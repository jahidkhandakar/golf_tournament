import '../entities/nearby_golfer.dart';

abstract class GolfersRepository {
  Future<List<NearbyGolfer>> getNearbyGolfers();
}
