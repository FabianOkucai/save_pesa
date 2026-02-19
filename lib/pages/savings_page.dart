import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../theme.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  static const List<IconData> _icons = [
    Icons.flight_takeoff,
    Icons.hotel,
    Icons.beach_access,
    Icons.home,
    Icons.directions_car,
    Icons.school,
    Icons.favorite,
    Icons.laptop,
    Icons.phone_android,
    Icons.watch,
    Icons.flag,
    Icons.star,
  ];
  static const List<Color> _colors = [
    AppColors.burgundy,
    AppColors.gold,
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
    Colors.blueGrey,
    Colors.brown,
    AppColors.burgundyLight,
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
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text('SET NEW DESTINATION',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppColors.burgundy)),
            const SizedBox(height: 24),
            TextField(
              controller: nameCtrl,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Destination Name',
                hintText: 'e.g., Summer in Paris',
                prefixIcon:
                    const Icon(Icons.place_outlined, color: AppColors.burgundy),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800, color: AppColors.burgundy),
              decoration: InputDecoration(
                labelText: 'Target Budget',
                prefixIcon: const Icon(Icons.savings_outlined,
                    color: AppColors.burgundy),
                suffixText: appState.currency,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_note_outlined,
                  color: AppColors.burgundy),
              title: Text(
                  deadline == null
                      ? 'Target Date (Optional)'
                      : 'Target: ${deadline!.day}/${deadline!.month}/${deadline!.year}',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                            primary: AppColors.burgundy),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) setState(() => deadline = picked);
              },
            ),
            const SizedBox(height: 16),
            Text('REPRESENTATION ICON',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: Colors.grey)),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _icons.map((ic) {
                  final sel = selectedIcon == ic;
                  return GestureDetector(
                    onTap: () => setState(() => selectedIcon = ic),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      width: 48,
                      decoration: BoxDecoration(
                        color: sel ? selectedColor : AppColors.offWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: sel ? selectedColor : Colors.transparent),
                      ),
                      child: Icon(ic,
                          size: 20,
                          color: sel ? Colors.white : AppColors.burgundy),
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
                  final name = nameCtrl.text.trim();
                  final target = int.tryParse(targetCtrl.text.trim()) ?? 0;
                  if (name.isEmpty || target <= 0) return;
                  appState.addGoal(name, target,
                      icon: selectedIcon,
                      color: selectedColor,
                      deadline: deadline);
                  Navigator.of(ctx).pop();
                },
                child: Text('ACTIVATE SAVINGS PLAN',
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
            ),
          ],
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
        title: Text('TOP UP: ${g.name.toUpperCase()}',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.burgundy)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${appState.currency} ${g.saved} / ${g.target}',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, color: AppColors.gold)),
            const SizedBox(height: 24),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Contribution Amount',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Later', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
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
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          final goals = appState.goals;
          final totalSaved = appState.totalSaved;
          final totalTarget = goals.fold<int>(0, (s, g) => s + g.target);
          final overallPct = totalTarget == 0
              ? 0.0
              : (totalSaved / totalTarget).clamp(0.0, 1.0);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppColors.burgundy,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('SAVINGS VOYAGES',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.5,
                          color: Colors.white)),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.burgundy, AppColors.burgundyDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(28),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('TOTAL ACCUMULATED',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5)),
                          const SizedBox(height: 8),
                          Text(
                            '${appState.currency} ${totalSaved.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  '${(overallPct * 100).toStringAsFixed(1)}% OF TOTAL TARGET',
                                  style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.gold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800)),
                              Text(
                                  'TARGET: ${appState.currency} ${totalTarget}',
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: overallPct,
                              minHeight: 8,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (goals.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome_outlined,
                            size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('No active voyages yet.',
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('Begin your journey today.',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final g = goals[index];
                        final pct = (g.saved / g.target).clamp(0.0, 1.0);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
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
                            border: Border.all(
                                color: AppColors.silver.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                          color: g.color.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(18)),
                                      child: Icon(g.icon,
                                          color: g.color, size: 26),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(g.name.toUpperCase(),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: 0.5,
                                                      fontSize: 15)),
                                          const SizedBox(height: 4),
                                          Text(
                                              'Remaining: ${appState.currency} ${g.target - g.saved}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[500])),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            '${(pct * 100).toStringAsFixed(0)}%',
                                            style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w900,
                                                color: g.color,
                                                fontSize: 20)),
                                        Text('COMPLETE',
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.grey[400],
                                                letterSpacing: 0.5)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 6,
                                    backgroundColor: AppColors.offWhite,
                                    color: g.color,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextButton.icon(
                                        icon: const Icon(Icons.add_rounded,
                                            size: 18),
                                        label: const Text('CONTRIBUTE',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13)),
                                        style: TextButton.styleFrom(
                                          foregroundColor: g.color,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        onPressed: pct >= 1.0
                                            ? null
                                            : () => _deposit(g),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.grey,
                                            size: 20),
                                        onPressed: () =>
                                            appState.deleteGoal(g.id),
                                      ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addGoal,
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text('NEW VOYAGE',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
    );
  }
}
