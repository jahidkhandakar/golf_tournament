import '../entities/outing.dart';

abstract class OutingRepository {
  Future<List<Outing>> getOutings();
}
