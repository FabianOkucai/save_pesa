import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/notification.dart';
import 'database_helper.dart';
import 'automation_service.dart';

// ── Enums & Extensions ────────────────────────────────────────────────────────

enum TxCategory {
  food,
  transport,
  salary,
  shopping,
  health,
  entertainment,
  other
}

extension TxCategoryExt on TxCategory {
  String get label {
    switch (this) {
      case TxCategory.food:
        return 'Food';
      case TxCategory.transport:
        return 'Transport';
      case TxCategory.salary:
        return 'Salary';
      case TxCategory.shopping:
        return 'Shopping';
      case TxCategory.health:
        return 'Health';
      case TxCategory.entertainment:
        return 'Entertainment';
      case TxCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TxCategory.food:
        return Icons.restaurant;
      case TxCategory.transport:
        return Icons.directions_car;
      case TxCategory.salary:
        return Icons.work;
      case TxCategory.shopping:
        return Icons.shopping_bag;
      case TxCategory.health:
        return Icons.local_hospital;
      case TxCategory.entertainment:
        return Icons.movie;
      case TxCategory.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case TxCategory.food:
        return Colors.orange;
      case TxCategory.transport:
        return Colors.blue;
      case TxCategory.salary:
        return Colors.green;
      case TxCategory.shopping:
        return Colors.purple;
      case TxCategory.health:
        return Colors.red;
      case TxCategory.entertainment:
        return Colors.pink;
      case TxCategory.other:
        return Colors.grey;
    }
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

class TransactionItem {
  final String id;
  final String title;
  final int amount;
  final DateTime date;
  final TxCategory category;
  final String? note;
  final String? mpesaId;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category = TxCategory.other,
    this.note,
    this.mpesaId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category.name,
        'note': note,
        'mpesa_id': mpesaId,
      };
}

class GoalItem {
  final String id;
  final String name;
  final int target;
  int saved;
  final IconData icon;
  final Color color;
  final DateTime? deadline;

  GoalItem({
    required this.id,
    required this.name,
    required this.target,
    this.saved = 0,
    this.icon = Icons.flag,
    this.color = Colors.blue,
    this.deadline,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'target': target,
        'saved': saved,
        'icon_code': icon.codePoint,
        'color_hex': '0x${color.value.toRadixString(16)}',
        'deadline': deadline?.toIso8601String(),
      };
}

// ── AppState ──────────────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  static String get baseUrl {
    if (kIsWeb) {
      // On web, localhost is usually correct for dev
      return 'http://localhost:5000/api';
    }

    // For Android/Emulator, try the standard bridge.
    // Fallback logic exists in the login/register methods.
    return 'http://10.0.2.2:5000/api';
  }

  bool isLoggedIn = false;
  String _phone = '';
  String userName = '';
  String? _token;
  String get phone => _phone;

  final List<TransactionItem> transactions = [];
  final List<GoalItem> goals = [];
  final List<NotificationItem> notifications = [];

  ThemeMode themeMode = ThemeMode.light;
  String currency = 'KES';
  bool isBiometricEnabled = false;
  String? profilePic; // Base64 string

  AppState() {
    init();
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _phone = prefs.getString('phone') ?? '';
      userName = prefs.getString('name') ?? '';
      isLoggedIn = _token != null && _token!.isNotEmpty;
      isBiometricEnabled = prefs.getBool('biometric') ?? false;
      profilePic = prefs.getString('profilePic');
    } catch (e) {
      debugPrint('SharedPreferences init error: $e');
      // If plugin fails, we can't load stored session, but we shouldn't crash
      isLoggedIn = false;
    }

    await loadLocalData();
    if (isLoggedIn) {
      // Don't wait for sync during init to avoid splash hang
      syncWithBackend();
      AutomationService.instance.initialize();
    }
    notifyListeners();
  }

  Future<void> loadLocalData() async {
    final localTx = await DatabaseHelper.instance.getTransactions();
    final localGoals = await DatabaseHelper.instance.getGoals();
    transactions.clear();
    transactions.addAll(localTx);
    goals.clear();
    goals.addAll(localGoals);
    notifyListeners();
  }

  // --- Auth ---

  Future<String?> register(String phone, String name, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'name': name, 'password': password}),
      );

      if (response.statusCode == 201) return null;
      final data = jsonDecode(response.body);
      return data['error'] ?? 'Registration failed';
    } catch (e) {
      return 'Server unreachable';
    }
  }

  Future<String?> login(String phone, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phone, 'password': password}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        return await _handleLoginSuccess(response.body);
      }
      final data = jsonDecode(response.body);
      return data['error'] ?? 'Login failed';
    } catch (e) {
      // Fallback logic for BOTH mobile and web
      try {
        final fallbackUrl = 'http://172.28.96.1:5000/api/login';
        final fallRes = await http
            .post(
              Uri.parse(fallbackUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'phone': phone, 'password': password}),
            )
            .timeout(const Duration(seconds: 5));
        if (fallRes.statusCode == 200)
          return await _handleLoginSuccess(fallRes.body);
      } catch (_) {}

      return 'Server unreachable';
    }
  }

  Future<String?> _handleLoginSuccess(String body) async {
    final data = jsonDecode(body);
    _token = data['token'];
    _phone = data['user']['phone'];
    userName = data['user']['name'];
    isLoggedIn = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('phone', _phone);
      await prefs.setString('name', userName);
    } catch (e) {
      debugPrint('Warning: Could not save session locally: $e');
    }

    await syncWithBackend();
    AutomationService.instance.initialize();
    addNotification('👋 Welcome back!', 'Data synced with cloud.',
        NotificationType.reminder);
    notifyListeners();
    return null;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    isBiometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric', enabled);
    notifyListeners();
  }

  Future<void> updateProfilePic(String base64) async {
    profilePic = base64;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profilePic', base64);
    notifyListeners();
  }

  Future<void> logout() async {
    isLoggedIn = false;
    _token = null;
    _phone = '';
    userName = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await DatabaseHelper.instance.clearAll();
    transactions.clear();
    goals.clear();
    notifyListeners();
  }

  // --- Transactions ---

  Future<void> addTransaction(String title, int amount, TxCategory category,
      {String? note, String? mpesaId}) async {
    final tx = TransactionItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
      note: note,
      mpesaId: mpesaId,
    );

    transactions.insert(0, tx);
    await DatabaseHelper.instance.insertTransaction(tx);
    notifyListeners();
    syncWithBackend();
  }

  Future<void> deleteTransaction(String id) async {
    transactions.removeWhere((t) => t.id == id);
    await DatabaseHelper.instance.deleteTransaction(id);
    notifyListeners();
    // In a real app, you'd send a delete request to the backend too
  }

  // --- Goals ---

  Future<void> addGoal(String name, int target,
      {IconData icon = Icons.flag,
      Color color = Colors.blue,
      DateTime? deadline}) async {
    final goal = GoalItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      target: target,
      saved: 0,
      icon: icon,
      color: color,
      deadline: deadline,
    );

    goals.add(goal);
    await DatabaseHelper.instance.insertGoal(goal);
    notifyListeners();
    syncWithBackend();
  }

  Future<void> depositToGoal(String id, int amount) async {
    final g = goals.firstWhere((x) => x.id == id);
    g.saved = (g.saved + amount).clamp(0, g.target);
    await DatabaseHelper.instance.insertGoal(g);
    notifyListeners();
    syncWithBackend();
  }

  // --- Sync ---

  Future<void> syncWithBackend() async {
    if (!isLoggedIn || _token == null) return;

    try {
      // Sync Transactions
      await http.post(
        Uri.parse('$baseUrl/transactions/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'transactions': transactions.map((t) => t.toJson()).toList(),
        }),
      );

      // Sync Goals
      await http.post(
        Uri.parse('$baseUrl/goals/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'goals': goals.map((g) => g.toJson()).toList(),
        }),
      );

      print('Sync completed successfully');
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  // --- Helpers ---

  int get balance => transactions.fold<int>(0, (sum, t) => sum + t.amount);
  int get totalIncome => transactions
      .where((t) => t.amount > 0)
      .fold<int>(0, (s, t) => s + t.amount);
  int get totalExpenses => transactions
      .where((t) => t.amount < 0)
      .fold<int>(0, (s, t) => s + t.amount.abs());
  int get totalSaved => goals.fold<int>(0, (s, g) => s + g.saved);

  Map<TxCategory, int> get expenseByCategory {
    final map = <TxCategory, int>{};
    for (final t in transactions.where((t) => t.amount < 0)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount.abs();
    }
    return map;
  }

  void toggleTheme(bool dark) {
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void addNotification(String title, String message, NotificationType type) {
    notifications.insert(
        0,
        NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          message: message,
          timestamp: DateTime.now(),
          type: type,
        ));
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    goals.removeWhere((g) => g.id == id);
    await DatabaseHelper.instance.deleteGoal(id);
    notifyListeners();
  }

  void setUserName(String name) {
    userName = name;
    notifyListeners();
  }

  void setCurrency(String c) {
    currency = c;
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final notif = notifications.firstWhere((n) => n.id == id);
    notif.isRead = true;
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;
}

final AppState appState = AppState();
