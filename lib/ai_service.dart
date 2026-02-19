import 'app_state.dart';

class AIService {
  static final AIService instance = AIService._init();
  AIService._init();

  // In a real app, this would call a real LLM like OpenAI or Gemini.
  // For this project, we'll create a "Smart Logic" AI that simulates deep analysis.

  Future<String> getFinancialAdvice(
      List<TransactionItem> transactions, List<GoalItem> goals) async {
    if (transactions.isEmpty) {
      return "Hello! I'm your AI advisor. Once you have some transactions, I'll analyze your spending patterns and help you save!";
    }

    final totalExpenses = transactions
        .where((t) => t.amount < 0)
        .fold(0, (s, t) => s + t.amount.abs());
    final totalIncome =
        transactions.where((t) => t.amount > 0).fold(0, (s, t) => s + t.amount);

    final shopping = transactions
        .where((t) => t.category == TxCategory.shopping)
        .fold(0, (s, t) => s + t.amount.abs());
    final transport = transactions
        .where((t) => t.category == TxCategory.transport)
        .fold(0, (s, t) => s + t.amount.abs());

    List<String> insights = [];

    if (totalExpenses > totalIncome && totalIncome > 0) {
      insights.add(
          "⚠️ You are currently spending more than you earn. Try to cut back on non-essential categories.");
    }

    if (shopping > (totalExpenses * 0.4)) {
      insights.add(
          "🛒 Your shopping expenses are quite high (over 40% of total). Have you considered using a budget for Naivas/Quickmart visits?");
    }

    if (transport > (totalExpenses * 0.2)) {
      insights.add(
          "🚗 Transport is taking a significant chunk of your cash. Maybe try carpooling or off-peak travel?");
    }

    final savingsRate = totalIncome > 0
        ? ((totalIncome - totalExpenses) / totalIncome * 100)
        : 0;
    if (savingsRate > 20) {
      insights.add(
          "🌟 Amazing! Your savings rate is ${savingsRate.toStringAsFixed(1)}%. You're on track for financial freedom.");
    } else if (savingsRate > 0) {
      insights.add(
          "📈 You're saving ${savingsRate.toStringAsFixed(1)}% of your income. Increasing this to 20% would speed up your goals significantly.");
    }

    if (goals.isNotEmpty) {
      final closestGoal = goals.first;
      final remaining = closestGoal.target - closestGoal.saved;
      insights.add(
          "🎯 For your '${closestGoal.name}' goal, you only need ${appState.currency} $remaining more. You can do it!");
    }

    return insights.join("\n\n");
  }
}
