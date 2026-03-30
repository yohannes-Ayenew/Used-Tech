// lib/core/utils/error_parser.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../error/exceptions.dart';

class ErrorParser {
  /// Parses the HTTP response and throws the appropriate exception.
  /// Handles both standard formats and the new backend AppError format.
  static String parseErrorMessage(http.Response response, String fallback) {
    try {
      final data = jsonDecode(response.body);
      
      // Handle { "message": "..." } or { "data": { "message": "..." } } or { "error": "..." }
      if (data is Map) {
        if (data.containsKey('message')) {
          return data['message'].toString();
        } else if (data.containsKey('error')) {
          return data['error'].toString();
        } else if (data.containsKey('data') && data['data'] is Map && data['data'].containsKey('message')) {
          return data['data']['message'].toString();
        }
      }
      
      return fallback;
    } catch (e) {
      return fallback;
    }
  }

  static Never handleResponseError(http.Response response, {String? defaultMessage}) {
    final message = parseErrorMessage(response, defaultMessage ?? 'An unexpected error occurred');
    
    if (response.statusCode == 401) {
      throw UnauthorizedException(message);
    } else if (response.statusCode == 403) {
      throw UnauthorizedException(message); // Reuse Unauthorized for Forbidden for now, or add ForbiddenException
    } else if (response.statusCode == 404) {
      throw NotFoundException(message);
    } else if (response.statusCode == 409) {
      throw ConflictException(message);
    } else if (response.statusCode == 400) {
      throw ValidationException(message);
    } else if (response.statusCode >= 500) {
      throw ServerException(message);
    } else {
      throw ServerException(message);
    }
  }
}
