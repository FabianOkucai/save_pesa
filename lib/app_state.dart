import 'package:flutter/material.dart';

enum TxCategory { food, transport, salary, shopping, health, entertainment, other }

extension TxCategoryExt on TxCategory {
  String get label {
    switch (this) {
      case TxCategory.food: return 'Food';
      case TxCategory.transport: return 'Transport';
      case TxCategory.salary: return 'Salary';
      case TxCategory.shopping: return 'Shopping';
      case TxCategory.health: return 'Health';
      case TxCategory.entertainment: return 'Entertainment';
      case TxCategory.other: return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TxCategory.food: return Icons.restaurant;
      case TxCategory.transport: return Icons.directions_car;
      case TxCategory.salary: return Icons.work;
      case TxCategory.shopping: return Icons.shopping_bag;
      case TxCategory.health: return Icons.local_hospital;
      case TxCategory.entertainment: return Icons.movie;
      case TxCategory.other: return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case TxCategory.food: return Colors.orange;
      case TxCategory.transport: return Colors.blue;
      case TxCategory.salary: return Colors.green;
      case TxCategory.shopping: return Colors.purple;
      case TxCategory.health: return Colors.red;
      case TxCategory.entertainment: return Colors.pink;
      case TxCategory.other: return Colors.grey;
    }
  }
}

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

class AppState extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  String userName = 'Guest';
  String currency = 'KES';

  final List<TransactionItem> transactions = <TransactionItem>[
    TransactionItem(
        id: 't1',
        title: 'Monthly Salary',
        amount: 55000,
        date: DateTime(2026, 2, 1),
        category: TxCategory.salary,
        note: 'February salary'),
    TransactionItem(
        id: 't2',
        title: 'Groceries',
        amount: -3200,
        date: DateTime(2026, 2, 5),
        category: TxCategory.food,
        note: 'Naivas supermarket'),
    TransactionItem(
        id: 't3',
        title: 'Uber ride',
        amount: -450,
        date: DateTime(2026, 2, 8),
        category: TxCategory.transport),
    TransactionItem(
        id: 't4',
        title: 'Netflix',
        amount: -1100,
        date: DateTime(2026, 2, 10),
        category: TxCategory.entertainment),
    TransactionItem(
        id: 't5',
        title: 'Pharmacy',
        amount: -800,
        date: DateTime(2026, 2, 12),
        category: TxCategory.health),
    TransactionItem(
        id: 't6',
        title: 'Freelance project',
        amount: 12000,
        date: DateTime(2026, 2, 14),
        category: TxCategory.salary,
        note: 'Web design gig'),
    TransactionItem(
        id: 't7',
        title: 'Clothes shopping',
        amount: -4500,
        date: DateTime(2026, 2, 15),
        category: TxCategory.shopping),
  ];

  final List<GoalItem> goals = <GoalItem>[
    GoalItem(
        id: 'g1',
        name: 'New Phone',
        target: 30000,
        saved: 12000,
        icon: Icons.phone_android,
        color: Colors.indigo,
        deadline: DateTime(2026, 5, 1)),
    GoalItem(
        id: 'g2',
        name: 'Holiday Trip',
        target: 50000,
        saved: 15000,
        icon: Icons.flight,
        color: Colors.teal,
        deadline: DateTime(2026, 8, 15)),
    GoalItem(
        id: 'g3',
        name: 'Emergency Fund',
        target: 100000,
        saved: 40000,
        icon: Icons.shield,
        color: Colors.green),
  ];

  // ── Computed ──────────────────────────────────────────────────────────────
  int get balance => transactions.fold<int>(0, (sum, t) => sum + t.amount);
  int get totalIncome => transactions.where((t) => t.amount > 0).fold<int>(0, (s, t) => s + t.amount);
  int get totalExpenses => transactions.where((t) => t.amount < 0).fold<int>(0, (s, t) => s + t.amount.abs());
  int get totalSaved => goals.fold<int>(0, (s, g) => s + g.saved);

  Map<TxCategory, int> get expenseByCategory {
    final map = <TxCategory, int>{};
    for (final t in transactions.where((t) => t.amount < 0)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount.abs();
    }
    return map;
  }

  // ── Transactions ──────────────────────────────────────────────────────────
  void addTransaction(String title, int amount, TxCategory category, {String? note}) {
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
  void addGoal(String name, int target, {IconData icon = Icons.flag, Color color = Colors.blue, DateTime? deadline}) {
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
}

final AppState appState = AppState();
