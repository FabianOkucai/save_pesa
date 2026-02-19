import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../theme.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text('FINANCIAL INSIGHTS',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final totalTx = appState.transactions.length;
          final expenseCount =
              appState.transactions.where((t) => t.amount < 0).length;
          final incomeCount =
              appState.transactions.where((t) => t.amount > 0).length;

          final avgExpense = expenseCount == 0
              ? 0
              : appState.totalExpenses.abs() ~/ expenseCount;
          final avgIncome =
              incomeCount == 0 ? 0 : appState.totalIncome ~/ incomeCount;

          final savingsRate = appState.totalIncome == 0
              ? 0
              : ((appState.balance / appState.totalIncome) * 100).round();
          final topCategory = appState.expenseByCategory.entries.isEmpty
              ? null
              : appState.expenseByCategory.entries
                  .reduce((a, b) => a.value > b.value ? a : b);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _InsightCard(
                icon: Icons.analytics_outlined,
                title: 'TOTAL TRANSACTIONS',
                value: '$totalTx',
                subtitle: 'All time records',
                color: Colors.blue,
              ),
              _InsightCard(
                icon: Icons.trending_up_rounded,
                title: 'AVERAGE INCOME',
                value:
                    '${appState.currency} ${avgIncome.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                subtitle: 'Per deposit',
                color: AppColors.success,
              ),
              _InsightCard(
                icon: Icons.trending_down_rounded,
                title: 'AVERAGE EXPENSE',
                value:
                    '${appState.currency} ${avgExpense.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                subtitle: 'Per transaction',
                color: AppColors.error,
              ),
              _InsightCard(
                icon: Icons.savings_outlined,
                title: 'SAVINGS RATE',
                value: '${savingsRate.clamp(0, 100)}%',
                subtitle: 'Of total inflow',
                color: AppColors.gold,
              ),
              if (topCategory != null)
                _InsightCard(
                  icon: topCategory.key.icon,
                  title: 'TOP SPENDING',
                  value: topCategory.key.label,
                  subtitle:
                      '${appState.currency} ${topCategory.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  color: topCategory.key.color,
                ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.burgundy, AppColors.burgundyDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.burgundy.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: AppColors.gold, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'SMART TIPS',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildTip('💡', 'Aim to save 20% of every income.'),
                    _buildTip('📊', 'Identify your largest expense category.'),
                    _buildTip(
                        '🎯', 'Set specific goals to increase discipline.'),
                    _buildTip('⚡', 'Small changes lead to big growth.'),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
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
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.silver.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.burgundy,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
