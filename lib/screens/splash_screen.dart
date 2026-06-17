import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/shift_provider.dart';
import 'clock_in_screen.dart';
import 'pos_dashboard_screen.dart';

/// Checks for an active shift after login, then routes to the right screen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _checkShift());
  }

  Future<void> _checkShift() async {
    final token = ref.read(authProvider).token;
    if (token == null) return;

    await ref.read(shiftProvider.notifier).checkActive(token);

    if (!mounted) return;

    final shiftState = ref.read(shiftProvider);
    if (shiftState.hasActiveShift) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PosDashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClockInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFF04291A))),
    );
  }
}
