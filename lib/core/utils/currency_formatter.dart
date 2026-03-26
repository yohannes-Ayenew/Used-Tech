// lib/core/utils/currency_formatter.dart

class CurrencyFormatter {
  static String format(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        ) + " ETB";
  }
}
