String formatAmount(double amount) {
  final fixed = amount.toStringAsFixed(2);
  if (fixed.endsWith('.00')) {
    return fixed.substring(0, fixed.length - 3);
  }
  return fixed;
}
