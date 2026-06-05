import 'package:dartz/dartz.dart' show Either;
import 'package:equatable/equatable.dart';

import 'package:imaginovation_app/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// For use cases that take no arguments.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
