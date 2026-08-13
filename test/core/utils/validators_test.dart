import 'package:flutter_test/flutter_test.dart';
import 'package:used_tech_client/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns error message when value is null or empty', () {
      expect(Validators.required(null), 'This field is required');
      expect(Validators.required('   '), 'This field is required');
    });

    test('returns null when value is non-empty', () {
      expect(Validators.required('valid input'), isNull);
    });
  });

  group('Validators.email', () {
    test('returns error message when email is null or invalid', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email('invalid-email'), 'Please enter a valid email address');
      expect(Validators.email('test@domain'), 'Please enter a valid email address');
    });

    test('returns null when email format is valid', () {
      expect(Validators.email('test@example.com'), isNull);
    });
  });

  group('Validators.phone', () {
    test('returns null when phone is null or empty since optional', () {
      expect(Validators.phone(null), isNull);
      expect(Validators.phone(''), isNull);
    });

    test('returns error when phone length is invalid', () {
      expect(Validators.phone('12345'), 'Please enter a valid 10-digit phone number');
    });

    test('returns null when phone is valid 10-digit number', () {
      expect(Validators.phone('0911234567'), isNull);
    });
  });

  group('Validators.password', () {
    test('returns error message when password is short or empty', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password('123'), 'Password must be at least 6 characters');
    });

    test('returns null when password meets minimum length', () {
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.strongPassword', () {
    test('validates password requirements correctly', () {
      expect(Validators.strongPassword(null), 'Password is required');
      expect(Validators.strongPassword('Short1'), 'Password must be at least 8 characters');
      expect(Validators.strongPassword('lowercase1'), 'Password must contain at least one uppercase letter');
      expect(Validators.strongPassword('NoDigitsHere'), 'Password must contain at least one number');
      expect(Validators.strongPassword('StrongPass1'), isNull);
    });
  });
}
