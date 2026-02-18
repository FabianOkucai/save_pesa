import 'package:flutter/material.dart';
import '../app_state.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  // Available icon/color options for new goals
  static const List<IconData> _icons = [
    Icons.phone_android, Icons.flight, Icons.shield, Icons.home,
    Icons.directions_car, Icons.school, Icons.favorite, Icons.laptop,
    Icons.sports_soccer, Icons.restaurant, Icons.flag, Icons.star,
  ];
  static const List<Color> _colors = [
    Colors.indigo, Colors.teal, Colors.green, Colors.orange,
    Colors.red, Colors.purple, Colors.blue, Colors.pink,
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('New Savings Goal',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Goal name',
                  prefixIcon: const Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target amount (${appState.currency})',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Deadline picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(deadline == null
                    ? 'Set deadline (optional)'
                    : 'Deadline: ${deadline!.day}/${deadline!.month}/${deadline!.year}'),
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
              const SizedBox(height: 8),

              // Icon picker
              Text('Icon', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _icons.map((ic) {
                  final sel = selectedIcon == ic;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedIcon = ic),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: sel ? selectedColor : selectedColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selectedColor.withOpacity(0.4)),
                      ),
                      child: Icon(ic, size: 20,
                          color: sel ? Colors.white : selectedColor),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Color picker
              Text('Color', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((c) {
                  final sel = selectedColor == c;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedColor = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: sel
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: sel
                            ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 6)]
                            : null,
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
                  label: const Text('Create Goal'),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final target = int.tryParse(targetCtrl.text.trim()) ?? 0;
                    if (name.isEmpty || target <= 0) return;
                    appState.addGoal(name, target,
                        icon: selectedIcon,
                        color: selectedColor,
                        deadline: deadline);
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

  void _deposit(GoalItem g) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: g.color.withOpacity(0.15),
              child: Icon(g.icon, color: g.color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('Deposit to ${g.name}')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${appState.currency} ${g.saved} / ${g.target}',
              style: TextStyle(color: g.color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (${appState.currency})',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amount = int.tryParse(ctrl.text.trim()) ?? 0;
              if (amount > 0) {
                appState.depositToGoal(g.id, amount);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(GoalItem g) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: Text('Are you sure you want to delete "${g.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              appState.deleteGoal(g.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final goals = appState.goals;
          final totalSaved = appState.totalSaved;
          final totalTarget = goals.fold<int>(0, (s, g) => s + g.target);

          return CustomScrollView(
            slivers: [
              // ── Overall savings summary ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 0,
                    color: cs.primaryContainer,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Saved',
                              style: TextStyle(
                                  color: cs.onPrimaryContainer.withOpacity(0.7),
                                  fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '${appState.currency} ${totalSaved.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: cs.onPrimaryContainer),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'of ${appState.currency} ${totalTarget.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} target across ${goals.length} goals',
                            style: TextStyle(
                                color: cs.onPrimaryContainer.withOpacity(0.6),
                                fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: totalTarget == 0
                                  ? 0
                                  : (totalSaved / totalTarget).clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor:
                                  cs.onPrimaryContainer.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Goal cards ───────────────────────────────────────────────
              if (goals.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(Icons.savings_outlined,
                            size: 64, color: cs.onSurface.withOpacity(0.25)),
                        const SizedBox(height: 16),
                        Text('No goals yet — tap + to create one',
                            style: TextStyle(
                                color: cs.onSurface.withOpacity(0.4))),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final g = goals[index];
                        final pct = (g.saved / g.target).clamp(0.0, 1.0);
                        final remaining = g.target - g.saved;
                        final daysLeft = g.deadline
                            ?.difference(DateTime.now())
                            .inDays;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                  color: g.color.withOpacity(0.2))),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: g.color.withOpacity(0.15),
                                      child: Icon(g.icon, color: g.color),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(g.name,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          if (daysLeft != null)
                                            Text(
                                              daysLeft > 0
                                                  ? '$daysLeft days left'
                                                  : 'Deadline passed',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: daysLeft > 0
                                                      ? cs.onSurface.withOpacity(0.5)
                                                      : Colors.red),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${(pct * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: g.color),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 8,
                                    backgroundColor: g.color.withOpacity(0.1),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(g.color),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${appState.currency} ${g.saved} saved',
                                      style: TextStyle(
                                          color: g.color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ),
                                    Text(
                                      '${appState.currency} $remaining to go',
                                      style: TextStyle(
                                          color: cs.onSurface.withOpacity(0.5),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.add, size: 16),
                                        label: const Text('Deposit'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: g.color,
                                          side: BorderSide(color: g.color),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        onPressed: pct >= 1.0
                                            ? null
                                            : () => _deposit(g),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () => _confirmDelete(g),
                                      tooltip: 'Delete goal',
                                    ),
                                  ],
                                ),
                                if (pct >= 1.0)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.green, size: 16),
                                        SizedBox(width: 6),
                                        Text('Goal achieved! 🎉',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: goals.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGoal,
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }
}
