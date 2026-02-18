import 'package:flutter/material.dart';
import '../app_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final recentTx = appState.transactions.take(5).toList();
          return CustomScrollView(
            slivers: [
              // ── Hero Header ──────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: cs.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [cs.primary, cs.tertiary],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hello, ${appState.userName} 👋',
                                      style: TextStyle(
                                        color: cs.onPrimary.withOpacity(0.85),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'SavePesa',
                                      style: TextStyle(
                                        color: cs.onPrimary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                CircleAvatar(
                                  backgroundColor: cs.onPrimary.withOpacity(0.2),
                                  child: Icon(Icons.person, color: cs.onPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Total Balance',
                              style: TextStyle(
                                color: cs.onPrimary.withOpacity(0.75),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${appState.currency} ${appState.balance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                              style: TextStyle(
                                color: cs.onPrimary,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        child: _SummaryCard(
                          label: 'Income',
                          amount: appState.totalIncome,
                          icon: Icons.arrow_downward_rounded,
                          color: Colors.green,
                          currency: appState.currency,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Expenses',
                          amount: appState.totalExpenses,
                          icon: Icons.arrow_upward_rounded,
                          color: Colors.red,
                          currency: appState.currency,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Spending by Category ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Text(
                    'Spending by Category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    scrollDirection: Axis.horizontal,
                    children: appState.expenseByCategory.entries.map((e) {
                      return _CategoryChip(category: e.key, amount: e.value, currency: appState.currency);
                    }).toList(),
                  ),
                ),
              ),

              // ── Savings Progress ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Card(
                    elevation: 0,
                    color: cs.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Savings Goals',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: cs.onPrimaryContainer)),
                              Text('${appState.goals.length} active',
                                  style: TextStyle(
                                      color: cs.onPrimaryContainer.withOpacity(0.7),
                                      fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...appState.goals.take(2).map((g) {
                            final pct = (g.saved / g.target).clamp(0.0, 1.0);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Icon(g.icon, size: 14, color: g.color),
                                        const SizedBox(width: 6),
                                        Text(g.name,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: cs.onPrimaryContainer)),
                                      ]),
                                      Text(
                                        '${(pct * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: g.color),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 6,
                                      backgroundColor: cs.onPrimaryContainer.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(g.color),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Recent Transactions ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Transactions',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text('${appState.transactions.length} total',
                          style: TextStyle(
                              fontSize: 12, color: cs.onSurface.withOpacity(0.5))),
                    ],
                  ),
                ),
              ),
              if (recentTx.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No transactions yet')),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final t = recentTx[index];
                      return _TxTile(tx: t, currency: appState.currency);
                    },
                    childCount: recentTx.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final int amount;
  final IconData icon;
  final Color color;
  final String currency;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 2),
                  Text(
                    '$currency ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: color, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final TxCategory category;
  final int amount;
  final String currency;

  const _CategoryChip(
      {required this.category, required this.amount, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: category.color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(category.icon, color: category.color, size: 20),
          const SizedBox(height: 4),
          Text(category.label,
              style: TextStyle(fontSize: 11, color: category.color, fontWeight: FontWeight.w600)),
          Text('$currency $amount',
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final TransactionItem tx;
  final String currency;

  const _TxTile({required this.tx, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.amount > 0;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: tx.category.color.withOpacity(0.15),
        child: Icon(tx.category.icon, color: tx.category.color, size: 20),
      ),
      title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${tx.date.day}/${tx.date.month}/${tx.date.year}  •  ${tx.category.label}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'}$currency ${tx.amount.abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isIncome ? Colors.green : Colors.red,
          fontSize: 14,
        ),
      ),
    );
  }
}
