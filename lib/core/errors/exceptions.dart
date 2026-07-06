/// Thrown by the data layer (datasources); caught by repositories and
/// translated into a [Failure] for the domain/presentation layers.
class ServerException implements Exception {
  const ServerException([this.message = 'Something went wrong on the server.']);

  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Something went wrong reading local data.']);

  final String message;
}
