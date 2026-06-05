import 'package:imaginovation_app/features/auth/domain/repositories/auth_repository.dart';

/// Simple local check (no network), so it returns a bool rather than Either.
class CheckAuthStatus {
  CheckAuthStatus(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.isAuthenticated();
}
