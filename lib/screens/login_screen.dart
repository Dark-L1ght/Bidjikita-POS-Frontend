import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import 'splash_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static const Color _brandColor = Color(0xFF04291A);
  static const Color _backgroundColor = Color(0xFFEDEBE7);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username dan kata sandi wajib diisi')),
      );
      return;
    }

    await ref.read(authProvider.notifier).login(username, password);

    if (!mounted) return;

    final auth = ref.read(authProvider);
    if (auth.isLoggedIn) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SplashScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/login_bg.png', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildCard(auth)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(AuthState auth) {
    return Container(
      width: 340,
      padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          const SizedBox(height: 8),
          Text(
            'Point Of Sale System',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          _buildUsernameField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          if (auth.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 16, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      auth.error!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildLoginButton(auth),
          const SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/bidjikita_logo.jpg',
      width: 128,
      height: 128,
      fit: BoxFit.contain,
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.grey[800],
          ),
          decoration: InputDecoration(
            hintText: 'Masukkan username',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                Icons.person_outline_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
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
              borderSide: const BorderSide(color: _brandColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kata Sandi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onFieldSubmitted: (_) => _handleLogin(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.grey[800],
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey[400],
              fontSize: 18,
              letterSpacing: 2,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                Icons.lock_outline_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
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
              borderSide: const BorderSide(color: _brandColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AuthState auth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: auth.isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: auth.isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Masuk',
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
    );
  }

  Widget _buildFooter() {
    return Text(
      '© 2026 Bidjikita Coffee Roastery. Semua Hak Dilindungi.',
      textAlign: TextAlign.center,
      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey[500]),
    );
  }
}
