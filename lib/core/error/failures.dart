import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message, {this.errors});

  final String message;
  final Map<String, dynamic>? errors;

  /// First validation message, if this failure carries field errors.
  String? firstError() {
    if (errors == null || errors!.isEmpty) return null;
    final first = errors!.values.first;
    if (first is List && first.isNotEmpty) return first.first.toString();
    return first.toString();
  }

  @override
  List<Object?> get props => [message, errors];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.errors, this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, errors, statusCode];
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.errors});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}
