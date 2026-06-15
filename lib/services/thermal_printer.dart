import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/receipt.dart';
import '../utils/currency.dart';

class ThermalPrinter {
  ThermalPrinter._();

  static const String _hostKey = 'printer_host';
  static const String _portKey = 'printer_port';
  static const String _btKey = 'printer_bt_address';
  static const String _paperKey = 'paper_size';
  static const int _defaultPort = 9100;

  static String? _cachedHost;
  static int _cachedPort = _defaultPort;
  static String? _cachedBtAddress;
  static PaperSize _paperSize = PaperSize.mm58;

  static Future<void> setPaperSize(PaperSize size) async {
    _paperSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paperKey, size == PaperSize.mm58 ? '58' : '80');
  }

  static Future<void> _loadPaperSize() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_paperKey);
    _paperSize = val == '80' ? PaperSize.mm80 : PaperSize.mm58;
  }

  static Future<String> getPaperSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_paperKey) ?? '58';
  }

  static Future<void> saveNetworkPrinter(String host, int port) async {
    _cachedHost = host;
    _cachedPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hostKey, host);
    await prefs.setInt(_portKey, port);
  }

  static Future<void> saveBluetoothPrinter(String address) async {
    _cachedBtAddress = address;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_btKey, address);
  }

  static Future<String?> getPrinterHost() async {
    if (_cachedHost != null) return _cachedHost;
    final prefs = await SharedPreferences.getInstance();
    _cachedHost = prefs.getString(_hostKey);
    _cachedPort = prefs.getInt(_portKey) ?? _defaultPort;
    return _cachedHost;
  }

  static Future<int> getPrinterPort() async {
    if (_cachedHost == null) await getPrinterHost();
    return _cachedPort;
  }

  static Future<String?> getBluetoothAddress() async {
    if (_cachedBtAddress != null) return _cachedBtAddress;
    final prefs = await SharedPreferences.getInstance();
    _cachedBtAddress = prefs.getString(_btKey);
    return _cachedBtAddress;
  }

  /// Requests Bluetooth permission (required on Android 12+).
  /// Returns true if granted or already granted.
  static Future<bool> requestBluetoothPermission() async {
    final connect = await Permission.bluetoothConnect.request();
    if (!connect.isGranted) {
      // Fallback for Android < 12
      final location = await Permission.locationWhenInUse.request();
      return location.isGranted;
    }
    // Android 12+ may also need BLUETOOTH_SCAN for some bonded operations.
    final scan = await Permission.bluetoothScan.request();
    return scan.isGranted || connect.isGranted;
  }

  static Future<List<BluetoothDevice>> getBondedDevices() async {
    final hasPerm = await requestBluetoothPermission();
    if (!hasPerm) return [];
    try {
      return await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearPrinter() async {
    _cachedHost = null;
    _cachedBtAddress = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hostKey);
    await prefs.remove(_portKey);
    await prefs.remove(_btKey);
  }

  static Future<void> clearNetworkPrinter() async {
    _cachedHost = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hostKey);
    await prefs.remove(_portKey);
  }

  static Future<void> clearBluetoothPrinter() async {
    _cachedBtAddress = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_btKey);
  }

  /// Prints to Bluetooth printer. Returns true on success.
  static Future<bool> _printBluetooth(ReceiptData receipt) async {
    final address = await getBluetoothAddress();
    if (address == null) {
      log('ThermalPrinter: no BT address saved');
      return false;
    }
    try {
      final bytes = await _buildEscPos(receipt);
      log('ThermalPrinter: connecting to $address ...');
      final conn = await BluetoothConnection.toAddress(
        address,
      ).timeout(const Duration(seconds: 8));
      if (!conn.isConnected) {
        log('ThermalPrinter: connection failed (not connected)');
        return false;
      }
      log('ThermalPrinter: connected, sending ${bytes.length} bytes');
      conn.output.add(Uint8List.fromList(bytes));
      await conn.output.allSent;
      await Future.delayed(const Duration(milliseconds: 500));
      await conn.finish();
      log('ThermalPrinter: done');
      return true;
    } on TimeoutException catch (e) {
      log('ThermalPrinter: connection timed out — $e');
      return false;
    } catch (e, st) {
      log('ThermalPrinter: BT print error — $e', stackTrace: st);
      return false;
    }
  }

  /// Tests whether the saved Bluetooth printer is reachable.
  static Future<bool> testBluetoothConnection() async {
    final address = await getBluetoothAddress();
    if (address == null) return false;
    try {
      final conn = await BluetoothConnection.toAddress(
        address,
      ).timeout(const Duration(seconds: 5));
      final ok = conn.isConnected;
      if (ok) await conn.finish();
      return ok;
    } catch (_) {
      return false;
    }
  }

  /// Prints to network printer via TCP socket. Returns true on success.
  static Future<bool> _printNetwork(ReceiptData receipt) async {
    final host = await getPrinterHost();
    if (host == null || host.isEmpty) return false;
    final port = await getPrinterPort();
    try {
      final bytes = await _buildEscPos(receipt);
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      await Future.delayed(const Duration(milliseconds: 500));
      await socket.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Tries Bluetooth first, then network. Returns true if any succeeds.
  static Future<bool> print(ReceiptData receipt) async {
    final hasBt = await getBluetoothAddress() != null;
    if (hasBt) {
      final ok = await _printBluetooth(receipt);
      if (ok) return true;
    }
    return _printNetwork(receipt);
  }

  /// Generates ESC/POS byte sequence.
  static Future<List<int>> _buildEscPos(ReceiptData r) async {
    await _loadPaperSize();
    final generator = await Generator(
      _paperSize,
      await CapabilityProfile.load(),
    );

    final bytes = <int>[];

    void add(List<int> chunk) => bytes.addAll(chunk);

    // ── Logo ──
    try {
      final logoData = await rootBundle.load(
        'assets/images/bidjikita_logo.jpg',
      );
      final logoImg = img.decodeImage(logoData.buffer.asUint8List());
      if (logoImg != null) {
        final maxW = _paperSize == PaperSize.mm58 ? 200 : 280;
        final resized = img.copyResize(logoImg, width: maxW);
        final cropped = _cropBlankMargins(resized);
        add(generator.image(cropped));
      }
    } catch (_) {
      // Logo not available
    }

    // ── Header (text fallback) ──
    add(
      generator.text(
        'COFFEE ROASTERY',
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    add(
      generator.text(
        'Jl. Logam No.36, Kujangsari, Bandung',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
    );
    add(generator.hr());

    // ── Order info ──
    add(
      generator.row([
        PosColumn(text: 'No. Pesanan', width: 6),
        PosColumn(
          text: r.orderId,
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );
    add(
      generator.row([
        PosColumn(text: 'Tanggal', width: 6),
        PosColumn(
          text: _fmtDate(r.dateTime),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );
    if (r.customerName.isNotEmpty) {
      add(
        generator.row([
          PosColumn(text: 'Pelanggan', width: 6),
          PosColumn(
            text: r.customerName,
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }
    add(
      generator.row([
        PosColumn(text: 'Kasir', width: 6),
        PosColumn(
          text: r.cashierName,
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );
    add(
      generator.row([
        PosColumn(text: 'Tipe', width: 6),
        PosColumn(
          text: r.orderType,
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );
    add(generator.hr());

    // ── Items ──
    add(
      generator.row([
        PosColumn(text: 'Menu', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(
          text: 'Jml',
          width: 2,
          styles: const PosStyles(bold: true, align: PosAlign.center),
        ),
        PosColumn(
          text: 'Harga',
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]),
    );
    add(generator.hr(ch: '-'));

    for (final item in r.items) {
      if (item.bundleSubItems.isNotEmpty) {
        add(
          generator.row([
            PosColumn(text: item.product.name, width: 6),
            PosColumn(
              text: '${item.quantity}x',
              width: 2,
              styles: const PosStyles(align: PosAlign.center),
            ),
            PosColumn(
              text: formatRupiah(item.subtotal),
              width: 4,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]),
        );
        for (final sub in item.bundleSubItems) {
          final vt =
              sub.variantName != null && sub.variantName != sub.productName
              ? ' - ${sub.variantName}'
              : '';
          add(
            generator.text(
              '  ${sub.productName}$vt x${sub.quantity}',
              styles: const PosStyles(
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              ),
            ),
          );
        }
        if (item.note.isNotEmpty) {
          add(
            generator.text(
              '  Catatan: ${item.note}',
              styles: const PosStyles(
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              ),
            ),
          );
        }
      } else {
        add(
          generator.row([
            PosColumn(text: item.product.name, width: 6),
            PosColumn(
              text: '${item.quantity}x',
              width: 2,
              styles: const PosStyles(align: PosAlign.center),
            ),
            PosColumn(
              text: formatRupiah(item.subtotal),
              width: 4,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]),
        );
        if (item.size != 'Regular' || item.sugarLevel.isNotEmpty) {
          final info = <String>[];
          if (item.size != 'Regular') info.add(item.size);
          if (item.sugarLevel.isNotEmpty) info.add(item.sugarLevel);
          add(
            generator.text(
              '  ${info.join(' - ')}',
              styles: const PosStyles(
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              ),
            ),
          );
        }
        if (item.note.isNotEmpty) {
          add(
            generator.text(
              '  Catatan: ${item.note}',
              styles: const PosStyles(
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              ),
            ),
          );
        }
      }
    }

    add(generator.hr());
    add(generator.emptyLines(1));

    // ── Totals ──
    add(
      generator.row([
        PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
        PosColumn(
          text: formatRupiah(r.total),
          width: 6,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]),
    );
    add(generator.hr());
    add(
      generator.row([
        PosColumn(text: 'Pembayaran', width: 6),
        PosColumn(
          text: r.paymentMethod,
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    );
    if (r.paymentMethod == 'Tunai') {
      add(
        generator.row([
          PosColumn(text: 'Diterima', width: 6),
          PosColumn(
            text: formatRupiah(r.cashReceived),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
      add(
        generator.row([
          PosColumn(text: 'Kembalian', width: 6),
          PosColumn(
            text: formatRupiah(r.change),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]),
      );
    }

    add(
      generator.text(
        'Terima kasih atas kunjungan Anda!',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
    );
    add(
      generator.text(
        'Selamat menikmati :)',
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
    );
    add(
      generator.text(
        '-- BIDJIKITA COFFEE ROASTERY --',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    // Advance paper just enough for the cutter, then cut
    add(generator.emptyLines(1));
    add(generator.rawBytes([0x1D, 0x56, 0x00])); // GS V 0 (full cut)

    return bytes;
  }

  static String _fmtDate(DateTime dt) {
    const months = [
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
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m';
  }

  /// Crops blank (white) margins from the top and bottom of an image.
  static img.Image _cropBlankMargins(img.Image src) {
    int top = 0;
    int bottom = src.height - 1;

    // Find top non-blank row
    for (int y = 0; y < src.height; y++) {
      bool blank = true;
      for (int x = 0; x < src.width; x++) {
        final p = src.getPixel(x, y);
        if (p.r < 240 || p.g < 240 || p.b < 240) {
          blank = false;
          break;
        }
      }
      if (!blank) {
        top = y;
        break;
      }
    }

    // Find bottom non-blank row
    for (int y = src.height - 1; y >= 0; y--) {
      bool blank = true;
      for (int x = 0; x < src.width; x++) {
        final p = src.getPixel(x, y);
        if (p.r < 240 || p.g < 240 || p.b < 240) {
          blank = false;
          break;
        }
      }
      if (!blank) {
        bottom = y;
        break;
      }
    }

    final height = bottom - top + 1;
    if (height <= 0 || height == src.height) return src;
    return img.copyCrop(src, x: 0, y: top, width: src.width, height: height);
  }
}
