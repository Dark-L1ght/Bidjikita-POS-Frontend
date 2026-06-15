import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/network_provider.dart';
import '../providers/product_provider.dart';
import '../screens/login_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/catalog_panel.dart';
import '../widgets/cart_panel.dart';

class PosDashboardScreen extends ConsumerStatefulWidget {
  const PosDashboardScreen({super.key});

  @override
  ConsumerState<PosDashboardScreen> createState() => _PosDashboardScreenState();
}

class _PosDashboardScreenState extends ConsumerState<PosDashboardScreen> {
  Timer? _initialTimer;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  static const _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agt',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  String get _formattedDateTime {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    return '${_days[_now.weekday - 1]}, ${_now.day} ${_months[_now.month - 1]} ${_now.year} · $h:$m';
  }

  @override
  void initState() {
    super.initState();
    _scheduleClockUpdate();
  }

  void _scheduleClockUpdate() {
    final secondsUntilNextMinute = 60 - DateTime.now().second;
    _initialTimer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (mounted) setState(() => _now = DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _initialTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Yakin ingin keluar dari sesi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF04291A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const LoginScreen(),
                    transitionDuration: const Duration(milliseconds: 400),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                  ),
                  (_) => false,
                );
              }
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(isConnectedProvider);
    final auth = ref.watch(authProvider);
    final userName = auth.user?.fullName.isNotEmpty == true
        ? auth.user!.fullName
        : auth.user?.username ?? 'Kasir';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        title: Row(
          children: [
            // ── Logo & brand ─────────────────────────────────────────────
            const Icon(Icons.eco, color: Color(0xFF04291A)),
            const SizedBox(width: 8),
            const Text(
              'Bidjikita Coffee Roastery',
              style: TextStyle(
                color: Color(0xFF04291A),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(),

            // ── Menu / Dashboard tab toggle ───────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF04291A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Dashboard',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // ── Date / time ───────────────────────────────────────────────
            _Pill(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _formattedDateTime,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Refresh products ──────────────────────────────────────────
            _PillButton(
              onTap: () {
                setState(() => _now = DateTime.now());
                ref.read(productListProvider.notifier).refresh();
                ref.invalidate(categoryListProvider);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 15, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'Refresh',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Network indicator ─────────────────────────────────────────
            _Pill(
              child: Icon(
                isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                size: 17,
                color: isConnected ? const Color(0xFF04291A) : Colors.red[400],
              ),
            ),
            const SizedBox(width: 8),

            // Profile / dropdown
            PopupMenuButton<_ProfileAction>(
              offset: const Offset(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              onSelected: (action) {
                if (action == _ProfileAction.logout) {
                  _confirmLogout();
                } else if (action == _ProfileAction.settings) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem<_ProfileAction>(
                  enabled: false,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF04291A),
                        child: Text(
                          userName.isNotEmpty
                              ? userName.characters.first.toUpperCase()
                              : 'K',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            if ((auth.user?.roleName ?? '').isNotEmpty)
                              Text(
                                auth.user!.roleName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem<_ProfileAction>(
                  enabled: false,
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem<_ProfileAction>(
                  value: _ProfileAction.settings,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Pengaturan',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                PopupMenuItem<_ProfileAction>(
                  value: _ProfileAction.logout,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: Colors.red[400],
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: _Pill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_circle_outlined,
                      size: 17,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 15,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    try {
      return const Row(
        children: [
          Expanded(flex: 3, child: CatalogPanel()),
          Expanded(flex: 1, child: CartPanel()),
        ],
      );
    } catch (_) {
      return const Center(
        child: Text(
          'Terjadi kesalahan. Silakan muat ulang.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ────────────────────────────────────────────────────────────
// Profile dropdown action enum
// ────────────────────────────────────────────────────────────

enum _ProfileAction { settings, logout }

// Shared AppBar pill widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final Widget child;
  const _Pill({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: child,
    );
  }
}

class _PillButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PillButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: child,
      ),
    );
  }
}
