import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/tx_tile.dart';
import '../widgets/summary_card.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  String _query = '';
  TxCategory _filterCategory = TxCategory.other;
  bool _filterAll = true;
  TxCategory _selectedCategory = TxCategory.other;
  bool _isExpense = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showAddSheet() {
    _titleCtrl.clear();
    _amountCtrl.clear();
    _noteCtrl.clear();
    _selectedCategory = TxCategory.other;
    _isExpense = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.silver,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('NEW TRANSACTION',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: AppColors.burgundy)),
                  IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, size: 20)),
                ],
              ),
              const SizedBox(height: 20),

              // Income / Expense toggle
              Container(
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => _isExpense = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isExpense
                                ? AppColors.burgundy
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('Expense',
                                style: TextStyle(
                                    color: _isExpense
                                        ? Colors.white
                                        : AppColors.burgundy.withOpacity(0.6),
                                    fontWeight: _isExpense
                                        ? FontWeight.w800
                                        : FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => _isExpense = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isExpense
                                ? AppColors.burgundy
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('Income',
                                style: TextStyle(
                                    color: !_isExpense
                                        ? Colors.white
                                        : AppColors.burgundy.withOpacity(0.6),
                                    fontWeight: !_isExpense
                                        ? FontWeight.w800
                                        : FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _titleCtrl,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'What was this for?',
                  prefixIcon: const Icon(Icons.description_outlined,
                      color: AppColors.burgundy),
                  filled: true,
                  fillColor: AppColors.offWhite,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.burgundy,
                    fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: const Icon(Icons.wallet_outlined,
                      color: AppColors.burgundy),
                  suffixText: appState.currency,
                  filled: true,
                  fillColor: AppColors.offWhite,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  prefixIcon: const Icon(Icons.notes_rounded,
                      color: AppColors.burgundy),
                  filled: true,
                  fillColor: AppColors.offWhite,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              // Category picker
              const Text('CATEGORY',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Colors.grey)),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: TxCategory.values.map((cat) {
                    final selected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setSheetState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.gold : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color:
                                  selected ? AppColors.gold : AppColors.silver),
                        ),
                        child: Row(
                          children: [
                            Icon(cat.icon,
                                size: 16,
                                color: selected
                                    ? Colors.white
                                    : AppColors.burgundy),
                            const SizedBox(width: 8),
                            Text(cat.label,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.burgundy,
                                    fontWeight: selected
                                        ? FontWeight.w800
                                        : FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.burgundy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final title = _titleCtrl.text.trim();
                    final rawStr =
                        _amountCtrl.text.trim().replaceAll(RegExp(r'[, ]'), '');
                    final raw = int.tryParse(rawStr) ?? 0;
                    if (title.isEmpty || raw == 0) return;
                    final amount = _isExpense ? -raw.abs() : raw.abs();
                    appState.addTransaction(title, amount, _selectedCategory,
                        note: _noteCtrl.text.trim().isEmpty
                            ? null
                            : _noteCtrl.text.trim());
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('CONFIRM TRANSACTION',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRANSACTIONS',
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 12),
          unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500, letterSpacing: 1, fontSize: 12),
          tabs: const [
            Tab(text: 'HISTORY'),
            Tab(text: 'ANALYTICS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── History Tab ───────────────────────────────────────────────────
          AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              final filtered = appState.transactions.where((t) {
                final matchQuery =
                    t.title.toLowerCase().contains(_query.toLowerCase());
                final matchCat = _filterAll || t.category == _filterCategory;
                return matchQuery && matchCat;
              }).toList();

              return Column(
                children: [
                  // Search & Category area
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search_rounded,
                                  color: AppColors.burgundy),
                              hintText: 'Search your transactions...',
                              filled: true,
                              fillColor: AppColors.offWhite,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                            ),
                            onChanged: (v) => setState(() => _query = v),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            children: [
                              ChoiceChip(
                                label: const Text('All'),
                                selected: _filterAll,
                                onSelected: (_) =>
                                    setState(() => _filterAll = true),
                                selectedColor: AppColors.burgundy,
                                labelStyle: TextStyle(
                                    color: _filterAll
                                        ? Colors.white
                                        : AppColors.burgundy,
                                    fontWeight: FontWeight.bold),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                    color: _filterAll
                                        ? AppColors.burgundy
                                        : AppColors.silver),
                                showCheckmark: false,
                              ),
                              const SizedBox(width: 8),
                              ...TxCategory.values.map((cat) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(cat.label),
                                      selected:
                                          !_filterAll && _filterCategory == cat,
                                      onSelected: (_) => setState(() {
                                        _filterAll = false;
                                        _filterCategory = cat;
                                      }),
                                      selectedColor: AppColors.burgundy,
                                      labelStyle: TextStyle(
                                          color: (!_filterAll &&
                                                  _filterCategory == cat)
                                              ? Colors.white
                                              : AppColors.burgundy,
                                          fontWeight: FontWeight.bold),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                          color: (!_filterAll &&
                                                  _filterCategory == cat)
                                              ? AppColors.burgundy
                                              : AppColors.silver),
                                      showCheckmark: false,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // List
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 64, color: AppColors.silver),
                                const SizedBox(height: 16),
                                const Text('No records found',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return TxTile(
                                tx: item,
                                currency: appState.currency,
                                onDelete: () =>
                                    appState.deleteTransaction(item.id),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),

          // ── Analytics Tab ──────────────────────────────────────────────────
          AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              final byCategory = appState.expenseByCategory;
              final total = appState.totalExpenses;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.burgundy, AppColors.burgundyDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        _AnalyticRow(
                            label: 'Total Inflow',
                            amount: appState.totalIncome,
                            color: AppColors.success,
                            currency: appState.currency),
                        const SizedBox(height: 16),
                        _AnalyticRow(
                            label: 'Total Outflow',
                            amount: appState.totalExpenses,
                            color: Colors.orangeAccent,
                            currency: appState.currency),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(color: Colors.white12),
                        ),
                        _AnalyticRow(
                            label: 'Net Positioning',
                            amount: appState.balance,
                            color: AppColors.gold,
                            currency: appState.currency,
                            isBold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 10),
                      const Text('OUTFLOW BY CATEGORY',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1.2,
                              color: AppColors.burgundy)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (byCategory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                          child: Text('No analytical data available.',
                              style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ...byCategory.entries.map((e) {
                      final pct = total == 0 ? 0.0 : e.value / total;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.silver.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color:
                                          AppColors.burgundy.withOpacity(0.05),
                                      shape: BoxShape.circle),
                                  child: Icon(e.key.icon,
                                      size: 16, color: AppColors.burgundy),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(e.key.label,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.darkGrey))),
                                Text('${appState.currency} ${e.value}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.burgundy)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Stack(
                              children: [
                                Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                        color: AppColors.offWhite,
                                        borderRadius:
                                            BorderRadius.circular(3))),
                                FractionallySizedBox(
                                  widthFactor: pct,
                                  child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                          color: AppColors.gold,
                                          borderRadius:
                                              BorderRadius.circular(3))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('${(pct * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey)),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AnalyticRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final String currency;
  final bool isBold;

  const _AnalyticRow(
      {required this.label,
      required this.amount,
      required this.color,
      required this.currency,
      this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.toUpperCase(),
            style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
        Text(
          '$currency ${amount.abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
          style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: isBold ? AppColors.gold : Colors.white,
              fontSize: isBold ? 18 : 15),
        ),
      ],
    );
  }
}
