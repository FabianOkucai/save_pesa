import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../theme.dart';
import 'package:fl_chart/fl_chart.dart';
import '../ai_service.dart';

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
              const SizedBox(height: 24),
              // Category Distribution Graph
              if (appState.expenseByCategory.isNotEmpty) ...[
                Text(
                  'EXPENSE DISTRIBUTION',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.burgundy.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 240,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border:
                        Border.all(color: AppColors.silver.withOpacity(0.5)),
                  ),
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: appState.expenseByCategory.entries.map((e) {
                        return PieChartSectionData(
                          color: e.key.color,
                          value: e.value.toDouble(),
                          title:
                              '${(e.value / appState.totalExpenses.abs() * 100).toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              const SizedBox(height: 12),
              FutureBuilder<String>(
                future: AIService.instance
                    .getFinancialAdvice(appState.transactions, appState.goals),
                builder: (context, snapshot) {
                  return Container(
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
                              'AI FINANCIAL ADVISOR',
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
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                        else
                          Text(
                            snapshot.data ?? 'No advice available yet.',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          );
        },
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
