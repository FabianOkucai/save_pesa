import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  static const List<IconData> _icons = [
    Icons.flight_takeoff, Icons.hotel, Icons.beach_access, Icons.home,
    Icons.directions_car, Icons.school, Icons.favorite, Icons.laptop,
    Icons.phone_android, Icons.watch, Icons.flag, Icons.star,
  ];
  static const List<Color> _colors = [
    AppColors.burgundy, AppColors.gold, Colors.teal, Colors.indigo,
    Colors.deepOrange, Colors.blueGrey, Colors.brown, AppColors.burgundyLight,
  ];

  void _addGoal() {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    IconData selectedIcon = _icons[0];
    Color selectedColor = _colors[0];
    DateTime? deadline;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.silver, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text('SET NEW DESTINATION', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.burgundy)),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Destination Name',
                  hintText: 'e.g., Summer in Paris',
                  prefixIcon: const Icon(Icons.place_outlined, color: AppColors.burgundy),
                  filled: true,
                  fillColor: AppColors.offWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.burgundy),
                decoration: InputDecoration(
                  labelText: 'Target Budget',
                  prefixIcon: const Icon(Icons.savings_outlined, color: AppColors.burgundy),
                  suffixText: appState.currency,
                  filled: true,
                  fillColor: AppColors.offWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_note_outlined, color: AppColors.burgundy),
                title: Text(deadline == null
                    ? 'Target Date (Optional)'
                    : 'Target: ${deadline!.day}/${deadline!.month}/${deadline!.year}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setSheetState(() => deadline = picked);
                },
              ),
              const SizedBox(height: 16),
              const Text('REPRESENTATION ICON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.grey)),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _icons.map((ic) {
                    final sel = selectedIcon == ic;
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedIcon = ic),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        width: 48,
                        decoration: BoxDecoration(
                          color: sel ? selectedColor : AppColors.offWhite,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(ic, size: 20, color: sel ? Colors.white : AppColors.burgundy),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final target = int.tryParse(targetCtrl.text.trim()) ?? 0;
                    if (name.isEmpty || target <= 0) return;
                    appState.addGoal(name, target, icon: selectedIcon, color: selectedColor, deadline: deadline);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('ACTIVATE SAVINGS PLAN', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deposit(GoalItem g) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('TOP UP: ${g.name.toUpperCase()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.burgundy)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${appState.currency} ${g.saved} / ${g.target}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold)),
            const SizedBox(height: 20),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Contribution Amount',
                filled: true,
                fillColor: AppColors.offWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.burgundy, foregroundColor: Colors.white),
            onPressed: () {
              final amount = int.tryParse(ctrl.text.trim()) ?? 0;
              if (amount > 0) {
                appState.depositToGoal(g.id, amount);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Contribute'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAVINGS VOYAGES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final goals = appState.goals;
          final totalSaved = appState.totalSaved;
          final totalTarget = goals.fold<int>(0, (s, g) => s + g.target);
          final overallPct = totalTarget == 0 ? 0.0 : (totalSaved / totalTarget).clamp(0.0, 1.0);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.burgundy, AppColors.burgundyDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL ACCUMULATED', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text(
                          '${appState.currency} ${totalSaved.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${(overallPct * 100).toStringAsFixed(1)}% OF TOTAL TARGET', style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w800)),
                            Text('TARGET: ${appState.currency} ${totalTarget}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Stack(
                          children: [
                            Container(height: 8, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4))),
                            FractionallySizedBox(
                              widthFactor: overallPct,
                              child: Container(height: 8, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(4))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (goals.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(64),
                    child: Center(child: Text('No active voyages. Begin your journey today.', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final g = goals[index];
                        final pct = (g.saved / g.target).clamp(0.0, 1.0);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.silver.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: g.color.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
                                      child: Icon(g.icon, color: g.color, size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(g.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                          Text('Remaining: ${appState.currency} ${g.target - g.saved}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('${(pct * 100).toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.w900, color: g.color, fontSize: 18)),
                                        const Text('COMPLETE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Stack(
                                  children: [
                                    Container(height: 4, decoration: BoxDecoration(color: AppColors.offWhite, borderRadius: BorderRadius.circular(2))),
                                    FractionallySizedBox(
                                      widthFactor: pct,
                                      child: Container(height: 4, decoration: BoxDecoration(color: g.color, borderRadius: BorderRadius.circular(2))),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextButton.icon(
                                        icon: const Icon(Icons.add, size: 16),
                                        label: const Text('CONTRIBUTE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                        style: TextButton.styleFrom(foregroundColor: g.color),
                                        onPressed: pct >= 1.0 ? null : () => _deposit(g),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                                      onPressed: () => appState.deleteGoal(g.id),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: goals.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.flight_takeoff),
      ),
    );
  }
}
