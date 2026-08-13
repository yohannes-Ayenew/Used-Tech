import 'package:flutter_test/flutter_test.dart';
import 'package:used_tech_client/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('should format zero correctly', () {
      final result = CurrencyFormatter.format(0);
      expect(result, '0 ETB');
    });

    test('should format numbers below one thousand without comma', () {
      final result = CurrencyFormatter.format(500);
      expect(result, '500 ETB');
    });

    test('should format numbers with thousands separator', () {
      final result = CurrencyFormatter.format(15000);
      expect(result, '15,000 ETB');
    });

    test('should format large numbers with multiple commas', () {
      final result = CurrencyFormatter.format(1250000);
      expect(result, '1,250,000 ETB');
    });
  });
}
