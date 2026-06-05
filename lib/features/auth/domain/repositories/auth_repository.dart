import 'package:dartz/dartz.dart' show Either, Unit;

import 'package:imaginovation_app/core/error/failures.dart';
import 'package:imaginovation_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();

  Future<bool> isAuthenticated();
}
