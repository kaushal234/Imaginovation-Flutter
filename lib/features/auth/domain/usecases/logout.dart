import 'package:dartz/dartz.dart' show Either, Unit;

import 'package:imaginovation_app/core/error/failures.dart';
import 'package:imaginovation_app/core/usecase/usecase.dart';
import 'package:imaginovation_app/features/auth/domain/repositories/auth_repository.dart';

class Logout implements UseCase<Unit, NoParams> {
  Logout(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) => _repository.logout();
}
