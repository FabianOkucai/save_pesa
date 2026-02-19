import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'app_state.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('save_pesa_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Check if mpesa_id exists before adding
      var tableInfo = await db.rawQuery('PRAGMA table_info(transactions)');
      bool columnExists = tableInfo.any((col) => col['name'] == 'mpesa_id');
      if (!columnExists) {
        await db.execute(
            'ALTER TABLE transactions ADD COLUMN mpesa_id TEXT UNIQUE');
      }
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount INTEGER NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        mpesa_id TEXT UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        target INTEGER NOT NULL,
        saved INTEGER DEFAULT 0,
        icon_code INTEGER,
        color_hex TEXT,
        deadline TEXT
      )
    ''');
  }

  // --- Transactions ---

  Future<void> insertTransaction(TransactionItem tx) async {
    final db = await instance.database;
    await db.insert(
      'transactions',
      {
        'id': tx.id,
        'title': tx.title,
        'amount': tx.amount,
        'date': tx.date.toIso8601String(),
        'category': tx.category.name,
        'note': tx.note,
        'mpesa_id': tx.mpesaId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTransactionsBatch(List<TransactionItem> txs) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var tx in txs) {
        batch.insert(
          'transactions',
          {
            'id': tx.id,
            'title': tx.title,
            'amount': tx.amount,
            'date': tx.date.toIso8601String(),
            'category': tx.category.name,
            'note': tx.note,
            'mpesa_id': tx.mpesaId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<TransactionItem>> getTransactions() async {
    final db = await instance.database;
    final maps = await db.query('transactions', orderBy: 'date DESC');

    return maps
        .map((json) => TransactionItem(
              id: json['id'] as String,
              title: json['title'] as String,
              amount: json['amount'] as int,
              date: DateTime.parse(json['date'] as String),
              category: TxCategory.values.firstWhere(
                (e) => e.name == json['category'],
                orElse: () => TxCategory.other,
              ),
              note: json['note'] as String?,
              mpesaId: json['mpesa_id'] as String?,
            ))
        .toList();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await instance.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // --- Goals ---

  Future<void> insertGoal(GoalItem goal) async {
    final db = await instance.database;
    await db.insert(
      'goals',
      {
        'id': goal.id,
        'name': goal.name,
        'target': goal.target,
        'saved': goal.saved,
        'icon_code': goal.icon.codePoint,
        'color_hex': '0x${goal.color.value.toRadixString(16)}',
        'deadline': goal.deadline?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GoalItem>> getGoals() async {
    final db = await instance.database;
    final maps = await db.query('goals');

    return maps
        .map((json) => GoalItem(
              id: json['id'] as String,
              name: json['name'] as String,
              target: json['target'] as int,
              saved: json['saved'] as int,
              // Note: mapping icon and color would need more logic if fully implemented
              // For now using defaults or basic mapping
              deadline: json['deadline'] != null
                  ? DateTime.parse(json['deadline'] as String)
                  : null,
            ))
        .toList();
  }

  Future<void> deleteGoal(String id) async {
    final db = await instance.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('transactions');
    await db.delete('goals');
  }
}
