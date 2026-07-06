import '../entities/gaggle.dart';

abstract class GaggleRepository {
  Future<List<Gaggle>> getGaggles();
}
