import 'package:equatable/equatable.dart';

/// Base type returned by the domain layer when a use case fails.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Something went wrong reading local data.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'You do not have access to this feature.']);
}
