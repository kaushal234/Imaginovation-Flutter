/// Thrown by the data layer (data sources). Never crosses into domain.
class ServerException implements Exception {
  ServerException(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;
}
