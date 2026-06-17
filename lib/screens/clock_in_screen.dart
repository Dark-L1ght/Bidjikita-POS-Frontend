import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/shift_provider.dart';
import 'login_screen.dart';
import 'pos_dashboard_screen.dart';

class ClockInScreen extends ConsumerStatefulWidget {
  const ClockInScreen({super.key});

  @override
  ConsumerState<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends ConsumerState<ClockInScreen> {
  late TextEditingController _cashController;
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _cashController = TextEditingController(text: '500000');
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _cashController.dispose();
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _handleClockIn() async {
    final raw = _cashController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cash = int.tryParse(raw) ?? 0;
    if (cash <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uang awal harus lebih dari 0')),
      );
      return;
    }

    final token = ref.read(authProvider).token;
    if (token == null) return;

    await ref.read(shiftProvider.notifier).clockIn(token, cash);

    if (!mounted) return;

    final shiftState = ref.read(shiftProvider);
    if (shiftState.hasActiveShift) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PosDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final shiftState = ref.watch(shiftProvider);
    final userName = auth.user?.fullName.isNotEmpty == true
        ? auth.user!.fullName
        : auth.user?.username ?? 'Kasir';

    return Scaffold(
      backgroundColor: const Color(0xFFEDEBE7),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/bidjikita_logo.jpg',
                width: 96,
                height: 96,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'Selamat Datang, $userName',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formattedTime,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A3C34),
                ),
              ),
              const SizedBox(height: 32),

              // Card
              Container(
                width: 380,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_circle_outline_rounded,
                      size: 48,
                      color: Color(0xFF1A3C34),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mulai Shift',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A3C34),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Starting cash input
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Uang awal di kasir',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cashController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onFieldSubmitted: (_) => _handleClockIn(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A3C34),
                      ),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A3C34),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (shiftState.error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          shiftState.error!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],

                    // Clock in button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: shiftState.isLoading ? null : _handleClockIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3C34),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: shiftState.isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Mulai Shift',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // Logout link
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Keluar',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
