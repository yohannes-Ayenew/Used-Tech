// lib/core/utils/currency_formatter.dart

/// Utility for formatting monetary currency values into localized string representations.
class CurrencyFormatter {
  /// Formats a double amount into a thousands-separated currency string ending with "ETB".
  static String format(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '$formatted ETB';
  }
}
