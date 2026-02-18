import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Financial Insights', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final totalTx = appState.transactions.length;
          final avgExpense = appState.transactions.where((t) => t.amount < 0).isEmpty
              ? 0
              : appState.totalExpenses ~/ appState.transactions.where((t) => t.amount < 0).length;
          final avgIncome = appState.transactions.where((t) => t.amount > 0).isEmpty
              ? 0
              : appState.totalIncome ~/ appState.transactions.where((t) => t.amount > 0).length;
          final savingsRate = appState.totalIncome == 0 ? 0 : ((appState.balance / appState.totalIncome) * 100).round();
          final topCategory = appState.expenseByCategory.entries.isEmpty
              ? null
              : appState.expenseByCategory.entries.reduce((a, b) => a.value > b.value ? a : b);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InsightCard(
                icon: Icons.analytics_outlined,
                title: 'Total Transactions',
                value: '$totalTx',
                subtitle: 'All time',
                color: Colors.blue,
              ),
              _InsightCard(
                icon: Icons.trending_up,
                title: 'Average Income',
                value: '${appState.currency} $avgIncome',
                subtitle: 'Per transaction',
                color: AppColors.success,
              ),
              _InsightCard(
                icon: Icons.trending_down,
                title: 'Average Expense',
                value: '${appState.currency} $avgExpense',
                subtitle: 'Per transaction',
                color: AppColors.error,
              ),
              _InsightCard(
                icon: Icons.savings_outlined,
                title: 'Savings Rate',
                value: '$savingsRate%',
                subtitle: 'Of total income',
                color: AppColors.gold,
              ),
              if (topCategory != null)
                _InsightCard(
                  icon: topCategory.key.icon,
                  title: 'Top Spending Category',
                  value: topCategory.key.label,
                  subtitle: '${appState.currency} ${topCategory.value}',
                  color: AppColors.burgundy,
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.burgundy, AppColors.burgundyDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Financial Tips',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTip('💡', 'Try to save at least 20% of your income'),
                    _buildTip('📊', 'Track your expenses daily for better insights'),
                    _buildTip('🎯', 'Set specific, measurable savings goals'),
                    _buildTip('⚠️', 'Avoid impulse purchases - wait 24 hours'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.burgundy),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
