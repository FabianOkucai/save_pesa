import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class SecurityService {
  static final SecurityService instance = SecurityService._init();
  SecurityService._init();

  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    try {
      return await auth.canCheckBiometrics || await auth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    final bool canAuthenticateWithBiometrics = await canCheckBiometrics();
    if (!canAuthenticateWithBiometrics)
      return true; // Fallback if no biometrics

    try {
      return await auth.authenticate(
        localizedReason: 'Please authenticate to access SavePesa',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}
