import 'package:dartz/dartz.dart' show Either;
import 'package:equatable/equatable.dart';

import 'package:imaginovation_app/core/error/failures.dart';
import 'package:imaginovation_app/core/usecase/usecase.dart';
import 'package:imaginovation_app/features/auth/domain/entities/user.dart';
import 'package:imaginovation_app/features/auth/domain/repositories/auth_repository.dart';

class Login implements UseCase<User, LoginParams> {
  Login(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
