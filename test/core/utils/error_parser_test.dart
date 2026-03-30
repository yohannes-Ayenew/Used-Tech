import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:used_tech_client/core/error/exceptions.dart';
import 'package:used_tech_client/core/utils/error_parser.dart';

void main() {
  group('ErrorParser.parseErrorMessage', () {
    test('should return "message" when it exists in root', () {
      final response = http.Response('{"message": "Server Error"}', 500);
      final result = ErrorParser.parseErrorMessage(response, 'Fallback');
      expect(result, 'Server Error');
    });

    test('should return "error" when it exists in root', () {
      final response = http.Response('{"error": "Invalid Input"}', 400);
      final result = ErrorParser.parseErrorMessage(response, 'Fallback');
      expect(result, 'Invalid Input');
    });

    test('should return "message" from nested "data" object', () {
      final response = http.Response('{"data": {"message": "Nested Error"}}', 500);
      final result = ErrorParser.parseErrorMessage(response, 'Fallback');
      expect(result, 'Nested Error');
    });

    test('should return fallback when JSON is invalid', () {
      final response = http.Response('not a json', 500);
      final result = ErrorParser.parseErrorMessage(response, 'Fallback');
      expect(result, 'Fallback');
    });

    test('should return fallback when keys are missing', () {
      final response = http.Response('{"foo": "bar"}', 500);
      final result = ErrorParser.parseErrorMessage(response, 'Fallback');
      expect(result, 'Fallback');
    });
  });

  group('ErrorParser.handleResponseError', () {
    test('should throw UnauthorizedException for 401', () {
      final response = http.Response('{"message": "Unauthorized"}', 401);
      expect(
        () => ErrorParser.handleResponseError(response),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('should throw NotFoundException for 404', () {
      final response = http.Response('{"message": "Not Found"}', 404);
      expect(
        () => ErrorParser.handleResponseError(response),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('should throw ValidationException for 400', () {
      final response = http.Response('{"message": "Bad Request"}', 400);
      expect(
        () => ErrorParser.handleResponseError(response),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw ConflictException for 409', () {
      final response = http.Response('{"message": "Conflict"}', 409);
      expect(
        () => ErrorParser.handleResponseError(response),
        throwsA(isA<ConflictException>()),
      );
    });

    test('should throw ServerException for 500', () {
      final response = http.Response('{"message": "Server Error"}', 500);
      expect(
        () => ErrorParser.handleResponseError(response),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
