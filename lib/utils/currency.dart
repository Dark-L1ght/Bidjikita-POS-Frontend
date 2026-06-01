/// Formats an integer IDR amount to "Rp 42.000" style.
String formatRupiah(int amount) {
  if (amount == 0) return 'Rp 0';
  final str = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
  }
  return 'Rp $buffer';
}
