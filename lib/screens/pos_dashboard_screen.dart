import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/network_provider.dart';
import '../providers/product_provider.dart';
import '../providers/shift_provider.dart';
import '../screens/clock_in_screen.dart';
import '../screens/login_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/cart_panel.dart';
import '../widgets/catalog_panel.dart';
import '../widgets/shift_dashboard.dart';

enum _PosTab { menu, dashboard }

class PosDashboardScreen extends ConsumerStatefulWidget {
  const PosDashboardScreen({super.key});

  @override
  ConsumerState<PosDashboardScreen> createState() => _PosDashboardScreenState();
}

class _PosDashboardScreenState extends ConsumerState<PosDashboardScreen> {
  Timer? _initialTimer;
  Timer? _clockTimer;
  DateTime _now = DateTime.now();
  _PosTab _selectedTab = _PosTab.menu;

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
    return '${_days[_now.weekday - 1]}, ${_now.day} '
        '${_months[_now.month - 1]} ${_now.year} · $h:$m';
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
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
    final shiftState = ref.watch(shiftProvider);
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
            // ── Logo & brand ─────────────────────────────────────────
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

            // ── Menu / Dashboard tab toggle ──────────────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _TabChip(
                    label: 'Menu',
                    selected: _selectedTab == _PosTab.menu,
                    onTap: () => setState(() => _selectedTab = _PosTab.menu),
                  ),
                  _TabChip(
                    label: 'Dashboard',
                    selected: _selectedTab == _PosTab.dashboard,
                    onTap: () {
                      setState(() => _selectedTab = _PosTab.dashboard);
                      _refreshShift();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── Shift indicator ─────────────────────────────────────
            if (shiftState.hasActiveShift)
              _Pill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle,
                      size: 13,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Shift · ${shiftState.activeShift!.startTime.hour.toString().padLeft(2, '0')}:${shiftState.activeShift!.startTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),

            // ── Date / time ──────────────────────────────────────────
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

            // ── Refresh products ─────────────────────────────────────
            _PillButton(
              onTap: () {
                setState(() => _now = DateTime.now());
                ref.read(productListProvider.notifier).refresh();
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

            // ── Network indicator ────────────────────────────────────
            _Pill(
              child: Icon(
                isConnected ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                size: 17,
                color: isConnected ? const Color(0xFF04291A) : Colors.red[400],
              ),
            ),
            const SizedBox(width: 8),

            // ── Profile / dropdown ───────────────────────────────────
            PopupMenuButton<_ProfileAction>(
              offset: const Offset(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              onSelected: (action) {
                if (action == _ProfileAction.settings) {
                  _openPrinterSettings();
                } else if (action == _ProfileAction.logout) {
                  _confirmLogout();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem<_ProfileAction>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        auth.user?.roleName ?? '',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<_ProfileAction>(
                  value: _ProfileAction.settings,
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 10),
                      const Text('Pengaturan'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<_ProfileAction>(
                  value: _ProfileAction.logout,
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: Colors.red[600],
                      ),
                      const SizedBox(width: 10),
                      const Text('Keluar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5F0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF04291A).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_circle_outlined,
                      size: 17,
                      color: Color(0xFF04291A),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF04291A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 15,
                      color: Color(0xFF04291A),
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
      body: _selectedTab == _PosTab.menu
          ? const Row(
              children: [
                Expanded(flex: 3, child: CatalogPanel()),
                Expanded(flex: 1, child: CartPanel()),
              ],
            )
          : ShiftDashboard(onEndShift: () => _showClockOutDialog(context)),
    );
  }

  void _refreshShift() {
    final token = ref.read(authProvider).token;
    if (token != null) {
      ref.read(shiftProvider.notifier).checkActive(token);
    }
  }

  void _openPrinterSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  // ── Clock out confirmation → reconciliation dialog ─────────────────
  void _showClockOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Akhiri Shift',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Yakin ingin mengakhiri shift?\nPastikan semua transaksi sudah selesai.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const _ClockOutDialog(),
              );
            },
            child: const Text('Ya, Akhiri'),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Tab chip for Menu/Dashboard toggle
// ──────────────────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF04291A) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Clock Out dialog
// ──────────────────────────────────────────────────────────────────────────

enum _FocusedField { cash, qris }

class _ClockOutDialog extends ConsumerStatefulWidget {
  const _ClockOutDialog();

  @override
  ConsumerState<_ClockOutDialog> createState() => _ClockOutDialogState();
}

class _ClockOutDialogState extends ConsumerState<_ClockOutDialog> {
  late TextEditingController _cashController;
  late TextEditingController _qrisController;
  bool _isLoading = false;
  _FocusedField _focusedField = _FocusedField.cash;

  @override
  void initState() {
    super.initState();
    final shift = ref.read(shiftProvider).activeShift;
    _cashController = TextEditingController(
      text: shift?.expectedCash.toString() ?? '0',
    );
    _qrisController = TextEditingController(
      text: shift?.expectedQris.toString() ?? '0',
    );
    _cashController.addListener(() => setState(() {}));
    _qrisController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cashController.dispose();
    _qrisController.dispose();
    super.dispose();
  }

  int _parseCash() =>
      int.tryParse(_cashController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  int _parseQris() =>
      int.tryParse(_qrisController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  TextEditingController get _activeCtrl =>
      _focusedField == _FocusedField.cash ? _cashController : _qrisController;

  void _pressDigit(int digit) {
    final ctrl = _activeCtrl;
    final raw = ctrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    ctrl.text = '$raw$digit';
    ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
  }

  void _pressBackspace() {
    final ctrl = _activeCtrl;
    final raw = ctrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return;
    ctrl.text = raw.substring(0, raw.length - 1);
    ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
  }

  void _press000() {
    final ctrl = _activeCtrl;
    final raw = ctrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    ctrl.text = '${raw}000';
    ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
  }

  Future<void> _handleClockOut() async {
    final shift = ref.read(shiftProvider).activeShift;
    if (shift == null) return;

    final token = ref.read(authProvider).token;
    if (token == null) return;

    setState(() => _isLoading = true);
    await ref
        .read(shiftProvider.notifier)
        .clockOut(token, actualCash: _parseCash(), actualQris: _parseQris());

    if (!mounted) return;
    setState(() => _isLoading = false);

    final state = ref.read(shiftProvider);
    if (!state.hasActiveShift) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ClockInScreen()),
      );
    }
  }

  String _formatRupiah(int amount) {
    if (amount == 0) return 'Rp 0';
    final sign = amount < 0 ? '-' : '';
    final str = amount.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    return '$sign Rp $buf';
  }

  @override
  Widget build(BuildContext context) {
    final shift = ref.watch(shiftProvider).activeShift;
    if (shift == null) return const SizedBox.shrink();

    final actualCash = _parseCash();
    final actualQris = _parseQris();
    final salesCash = shift.expectedCash - shift.startingCash;
    final expectedCash = shift.expectedCash;
    final expectedQris = shift.expectedQris;

    String fmt(int v) => _formatRupiah(v);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 180, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.stop_circle_outlined,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Ringkasan Shift',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black54,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _sectionDivider('Tunai'),
              _cashRow(
                'Di kasir saat ini:',
                child: _focusField(
                  value: fmt(actualCash),
                  focused: _focusedField == _FocusedField.cash,
                  onTap: () =>
                      setState(() => _focusedField = _FocusedField.cash),
                ),
              ),
              _labelRow('Uang awal:', fmt(shift.startingCash)),
              _labelRow('Penjualan tunai:', fmt(salesCash)),
              _labelRow('Seharusnya:', fmt(expectedCash)),
              _matchRow(expectedCash, actualCash),
              const SizedBox(height: 12),

              _sectionDivider('QRIS'),
              _cashRow(
                'Di aplikasi QRIS:',
                child: _focusField(
                  value: fmt(actualQris),
                  focused: _focusedField == _FocusedField.qris,
                  onTap: () =>
                      setState(() => _focusedField = _FocusedField.qris),
                ),
              ),
              _labelRow('Penjualan QRIS:', fmt(expectedQris)),
              _matchRow(expectedQris, actualQris),
              const SizedBox(height: 12),

              _buildNumpad(),

              if (ref.watch(shiftProvider).error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    ref.watch(shiftProvider).error!,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _handleClockOut,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.stop_circle_outlined, size: 18),
                  label: Text(
                    _isLoading ? 'Memproses...' : 'Akhiri Shift',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['000', '0', '\u232B'],
    ];
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: row.map((key) {
                final digit = int.tryParse(key);
                final isBackspace = key == '\u232B';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Material(
                      color: isBackspace
                          ? Colors.red[50]
                          : const Color(0xFFF1F3F2),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (digit != null) {
                            _pressDigit(digit);
                          } else if (isBackspace) {
                            _pressBackspace();
                          } else if (key == '000') {
                            _press000();
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            key,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isBackspace
                                  ? Colors.red[700]
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _focusField({
    required String value,
    required bool focused,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: focused ? const Color(0xFFEBF5F0) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: focused ? const Color(0xFF04291A) : Colors.grey[300]!,
            width: focused ? 1.5 : 1,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: focused ? const Color(0xFF04291A) : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _sectionDivider(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF04291A),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(height: 1, color: Color(0xFF04291A))),
        ],
      ),
    );
  }

  Widget _cashRow(String label, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          const SizedBox(width: 12),
          SizedBox(width: 220, child: child),
        ],
      ),
    );
  }

  Widget _labelRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _matchRow(int expected, int actual) {
    final match = expected == actual;
    final diff = actual - expected;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            match ? Icons.check_circle : Icons.error_outline,
            size: 16,
            color: match ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            match ? 'Sesuai' : 'Selisih ${_formatRupiah(diff)}',
            style: TextStyle(
              fontSize: 12,
              color: match ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Profile dropdown action enum
// ──────────────────────────────────────────────────────────────────────────

enum _ProfileAction { settings, logout }

// ──────────────────────────────────────────────────────────────────────────
// Shared AppBar pill widgets
// ──────────────────────────────────────────────────────────────────────────

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
