import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool get _darkMode => appState.themeMode == ThemeMode.dark;

  void _editName() {
    final ctrl = TextEditingController(text: appState.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('UPDATE PROFILE',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: AppColors.burgundy)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: 'Your Name',
            prefixIcon:
                const Icon(Icons.person_outline, color: AppColors.burgundy),
            filled: true,
            fillColor: AppColors.offWhite,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                foregroundColor: Colors.white),
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) appState.setUserName(name);
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('PROFILE & SETTINGS',
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5)),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return ListView(
            children: [
              // ── Premium Profile Card ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.burgundy, AppColors.burgundyDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            appState.userName.isNotEmpty
                                ? appState.userName[0].toUpperCase()
                                : 'G',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appState.userName,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(appState.phone,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            const Text('SAVEPESA MEMBER',
                                style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _editName,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.edit_outlined,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Quick Stats ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatChip(
                        label: 'Transactions',
                        value: '${appState.transactions.length}',
                        icon: Icons.receipt_long_outlined),
                    const SizedBox(width: 12),
                    _StatChip(
                        label: 'Goals',
                        value: '${appState.goals.length}',
                        icon: Icons.flight_takeoff_outlined),
                    const SizedBox(width: 12),
                    _StatChip(
                      label: 'Balance',
                      value: '${(appState.balance / 1000).toStringAsFixed(1)}K',
                      icon: Icons.account_balance_wallet_outlined,
                      highlight: appState.balance >= 0,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              _SectionHeader('PREFERENCES'),
              const SizedBox(height: 8),

              // ── Dark mode ─────────────────────────────────────────────────
              _SettingsTile(
                icon: _darkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: 'Appearance',
                subtitle: _darkMode ? 'Dark Mode' : 'Light Mode',
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (v) => appState.toggleTheme(v),
                  activeColor: AppColors.burgundy,
                ),
              ),

              // ── Currency ──────────────────────────────────────────────────
              _SettingsTile(
                icon: Icons.currency_exchange_outlined,
                title: 'Currency',
                subtitle: appState.currency,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                      title: const Text('SELECT CURRENCY',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: AppColors.burgundy)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            ['KES', 'USD', 'EUR', 'GBP', 'UGX', 'TZS'].map((c) {
                          final selected = appState.currency == c;
                          return GestureDetector(
                            onTap: () {
                              appState.setCurrency(c);
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.burgundy
                                    : AppColors.offWhite,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(c,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: selected
                                              ? Colors.white
                                              : AppColors.darkGrey)),
                                  if (selected)
                                    const Icon(Icons.check,
                                        color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              _SectionHeader('ABOUT'),
              const SizedBox(height: 8),

              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About SavePesa',
                subtitle: 'Version 1.0.0',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'SavePesa',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2026 SavePesa',
                  children: const [
                    SizedBox(height: 12),
                    Text(
                        'A personal finance app to help you track income, expenses, and savings goals.'),
                  ],
                ),
              ),

              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),

              _SettingsTile(
                icon: Icons.star_outline,
                title: 'Rate the App',
                onTap: () {},
              ),

              const SizedBox(height: 16),
              // ── Logout ────────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.logout,
                        color: AppColors.error, size: 20),
                  ),
                  title: const Text('Sign Out',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.error)),
                  subtitle: const Text('You will need to sign in again',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing:
                      const Icon(Icons.chevron_right, color: AppColors.error),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        title: const Text('Sign Out?',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkGrey)),
                        content: const Text(
                            'Are you sure you want to sign out of SavePesa?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white),
                            onPressed: () {
                              Navigator.pop(ctx);
                              appState.logout();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                                (_) => false,
                              );
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.burgundy.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('SavePesa v1.0.0',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.burgundy,
                              letterSpacing: 1)),
                    ),
                    const SizedBox(height: 8),
                    const Text('Made with ❤️ in Kenya',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 14,
              decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppColors.burgundy)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile(
      {required this.icon,
      required this.title,
      this.subtitle,
      this.trailing,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.silver.withOpacity(0.4)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.burgundy.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.burgundy, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.darkGrey)),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]))
            : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right, color: Colors.grey)
                : null),
        onTap: onTap,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _StatChip(
      {required this.label,
      required this.value,
      required this.icon,
      this.highlight = true});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.silver.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.burgundy, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.burgundy)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
