import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/network_provider.dart';
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
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get _formattedDateTime {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    return '${_days[_now.weekday - 1]}, ${_now.day} ${_months[_now.month - 1]} ${_now.year} · $h:$m';
  }

  @override
  void initState() {
    super.initState();
    // Update every minute; also refresh on the next exact minute boundary.
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

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(isConnectedProvider);

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
            // ── Logo & brand ───────────────────────────────────────────────
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

            // ── Menu / Dashboard tab toggle ────────────────────────────────
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

            // ── Date / time ────────────────────────────────────────────────
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

            // ── Refresh ────────────────────────────────────────────────────
            _PillButton(
              onTap: () => setState(() => _now = DateTime.now()),
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

            // ── Network indicator ──────────────────────────────────────────
            _Pill(
              child: Icon(
                isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                size: 17,
                color: isConnected ? const Color(0xFF04291A) : Colors.red[400],
              ),
            ),
            const SizedBox(width: 8),

            // ── Notifications ──────────────────────────────────────────────
            _PillButton(
              onTap: () {},
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 17,
                color: Colors.black54,
              ),
            ),
            const SizedBox(width: 8),

            // ── Profile ────────────────────────────────────────────────────
            _PillButton(
              onTap: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 17,
                    color: Colors.black54,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Nabil',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 15,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),

      // ── Split-screen body ────────────────────────────────────────────────
      body: const Row(
        children: [
          Expanded(flex: 3, child: CatalogPanel()),
          Expanded(flex: 1, child: CartPanel()),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared AppBar pill widgets
// ──────────────────────────────────────────────────────────────────────────────

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
