import 'package:flutter_test/flutter_test.dart';
import 'package:used_tech_client/core/constants/api_endpoints.dart';

void main() {
  group('ApiEndpoints Test Suite', () {
    test('baseUrl should return valid production endpoint', () {
      expect(ApiEndpoints.baseUrl, equals('https://ecommerce-backend-saje.onrender.com/api'));
    });

    group('resolveImageUrl', () {
      test('should return empty string when path is empty', () {
        expect(ApiEndpoints.resolveImageUrl(''), equals(''));
      });

      test('should return raw URL when path starts with http', () {
        const fullUrl = 'https://example.com/image.png';
        expect(ApiEndpoints.resolveImageUrl(fullUrl), equals(fullUrl));
      });

      test('should prefix relative paths with host URL', () {
        expect(
          ApiEndpoints.resolveImageUrl('uploads/items/123.jpg'),
          equals('https://ecommerce-backend-saje.onrender.com/uploads/items/123.jpg'),
        );
      });

      test('should strip leading src/ prefix from image path', () {
        expect(
          ApiEndpoints.resolveImageUrl('src/uploads/items/123.jpg'),
          equals('https://ecommerce-backend-saje.onrender.com/uploads/items/123.jpg'),
        );
      });
    });

    group('User & Auth Endpoints', () {
      test('should construct correct user auth endpoint URLs', () {
        expect(ApiEndpoints.login, endsWith('/users/login'));
        expect(ApiEndpoints.register, endsWith('/users/register'));
        expect(ApiEndpoints.verifyEmail, endsWith('/users/verify-email'));
        expect(ApiEndpoints.googleLogin, endsWith('/users/google'));
        expect(ApiEndpoints.getProfile, endsWith('/users/me'));
      });
    });

    group('Product Endpoints', () {
      test('should construct correct product endpoint URLs', () {
        expect(ApiEndpoints.getProducts, equals('${ApiEndpoints.baseUrl}/products'));
        expect(ApiEndpoints.getProductById('prod-123'), equals('${ApiEndpoints.baseUrl}/products/prod-123'));
        expect(ApiEndpoints.updateProductStatus('prod-123'), equals('${ApiEndpoints.baseUrl}/products/prod-123/status'));
      });
    });

    group('Order Endpoints', () {
      test('should construct correct order status and dispute URLs', () {
        expect(ApiEndpoints.createOrder, equals('${ApiEndpoints.baseUrl}/orders'));
        expect(ApiEndpoints.markOrderShipped('ord-99'), equals('${ApiEndpoints.baseUrl}/orders/ord-99/shipped'));
        expect(ApiEndpoints.completeOrder('ord-99'), equals('${ApiEndpoints.baseUrl}/orders/ord-99/complete'));
        expect(ApiEndpoints.reportIssue('ord-99'), equals('${ApiEndpoints.baseUrl}/orders/ord-99/dispute'));
      });
    });

    group('Socket URL', () {
      test('should strip /api suffix from socket root URL', () {
        expect(ApiEndpoints.socketUrl, equals('https://ecommerce-backend-saje.onrender.com'));
      });
    });
  });
}
