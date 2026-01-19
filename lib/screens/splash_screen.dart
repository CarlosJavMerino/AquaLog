import 'package:flutter/material.dart';

/// A simple loading screen displayed while the application initializes.
///
/// This screen is rendered during the [AuthStatus.unknown] state,
/// typically while Firebase Auth is checking the user's session token 
/// or while essential dependencies are being injected.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  /// Static route generator for navigation consistency.
  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SplashScreen());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}