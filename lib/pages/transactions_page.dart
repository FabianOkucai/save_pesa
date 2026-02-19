import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/tx_tile.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/summary_card.dart';
import '../media_service.dart';

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
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
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
                width: 40,
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
                Text('NEW TRANSACTION',
                    style: GoogleFonts.plusJakartaSans(
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
                      onTap: () => setState(() => _isExpense = true),
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
                              style: GoogleFonts.plusJakartaSans(
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
                      onTap: () => setState(() => _isExpense = false),
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
                              style: GoogleFonts.plusJakartaSans(
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
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'What was this for?',
                prefixIcon:
                    Icon(Icons.description_outlined, color: AppColors.burgundy),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  color: AppColors.burgundy,
                  fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: const Icon(Icons.wallet_outlined,
                    color: AppColors.burgundy),
                suffixText: appState.currency,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                prefixIcon:
                    Icon(Icons.notes_rounded, color: AppColors.burgundy),
              ),
            ),
            const SizedBox(height: 24),

            // Category picker
            Text('CATEGORY',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.grey)),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: TxCategory.values.map((cat) {
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.gold : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: selected
                                ? AppColors.gold
                                : AppColors.silver.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(cat.icon,
                              size: 16,
                              color:
                                  selected ? Colors.white : AppColors.burgundy),
                          const SizedBox(width: 8),
                          Text(cat.label,
                              style: GoogleFonts.plusJakartaSans(
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
                child: Text('CONFIRM TRANSACTION',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TRANSACTIONS',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 4,
          labelColor: AppColors.burgundy,
          unselectedLabelColor: Colors.grey[400],
          labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700, letterSpacing: 1, fontSize: 13),
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
                            onChanged: (v) => setState(() => _query = v),
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
                          ),
                        ),
                        SizedBox(
                          height: 44,
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
                                labelStyle: GoogleFonts.plusJakartaSans(
                                    color: _filterAll
                                        ? Colors.white
                                        : AppColors.burgundy,
                                    fontWeight: FontWeight.w800),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                    color: _filterAll
                                        ? AppColors.burgundy
                                        : AppColors.silver.withOpacity(0.5)),
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
                                      labelStyle: GoogleFonts.plusJakartaSans(
                                          color: (!_filterAll &&
                                                  _filterCategory == cat)
                                              ? Colors.white
                                              : AppColors.burgundy,
                                          fontWeight: FontWeight.w800),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                          color: (!_filterAll &&
                                                  _filterCategory == cat)
                                              ? AppColors.burgundy
                                              : AppColors.silver
                                                  .withOpacity(0.5)),
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
                                Text('No records found',
                                    style: GoogleFonts.plusJakartaSans(
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
                          padding: EdgeInsets.symmetric(vertical: 20),
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
                  if (byCategory.isNotEmpty) ...[
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: byCategory.entries.map((e) {
                            return PieChartSectionData(
                              color: e.key.color,
                              value: e.value.toDouble(),
                              title: '',
                              radius: 40,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    children: [
                      Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 12),
                      Text('OUTFLOW BY CATEGORY',
                          style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 1.2,
                              color: AppColors.burgundyDark)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (byCategory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(48),
                      child: Center(
                          child: Text('No analytical data available.',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500))),
                    )
                  else
                    ...byCategory.entries.map((e) {
                      final pct = total == 0 ? 0.0 : e.value / total;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                              color: AppColors.silver.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: e.key.color.withOpacity(0.12),
                                      shape: BoxShape.circle),
                                  child: Icon(e.key.icon,
                                      size: 18, color: e.key.color),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: Text(e.key.label,
                                        style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: AppColors.darkGrey))),
                                Text(
                                    '${appState.currency} ${e.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: AppColors.burgundy)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: AppColors.offWhite,
                                color: e.key.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text('${(pct * 100).toStringAsFixed(1)}%',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey[500])),
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            onPressed: () async {
              final result = await MediaService.instance.scanReceipt();
              if (result != null) {
                appState.addTransaction(
                  result['title'],
                  result['amount'],
                  result['category'],
                  note: result['note'],
                );
              }
            },
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.white,
            heroTag: 'scan_fab',
            child: const Icon(Icons.camera_alt_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            onPressed: _showAddSheet,
            backgroundColor: AppColors.burgundy,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            heroTag: 'add_fab',
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ],
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
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2)),
        Text(
          '$currency ${amount.abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
          style: GoogleFonts.plusJakartaSans(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: isBold ? AppColors.gold : Colors.white,
              fontSize: isBold ? 20 : 16),
        ),
      ],
    );
  }
}
