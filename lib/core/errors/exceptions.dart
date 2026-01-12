class ServerException implements Exception {
  final String message;
  
  const ServerException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);
  
  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  
  const ValidationException(this.message);
  
  @override
  String toString() => message;
}

class AuthenticationException implements Exception {
  final String message;
  
  const AuthenticationException(this.message);
  
  @override
  String toString() => message;
}

class AuthorizationException implements Exception {
  final String message;
  
  const AuthorizationException(this.message);
  
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  
  const NotFoundException(this.message);
  
  @override
  String toString() => message;
}

