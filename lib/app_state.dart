import 'package:flutter/material.dart';
import 'models/notification.dart';

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
  final int amount; // positive = income, negative = expense
  final DateTime date;
  final TxCategory category;
  final String? note;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category = TxCategory.other,
    this.note,
  });
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
}

// ── Auth ──────────────────────────────────────────────────────────────────────

class _UserRecord {
  final String phone;
  final String passwordHash;
  final String name;
  _UserRecord(
      {required this.phone, required this.passwordHash, required this.name});
}

// ── AppState ──────────────────────────────────────────────────────────────────

class AppState extends ChangeNotifier {
  // ── Auth state ────────────────────────────────────────────────────────────
  bool isLoggedIn = false;
  String _phone = '';
  String userName = '';
  String get phone => _phone;

  final List<_UserRecord> _users = [];

  /// Register a new user. Returns null on success, error string on failure.
  String? register(String phone, String name, String password) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 9) return 'Enter a valid phone number';
    if (name.trim().isEmpty) return 'Name is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (_users.any((u) => u.phone == cleaned))
      return 'Phone number already registered';

    _users.add(_UserRecord(
      phone: cleaned,
      passwordHash: _hash(password),
      name: name.trim(),
    ));
    return null;
  }

  /// Login an existing user. Returns null on success, error string on failure.
  String? login(String phone, String password) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    final user = _users.cast<_UserRecord?>().firstWhere(
          (u) => u!.phone == cleaned && u.passwordHash == _hash(password),
          orElse: () => null,
        );
    if (user == null) return 'Invalid phone number or password';

    _phone = user.phone;
    userName = user.name;
    isLoggedIn = true;
    transactions.clear();
    goals.clear();
    notifications.clear();
    addNotification('👋 Welcome back!', 'Ready to manage your finances today?', NotificationType.reminder);
    addNotification('💡 Quick Tip', 'Set a savings goal to stay motivated!', NotificationType.reminder);
    notifyListeners();
    return null;
  }

  void logout() {
    isLoggedIn = false;
    _phone = '';
    userName = '';
    transactions.clear();
    goals.clear();
    notifyListeners();
  }

  // Simple deterministic hash (NOT for production — use bcrypt in real apps)
  String _hash(String input) {
    int h = 5381;
    for (final c in input.codeUnits) {
      h = ((h << 5) + h) + c;
    }
    return h.toRadixString(16);
  }

  // ── Preferences ───────────────────────────────────────────────────────────
  ThemeMode themeMode = ThemeMode.light;
  String currency = 'KES';

  // ── Data ──────────────────────────────────────────────────────────────────
  final List<TransactionItem> transactions = [];
  final List<GoalItem> goals = [];
  final List<NotificationItem> notifications = [];

  // ── Computed ──────────────────────────────────────────────────────────────
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

  // ── Transactions ──────────────────────────────────────────────────────────
  void addTransaction(String title, int amount, TxCategory category,
      {String? note}) {
    transactions.insert(
      0,
      TransactionItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        date: DateTime.now(),
        category: category,
        note: note,
      ),
    );
    notifyListeners();
  }

  void deleteTransaction(String id) {
    transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ── Goals ─────────────────────────────────────────────────────────────────
  void addGoal(String name, int target,
      {IconData icon = Icons.flag,
      Color color = Colors.blue,
      DateTime? deadline}) {
    goals.add(GoalItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      target: target,
      saved: 0,
      icon: icon,
      color: color,
      deadline: deadline,
    ));
    notifyListeners();
  }

  void depositToGoal(String id, int amount) {
    final g = goals.firstWhere((x) => x.id == id);
    g.saved = (g.saved + amount).clamp(0, g.target);
    notifyListeners();
  }

  void deleteGoal(String id) {
    goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  // ── Settings ──────────────────────────────────────────────────────────────
  void toggleTheme(bool dark) {
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
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

  // ── Notifications ─────────────────────────────────────────────────────────
  void addNotification(String title, String message, NotificationType type) {
    notifications.insert(
      0,
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        message: message,
        timestamp: DateTime.now(),
        type: type,
      ),
    );
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

  int get unreadNotificationCount => notifications.where((n) => !n.isRead).length;
}

final AppState appState = AppState();
