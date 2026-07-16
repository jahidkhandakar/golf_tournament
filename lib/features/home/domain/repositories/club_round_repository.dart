import '../entities/club_round.dart';

abstract class ClubRoundRepository {
  Future<List<ClubRound>> getClubRounds();
}
