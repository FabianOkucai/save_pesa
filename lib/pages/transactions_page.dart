import 'package:flutter/material.dart';
import '../app_state.dart';

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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Add Transaction',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Income / Expense toggle
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setSheetState(() => _isExpense = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isExpense ? Colors.red : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Center(
                          child: Text('Expense',
                              style: TextStyle(
                                  color: _isExpense ? Colors.white : Colors.red,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setSheetState(() => _isExpense = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isExpense ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Center(
                          child: Text('Income',
                              style: TextStyle(
                                  color: !_isExpense ? Colors.white : Colors.green,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Title',
                  prefixIcon: const Icon(Icons.label_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (${appState.currency})',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: const Icon(Icons.notes),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Category picker
              Text('Category',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TxCategory.values.map((cat) {
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setSheetState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? cat.color : cat.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cat.color.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat.icon,
                              size: 14,
                              color: selected ? Colors.white : cat.color),
                          const SizedBox(width: 4),
                          Text(cat.label,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: selected ? Colors.white : cat.color,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Transaction'),
                  onPressed: () {
                    final title = _titleCtrl.text.trim();
                    final raw = int.tryParse(
                            _amountCtrl.text.trim().replaceAll(RegExp(r'[, ]'), '')) ??
                        0;
                    if (title.isEmpty || raw == 0) return;
                    final amount = _isExpense ? -raw.abs() : raw.abs();
                    appState.addTransaction(title, amount, _selectedCategory,
                        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim());
                    Navigator.of(ctx).pop();
                  },
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Summary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── All Transactions Tab ──────────────────────────────────────────
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
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Search transactions…',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  // Category filter chips
                  SizedBox(
                    height: 52,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('All'),
                            selected: _filterAll,
                            onSelected: (_) => setState(() {
                              _filterAll = true;
                            }),
                          ),
                        ),
                        ...TxCategory.values.map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                avatar: Icon(cat.icon, size: 14, color: cat.color),
                                label: Text(cat.label),
                                selected: !_filterAll && _filterCategory == cat,
                                onSelected: (_) => setState(() {
                                  _filterAll = false;
                                  _filterCategory = cat;
                                }),
                              ),
                            )),
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
                                    size: 56, color: cs.onSurface.withOpacity(0.3)),
                                const SizedBox(height: 12),
                                Text('No transactions found',
                                    style: TextStyle(
                                        color: cs.onSurface.withOpacity(0.5))),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, indent: 72),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final isIncome = item.amount > 0;
                              return Dismissible(
                                key: ValueKey(item.id),
                                background: Container(
                                  color: Colors.red.shade400,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                secondaryBackground: Container(
                                  color: Colors.red.shade400,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (_) =>
                                    appState.deleteTransaction(item.id),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        item.category.color.withOpacity(0.15),
                                    child: Icon(item.category.icon,
                                        color: item.category.color, size: 20),
                                  ),
                                  title: Text(item.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.date.day}/${item.date.month}/${item.date.year}  •  ${item.category.label}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      if (item.note != null)
                                        Text(item.note!,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: cs.onSurface.withOpacity(0.5),
                                                fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                  trailing: Text(
                                    '${isIncome ? '+' : '-'}${appState.currency} ${item.amount.abs()}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isIncome ? Colors.green : Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),

          // ── Summary Tab ───────────────────────────────────────────────────
          AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              final byCategory = appState.expenseByCategory;
              final total = appState.totalExpenses;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Income vs Expense card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _SummaryRow(
                              label: 'Total Income',
                              amount: appState.totalIncome,
                              color: Colors.green,
                              currency: appState.currency),
                          const Divider(height: 20),
                          _SummaryRow(
                              label: 'Total Expenses',
                              amount: appState.totalExpenses,
                              color: Colors.red,
                              currency: appState.currency),
                          const Divider(height: 20),
                          _SummaryRow(
                              label: 'Net Balance',
                              amount: appState.balance,
                              color: appState.balance >= 0
                                  ? Colors.green
                                  : Colors.red,
                              currency: appState.currency),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Expenses by Category',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...byCategory.entries.map((e) {
                    final pct = total == 0 ? 0.0 : e.value / total;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(e.key.icon, size: 16, color: e.key.color),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(e.key.label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ),
                              Text(
                                '${appState.currency} ${e.value}',
                                style: TextStyle(
                                    color: e.key.color,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(pct * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurface.withOpacity(0.5)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: e.key.color.withOpacity(0.1),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(e.key.color),
                            ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final String currency;

  const _SummaryRow(
      {required this.label,
      required this.amount,
      required this.color,
      required this.currency});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500)),
        Text(
          '$currency ${amount.abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: color, fontSize: 15),
        ),
      ],
    );
  }
}
