import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/tx_tile.dart';
import '../widgets/summary_card.dart';
import '../models/notification.dart';
import 'notifications_page.dart';
import 'insights_page.dart';
import '../ai_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _timeFilter = 'All';
  TxCategory? _categoryFilter;

  List<TransactionItem> _getFilteredTransactions() {
    var txs = appState.transactions;
    final now = DateTime.now();

    if (_timeFilter == 'Week') {
      txs = txs.where((t) => now.difference(t.date).inDays <= 7).toList();
    } else if (_timeFilter == 'Month') {
      txs = txs.where((t) => now.difference(t.date).inDays <= 30).toList();
    }

    if (_categoryFilter != null) {
      txs = txs.where((t) => t.category == _categoryFilter).toList();
    }

    return txs.take(5).toList();
  }

  Future<String> _getAIAdviceSnippet() async {
    final advice = await AIService.instance
        .getFinancialAdvice(appState.transactions, appState.goals);
    final firstLine = advice.split('\n\n').first;
    return firstLine.replaceAll('**', ''); // Remove markdown for snippet
  }

  int _getBalanceTrend() {
    if (appState.transactions.length < 2) return 0;
    final now = DateTime.now();
    final lastWeek = appState.transactions
        .where((t) => now.difference(t.date).inDays <= 7)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final prevWeek = appState.transactions
        .where((t) =>
            now.difference(t.date).inDays > 7 &&
            now.difference(t.date).inDays <= 14)
        .fold<int>(0, (sum, t) => sum + t.amount);
    return prevWeek == 0 ? 0 : ((lastWeek - prevWeek) / prevWeek * 100).round();
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            _QuickActionTile(
              icon: Icons.add_circle_outline,
              title: 'Add Transaction',
              color: AppColors.burgundy,
              onTap: () {
                Navigator.pop(context);
                _showAddTransaction();
              },
            ),
            _QuickActionTile(
              icon: Icons.flag_outlined,
              title: 'Create Savings Goal',
              color: AppColors.gold,
              onTap: () {
                Navigator.pop(context);
                _showAddGoal();
              },
            ),
            _QuickActionTile(
              icon: Icons.insights_outlined,
              title: 'View Insights',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InsightsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransaction() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    TxCategory category = TxCategory.other;
    bool isIncome = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title')),
              TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Income'),
                value: isIncome,
                onChanged: (v) => setState(() => isIncome = v),
              ),
              DropdownButtonFormField<TxCategory>(
                value: category,
                items: TxCategory.values
                    .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.label)))
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(amountCtrl.text) ?? 0;
                if (titleCtrl.text.isNotEmpty && amount > 0) {
                  appState.addTransaction(
                      titleCtrl.text, isIncome ? amount : -amount, category);
                  appState.addNotification(
                    isIncome ? '💰 Income Added' : '💸 Expense Recorded',
                    '${titleCtrl.text}: ${appState.currency} $amount',
                    NotificationType.transaction,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoal() {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Savings Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Goal Name')),
            TextField(
                controller: targetCtrl,
                decoration: const InputDecoration(labelText: 'Target Amount'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final target = int.tryParse(targetCtrl.text) ?? 0;
              if (nameCtrl.text.isNotEmpty && target > 0) {
                appState.addGoal(nameCtrl.text, target);
                appState.addNotification(
                  '🎯 New Goal Created',
                  '${nameCtrl.text}: Target ${appState.currency} $target',
                  NotificationType.goal,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions,
        backgroundColor: AppColors.burgundy,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final recentTx = _getFilteredTransactions();
          final trend = _getBalanceTrend();
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              slivers: [
                // ── Hero Header ──────────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  stretch: true,
                  backgroundColor: AppColors.burgundy,
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                AppColors.burgundy,
                                AppColors.burgundyDark
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: -50,
                          right: -50,
                          child: CircleAvatar(
                            radius: 120,
                            backgroundColor: Colors.white.withOpacity(0.03),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.gold
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              )
                                            ],
                                          ),
                                          child: CircleAvatar(
                                            radius: 24,
                                            backgroundColor: AppColors.gold,
                                            child: CircleAvatar(
                                              radius: 22,
                                              backgroundColor:
                                                  AppColors.burgundyLight,
                                              child: appState.profilePic != null
                                                  ? ClipOval(
                                                      child: Image.memory(
                                                        base64Decode(appState
                                                            .profilePic!),
                                                        width: 44,
                                                        height: 44,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : Text(
                                                      appState.userName
                                                              .isNotEmpty
                                                          ? appState.userName[0]
                                                              .toUpperCase()
                                                          : 'U',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'WELCOME BACK',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                color: Colors.white
                                                    .withOpacity(0.6),
                                                fontSize: 10,
                                                letterSpacing: 2.5,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              appState.userName,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const NotificationsPage()),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.1)),
                                            ),
                                            child: const Icon(
                                                Icons
                                                    .notifications_none_rounded,
                                                color: Colors.white,
                                                size: 24),
                                          ),
                                          if (appState.unreadNotificationCount >
                                              0)
                                            Positioned(
                                              right: 4,
                                              top: 4,
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.error,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                // Glassmorphic Balance Card
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'AVAILABLE BALANCE',
                                            style: GoogleFonts.plusJakartaSans(
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                              fontSize: 11,
                                              letterSpacing: 1.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            color:
                                                AppColors.gold.withOpacity(0.8),
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            appState.currency,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: AppColors.gold,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              appState.balance
                                                  .toString()
                                                  .replaceAllMapped(
                                                      RegExp(
                                                          r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                                      (m) => '${m[1]},'),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                color: Colors.white,
                                                fontSize: 42,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: -1.0,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (trend != 0) ...[
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: trend > 0
                                                    ? AppColors.success
                                                        .withOpacity(0.2)
                                                    : AppColors.error
                                                        .withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: trend > 0
                                                        ? AppColors.success
                                                            .withOpacity(0.3)
                                                        : AppColors.error
                                                            .withOpacity(0.3)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    trend > 0
                                                        ? Icons.trending_up
                                                        : Icons.trending_down,
                                                    color: trend > 0
                                                        ? AppColors.success
                                                        : AppColors.error,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${trend.abs()}%',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      color: trend > 0
                                                          ? AppColors.success
                                                          : AppColors.error,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Motivational Message ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: FutureBuilder<String>(
                    future: _getAIAdviceSnippet(),
                    builder: (context, snapshot) => Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withOpacity(0.15),
                            AppColors.burgundy.withOpacity(0.08)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: AppColors.gold, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              snapshot.data ?? 'Analyzing your finances...',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.burgundy),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Income / Expense Cards ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            label: 'Income',
                            amount: appState.totalIncome,
                            icon: Icons.south_west_rounded,
                            color: AppColors.success,
                            currency: appState.currency,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            label: 'Expenses',
                            amount: appState.totalExpenses,
                            icon: Icons.north_east_rounded,
                            color: AppColors.error,
                            currency: appState.currency,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Savings Goals Preview ─────────────────────────────────────
                if (appState.goals.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'ACTIVE GOALS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: AppColors.burgundyDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: appState.goals.take(3).length,
                            itemBuilder: (context, i) {
                              final goal = appState.goals[i];
                              final progress = goal.saved / goal.target;
                              return Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.silver.withOpacity(0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: goal.color.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(goal.icon,
                                              color: goal.color, size: 20),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${(progress * 100).round()}%',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: goal.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      goal.name,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${appState.currency} ${goal.saved} / ${goal.target}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600]),
                                    ),
                                    const Spacer(),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey[200],
                                        color: goal.color,
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Spending by Category ──────────────────────────────────────
                if (appState.expenseByCategory.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'SPENDING BY CATEGORY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: AppColors.burgundyDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (appState.expenseByCategory.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 100,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        scrollDirection: Axis.horizontal,
                        children: appState.expenseByCategory.entries.map((e) {
                          return _CategoryChip(
                            category: e.key,
                            amount: e.value,
                            currency: appState.currency,
                            isSelected: _categoryFilter == e.key,
                            onTap: () {
                              setState(() {
                                _categoryFilter =
                                    _categoryFilter == e.key ? null : e.key;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                // ── Time Filter & Recent Transactions ─────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'RECENT TRANSACTIONS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: AppColors.burgundyDark,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _FilterChip(
                              label: 'All',
                              isSelected: _timeFilter == 'All',
                              onTap: () => setState(() => _timeFilter = 'All'),
                            ),
                            _FilterChip(
                              label: 'Week',
                              isSelected: _timeFilter == 'Week',
                              onTap: () => setState(() => _timeFilter = 'Week'),
                            ),
                            _FilterChip(
                              label: 'Month',
                              isSelected: _timeFilter == 'Month',
                              onTap: () =>
                                  setState(() => _timeFilter = 'Month'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (recentTx.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first transaction',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final t = recentTx[index];
                        return TxTile(tx: t, currency: appState.currency);
                      },
                      childCount: recentTx.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final TxCategory category;
  final int amount;
  final String currency;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.amount,
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.burgundy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? AppColors.burgundy
                  : AppColors.silver.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.burgundy.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon,
                  color: isSelected ? Colors.white : AppColors.burgundy,
                  size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.burgundy,
                  ),
                ),
                Text(
                  '$currency $amount',
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? Colors.white70 : Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.burgundy : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? AppColors.burgundy : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
