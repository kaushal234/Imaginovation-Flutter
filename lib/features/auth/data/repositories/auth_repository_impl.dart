import 'package:dartz/dartz.dart' show Either, Left, Right, Unit, unit;

import 'package:imaginovation_app/core/error/exceptions.dart';
import 'package:imaginovation_app/core/error/failures.dart';
import 'package:imaginovation_app/core/storage/token_storage.dart';
import 'package:imaginovation_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:imaginovation_app/features/auth/domain/entities/user.dart';
import 'package:imaginovation_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remote.login(email: email, password: password);
      return Right(user);
    } on ServerException catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await _remote.logout();
    return const Right(unit);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _tokenStorage.readToken();
    return token != null && token.isNotEmpty;
  }

  Failure _mapException(ServerException e) {
    if (e.statusCode == 422) {
      return ValidationFailure(e.message, errors: e.errors);
    }
    return ServerFailure(e.message, statusCode: e.statusCode);
  }
}
