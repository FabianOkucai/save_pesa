import 'package:flutter/material.dart';
import '../app_state.dart';
import '../theme.dart';
import '../main.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final _amountCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _proceed({bool skip = false}) async {
    if (!skip) {
      final raw = _amountCtrl.text.trim().replaceAll(',', '');
      final amount = int.tryParse(raw);
      if (amount == null || amount <= 0) {
        setState(() => _error = 'Enter a valid amount');
        return;
      }
      setState(() {
        _loading = true;
        _error = null;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      appState.addTransaction('Opening Balance', amount, TxCategory.salary,
          note: 'Initial deposit');
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavigation(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // ── Welcome banner ─────────────────────────────────────────
                  Container(
                    width: double.infinity,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.waving_hand,
                            color: AppColors.gold, size: 36),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome, ${appState.userName}!',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Your account is ready. Let\'s set up your starting balance.',
                          style: TextStyle(
                              fontSize: 13, color: Colors.white70, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // ── Prompt ─────────────────────────────────────────────────
                  const Text(
                    'How much money do you currently have?',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkGrey,
                        height: 1.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will be recorded as your opening balance.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 28),

                  // ── Amount field ───────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _error != null
                            ? AppColors.error
                            : AppColors.silver.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          decoration: BoxDecoration(
                            color: AppColors.burgundy.withOpacity(0.06),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            appState.currency,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.burgundy,
                                fontSize: 15),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 18),
                            onChanged: (_) => setState(() => _error = null),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                  color: Colors.grey[300],
                                  fontWeight: FontWeight.w400),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!,
                        style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 32),

                  // ── Continue button ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : () => _proceed(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.burgundy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('SET MY BALANCE',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Skip ───────────────────────────────────────────────────
                  Center(
                    child: TextButton(
                      onPressed: () => _proceed(skip: true),
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
