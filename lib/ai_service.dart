import 'app_state.dart';

class AIService {
  static final AIService instance = AIService._init();
  AIService._init();

  // In a real app, this would call a real LLM like OpenAI or Gemini.
  // For this project, we'll create a "Smart Logic" AI that simulates deep analysis.

  Future<String> getFinancialAdvice(
      List<TransactionItem> transactions, List<GoalItem> goals) async {
    if (transactions.isEmpty) {
      return "Hello! I'm your AI advisor. Once you have some transactions, I'll analyze your spending patterns and help you manage your finances like a pro!";
    }

    final totalExpenses = transactions
        .where((t) => t.amount < 0)
        .fold(0, (s, t) => s + t.amount.abs());
    final totalIncome =
        transactions.where((t) => t.amount > 0).fold(0, (s, t) => s + t.amount);

    final expenseByCategory = <TxCategory, int>{};
    for (var t in transactions.where((t) => t.amount < 0)) {
      expenseByCategory[t.category] =
          (expenseByCategory[t.category] ?? 0) + t.amount.abs();
    }

    List<String> insights = [];

    // General Overspending Alert
    if (totalExpenses > totalIncome && totalIncome > 0) {
      insights.add(
          "🚨 **Attention Required**: You've spent ${appState.currency} ${(totalExpenses - totalIncome)} more than you've earned recently. I recommend pausing non-essential spending for the next 7 days.");
    }

    // Small Spend Analysis (Airtime/Food) - 1-250 KES
    final smallSpends = transactions
        .where((t) => t.amount.abs() <= 250 && t.amount < 0)
        .fold(0, (s, t) => s + t.amount.abs());
    if (smallSpends > (totalExpenses * 0.15)) {
      insights.add(
          "🍩 **Micro-Spending Leak**: Your small daily spends (below 250 KES) account for ${(smallSpends / totalExpenses * 100).toStringAsFixed(0)}% of your expenses. These 'small' amounts like airtime and snacks add up to ${appState.currency} $smallSpends. Consider a weekly budget for these.");
    }

    // Top Category Advice
    if (expenseByCategory.isNotEmpty) {
      final top =
          expenseByCategory.entries.reduce((a, b) => a.value > b.value ? a : b);
      if (top.key == TxCategory.shopping) {
        insights.add(
            "🛒 **Shopping Insight**: Shopping is your top expense at ${appState.currency} ${top.value}. Try making a list before you visit Naivas or Quickmart to avoid impulse buys.");
      } else if (top.key == TxCategory.entertainment) {
        insights.add(
            "🎬 **Lifestyle Audit**: Entertainment is taking a large chunk. Can you find free local alternatives for your next weekend outing?");
      }
    }

    // Savings Progress
    final savingsRate = totalIncome > 0
        ? ((totalIncome - totalExpenses) / totalIncome * 100)
        : 0;
    if (savingsRate > 20) {
      insights.add(
          "🌟 **Financial Star**: You're saving ${savingsRate.toStringAsFixed(1)}% of your income. This is excellent! If you maintain this, your emergency fund will be fully funded soon.");
    } else {
      insights.add(
          "📈 **Growth Opportunity**: Your current savings rate is ${savingsRate.clamp(0, 100).toStringAsFixed(1)}%. Aiming for 20% would give you much more freedom later.");
    }

    // Goal Specific Advice
    if (goals.isNotEmpty) {
      final closestGoal = goals.first;
      final remaining = closestGoal.target - closestGoal.saved;
      if (remaining > 0) {
        final daysInMonth = 30;
        final dailyNeeded = (remaining / daysInMonth).round();
        insights.add(
            "🎯 **Goal Target**: To hit '${closestGoal.name}' in a month, you need to save about ${appState.currency} $dailyNeeded per day. I can help you find where to save that!");
      }
    }

    return insights.take(4).join("\n\n");
  }
}
