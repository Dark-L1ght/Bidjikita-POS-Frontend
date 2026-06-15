import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../services/thermal_printer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  List<BluetoothDevice> _btDevices = [];
  String _savedPaperSize = '58';
  String? _savedBtAddr;
  String? _savedHost;
  int _savedPort = 9100;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final addr = await ThermalPrinter.getBluetoothAddress();
    final host = await ThermalPrinter.getPrinterHost();
    final port = await ThermalPrinter.getPrinterPort();
    final paper = await ThermalPrinter.getPaperSize();
    final devices = await ThermalPrinter.getBondedDevices();
    if (mounted) {
      setState(() {
        _savedBtAddr = addr;
        _savedHost = host;
        _savedPort = port;
        _savedPaperSize = paper;
        _btDevices = devices;
        _loading = false;
      });
    }
  }

  Future<void> _selectPaperSize(String size) async {
    await ThermalPrinter.setPaperSize(
      size == '80' ? PaperSize.mm80 : PaperSize.mm58,
    );
    if (mounted) setState(() => _savedPaperSize = size);
  }

  Future<void> _selectBluetooth(String address) async {
    await ThermalPrinter.saveBluetoothPrinter(address);
    await ThermalPrinter.clearNetworkPrinter();
    if (mounted) {
      setState(() {
        _savedBtAddr = address;
        _savedHost = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printer Bluetooth disimpan')),
      );
    }
  }

  Future<void> _saveNetworkPrinter(String host, int port) async {
    await ThermalPrinter.saveNetworkPrinter(host, port);
    await ThermalPrinter.clearBluetoothPrinter();
    if (mounted) {
      setState(() {
        _savedHost = host;
        _savedPort = port;
        _savedBtAddr = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printer jaringan disimpan')),
      );
    }
  }

  Future<void> _clearPrinter() async {
    await ThermalPrinter.clearPrinter();
    if (mounted) {
      setState(() {
        _savedBtAddr = null;
        _savedHost = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaturan printer dihapus')),
      );
    }
  }

  void _showNetworkDialog() {
    final hostCtl = TextEditingController(text: _savedHost ?? '');
    final portCtl = TextEditingController(text: _savedPort.toString());
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Printer Jaringan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hostCtl,
              decoration: const InputDecoration(
                hintText: '192.168.1.100',
                labelText: 'Alamat IP',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: portCtl,
              decoration: const InputDecoration(
                hintText: '9100',
                labelText: 'Port',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
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
            onPressed: () {
              final host = hostCtl.text.trim();
              final port = int.tryParse(portCtl.text) ?? 9100;
              if (host.isNotEmpty) {
                Navigator.pop(c);
                _saveNetworkPrinter(host, port);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _testPrint() async {
    setState(() => _loading = true);
    final ok = await ThermalPrinter.testBluetoothConnection();
    if (mounted) {
      setState(() => _loading = false);
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Tes Printer'),
          content: Text(
            ok
                ? 'Koneksi printer berhasil.'
                : 'Koneksi printer gagal. Pastikan printer menyala dan sudah dipasangkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: Color(0xFF04291A),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Printer Status Card ──
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status Printer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_savedBtAddr != null)
                          _buildInfoRow(
                            Icons.bluetooth,
                            'Bluetooth',
                            _savedBtAddr!,
                          )
                        else if (_savedHost != null)
                          _buildInfoRow(
                            Icons.wifi,
                            'Jaringan',
                            '$_savedHost:$_savedPort',
                          )
                        else
                          Text(
                            'Belum ada printer yang dikonfigurasi',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Paper Size ──
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ukuran Kertas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('58mm'),
                              selected: _savedPaperSize == '58',
                              onSelected: (_) => _selectPaperSize('58'),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('80mm'),
                              selected: _savedPaperSize == '80',
                              onSelected: (_) => _selectPaperSize('80'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Bluetooth Devices ──
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Perangkat Bluetooth',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              onPressed: _loadSettings,
                              icon: const Icon(Icons.refresh, size: 18),
                              tooltip: 'Segarkan',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (_btDevices.isEmpty)
                          Text(
                            'Tidak ada perangkat Bluetooth yang dipasangkan',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          )
                        else
                          ..._btDevices.map(
                            (d) => ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.bluetooth,
                                size: 20,
                                color: d.address == _savedBtAddr
                                    ? const Color(0xFF04291A)
                                    : Colors.grey,
                              ),
                              title: Text(
                                d.name ?? '(tidak ada nama)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: d.address == _savedBtAddr
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                d.address,
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: d.address == _savedBtAddr
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF04291A),
                                      size: 18,
                                    )
                                  : null,
                              onTap: () => _selectBluetooth(d.address),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Network Printer ──
                  _buildCard(
                    child: InkWell(
                      onTap: _showNetworkDialog,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.wifi, size: 20, color: Colors.grey[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Printer Jaringan (WiFi)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _savedHost != null
                                        ? '$_savedHost:$_savedPort'
                                        : 'Ketuk untuk mengatur',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Actions ──
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _testPrint,
                          icon: const Icon(Icons.print_outlined, size: 18),
                          label: const Text('Tes Koneksi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF04291A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _clearPrinter,
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Hapus Pengaturan Printer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red[400],
                            side: BorderSide(color: Colors.red[200]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF04291A)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
