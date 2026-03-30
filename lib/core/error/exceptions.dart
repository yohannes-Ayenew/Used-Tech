// lib/core/error/exceptions.dart

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => message;
}

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);

  @override
  String toString() => message;
}
