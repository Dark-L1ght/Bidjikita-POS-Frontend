import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/receipt.dart';
import '../utils/currency.dart';

/// Generates a receipt PDF (letter/A4 for the fallback path).
class ReceiptPrinter {
  static Future<void> print(ReceiptData receipt) async {
    final pdf = pw.Document(title: 'Struk_${receipt.orderId}');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: const PdfPageFormat(
          595.28, // A4 width in points
          841.89, // A4 height in points
          marginAll: 42.52, // ~1.5cm in points
        ),
        build: (ctx) => _buildContent(receipt),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: 'Struk_${receipt.orderId}',
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Receipt content
  // ──────────────────────────────────────────────────────────────────────────
  static List<pw.Widget> _buildContent(ReceiptData r) {
    final bold = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11);
    final normal = const pw.TextStyle(fontSize: 10);
    final small = const pw.TextStyle(fontSize: 9);
    final titleLg = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18);
    final titleSm = pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14);
    final div = pw.Divider(thickness: 0.5, color: PdfColors.grey700);
    final thickDiv = pw.Divider(thickness: 1.2, color: PdfColors.black);

    return [
      // ── Shop header ────────────────────────────────────────────────
      pw.Center(child: pw.Text('BIDJIKITA', style: titleLg)),
      pw.Center(child: pw.Text('COFFEE ROASTERY', style: titleSm)),
      pw.SizedBox(height: 2),
      pw.Center(
        child: pw.Text('Jl. Logam No.36, Kujangsari, Bandung', style: small),
      ),
      pw.Center(child: pw.Text('Telp: 0812-3456-7890', style: small)),
      pw.SizedBox(height: 4),
      div,

      // ── Order metadata ─────────────────────────────────────────────
      _pRow('No. Pesanan', r.orderId, small, bold),
      _pRow('Tanggal', _fmtDate(r.dateTime), small, small),
      if (r.customerName.isNotEmpty)
        _pRow('Pelanggan', r.customerName, small, small),
      _pRow('Kasir', r.cashierName, small, small),
      _pRow('Tipe', r.orderType, small, small),
      pw.SizedBox(height: 2),
      div,

      // ── Items header ───────────────────────────────────────────────
      pw.Row(
        children: [
          pw.Expanded(flex: 6, child: pw.Text('Item', style: bold)),
          pw.Text('Qty', style: bold),
          pw.SizedBox(width: 6),
          pw.Expanded(
            flex: 3,
            child: pw.Text('Harga', style: bold, textAlign: pw.TextAlign.right),
          ),
        ],
      ),
      pw.Divider(thickness: 0.4, borderStyle: pw.BorderStyle.dashed),

      // ── Line items ─────────────────────────────────────────────────
      ...r.items.expand<pw.Widget>((item) {
        // Bundle: show name + sub-items.
        if (item.bundleSubItems.isNotEmpty) {
          return [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 6,
                  child: pw.Text(item.product.name, style: normal),
                ),
                pw.Text('${item.quantity}x', style: normal),
                pw.SizedBox(width: 6),
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    formatRupiah(item.subtotal),
                    style: normal,
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
            ...item.bundleSubItems.map(
              (sub) => pw.Text(
                '  ${sub.productName}${sub.variantName != null && sub.variantName != sub.productName ? " - ${sub.variantName}" : ""} x${sub.quantity}',
                style: small,
              ),
            ),
            if (item.note.isNotEmpty)
              pw.Text('  Catatan: ${item.note}', style: small),
          ];
        }

        final info = [
          if (item.size != 'Regular')
            '  ${item.size}${item.sugarLevel.isNotEmpty ? " - ${item.sugarLevel}" : ""}',
          if (item.note.isNotEmpty) '  Catatan: ${item.note}',
        ];
        return [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 6,
                child: pw.Text(item.product.name, style: normal),
              ),
              pw.Text('${item.quantity}x', style: normal),
              pw.SizedBox(width: 6),
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  formatRupiah(item.subtotal),
                  style: normal,
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
          ...info.map((s) => pw.Text(s, style: small)),
        ];
      }),
      pw.SizedBox(height: 2),
      div,

      // ── Totals ─────────────────────────────────────────────────────
      _pRow('Subtotal', formatRupiah(r.subtotal), normal, normal),
      pw.SizedBox(height: 2),
      thickDiv,
      _pRow('TOTAL', formatRupiah(r.total), bold, bold),
      thickDiv,
      pw.SizedBox(height: 2),

      // ── Payment ────────────────────────────────────────────────────
      _pRow('Pembayaran', r.paymentMethod, normal, normal),
      if (r.paymentMethod == 'Tunai') ...[
        _pRow('Diterima', formatRupiah(r.cashReceived), normal, normal),
        _pRow('Kembalian', formatRupiah(r.change), normal, normal),
      ],
      pw.SizedBox(height: 4),
      div,

      // ── Footer ─────────────────────────────────────────────────────
      pw.SizedBox(height: 4),
      pw.Center(
        child: pw.Text('Terima kasih atas kunjungan Anda!', style: small),
      ),
      pw.Center(
        child: pw.Text('Selamat menikmati minuman Anda :)', style: small),
      ),
      pw.SizedBox(height: 4),
      pw.Center(
        child: pw.Text(
          '-- BIDJIKITA COFFEE ROASTERY --',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7),
        ),
      ),
      pw.SizedBox(height: 10),
    ];
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────
  static pw.Widget _pRow(
    String label,
    String value,
    pw.TextStyle labelStyle,
    pw.TextStyle valueStyle,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: labelStyle),
        pw.Text(value, style: valueStyle),
      ],
    );
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
}
