import 'package:flutter/material.dart';
import '../app_state.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Your Name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return ListView(
            children: [
              // ── Profile card ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 0,
                  color: cs.primaryContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: cs.primary,
                          child: Text(
                            appState.userName.isNotEmpty
                                ? appState.userName[0].toUpperCase()
                                : 'G',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: cs.onPrimary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(appState.userName,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onPrimaryContainer)),
                              Text('SavePesa user',
                                  style: TextStyle(
                                      color: cs.onPrimaryContainer.withOpacity(0.6),
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              color: cs.onPrimaryContainer),
                          onPressed: _editName,
                          tooltip: 'Edit name',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Stats ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Transactions',
                        value: '${appState.transactions.length}',
                        icon: Icons.receipt_long,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Goals',
                        value: '${appState.goals.length}',
                        icon: Icons.savings,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Balance',
                        value: '${(appState.balance / 1000).toStringAsFixed(1)}K',
                        icon: Icons.account_balance_wallet,
                        color: appState.balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _SectionHeader('Preferences'),

              // ── Dark mode ─────────────────────────────────────────────────
              SwitchListTile(
                secondary: CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  child: Icon(
                    _darkMode ? Icons.dark_mode : Icons.light_mode,
                    color: cs.onSecondaryContainer,
                  ),
                ),
                title: const Text('Dark Mode'),
                subtitle: Text(_darkMode ? 'Dark theme active' : 'Light theme active'),
                value: _darkMode,
                onChanged: (v) => appState.toggleTheme(v),
              ),

              // ── Currency ──────────────────────────────────────────────────
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  child: Icon(Icons.currency_exchange,
                      color: cs.onSecondaryContainer),
                ),
                title: const Text('Currency'),
                subtitle: Text(appState.currency),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      title: const Text('Select Currency'),
                      children: ['KES', 'USD', 'EUR', 'GBP', 'UGX', 'TZS']
                          .map((c) => SimpleDialogOption(
                                onPressed: () {
                                  appState.setCurrency(c);
                                  Navigator.of(ctx).pop();
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(c,
                                      style: TextStyle(
                                          fontWeight:
                                              appState.currency == c
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          color: appState.currency == c
                                              ? cs.primary
                                              : null)),
                                ),
                              ))
                          .toList(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
              _SectionHeader('About'),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  child: Icon(Icons.info_outline, color: cs.onSecondaryContainer),
                ),
                title: const Text('About SavePesa'),
                subtitle: const Text('Version 1.0.0'),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'SavePesa',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2026 SavePesa',
                  children: const [
                    SizedBox(height: 12),
                    Text('A personal finance app to help you track income, expenses, and savings goals.'),
                  ],
                ),
              ),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  child: Icon(Icons.privacy_tip_outlined,
                      color: cs.onSecondaryContainer),
                ),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  child: Icon(Icons.star_outline, color: cs.onSecondaryContainer),
                ),
                title: const Text('Rate the App'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  'SavePesa v1.0.0 • Made with ❤️ in Kenya',
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurface.withOpacity(0.4)),
                ),
              ),
              const SizedBox(height: 24),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}
