import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_state.dart';
import '../main.dart';
import '../security_service.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();

    _handleNavigation();
  }

  bool _authFailed = false;

  Future<void> _handleNavigation() async {
    print('SplashScreen: Waiting 1.5s delay...');
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    print(
        'SplashScreen: Checking login status... (isLoggedIn: ${appState.isLoggedIn})');
    if (appState.isLoggedIn) {
      if (appState.isBiometricEnabled) {
        print('SplashScreen: Biometric enabled, authenticating...');
        final authenticated = await SecurityService.instance.authenticate();
        print('SplashScreen: Biometric result: $authenticated');
        if (authenticated && mounted) {
          _proceed();
        } else if (mounted) {
          setState(() => _authFailed = true);
        }
      } else {
        _proceed();
      }
    } else {
      _goToLogin();
    }
  }

  void _proceed() {
    print('SplashScreen: Navigating to MainNavigation');
    appState.startAutomation();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  void _goToLogin() {
    print('SplashScreen: Navigating to LoginPage');
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.burgundy, AppColors.burgundyDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo circle
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.savings_outlined,
                          color: Colors.white, size: 48),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'SavePesa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'YOUR FINANCIAL JOURNEY STARTS HERE',
                    style: TextStyle(
                      color: AppColors.gold.withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 60),
                  if (_authFailed)
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _authFailed = false);
                            _handleNavigation();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.burgundy),
                          child: const Text('RETRY BIOMETRICS'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await appState.clearSession();
                            _goToLogin();
                          },
                          child: const Text('ENTER PIN / LOGIN MANUALLY',
                              style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white.withOpacity(0.5),
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
