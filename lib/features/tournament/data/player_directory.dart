import '../../profile/domain/entities/user_profile.dart';

/// Lookup for the gender and senior flags shown next to player names during
/// score and placard entry, so whoever is typing knows which category slot a
/// placard name belongs in. Reads each registrant's profile once the backend
/// is wired; until then this mock seeds the demo roster. Unknown names render
/// with no chips rather than guessed ones.
class PlayerDirectory {
  static const Map<String, ({Gender gender, bool senior, double handicap})> _seed = {
    'Jahid': (gender: Gender.male, senior: false, handicap: 3.2),
    'Marcus Thompson': (gender: Gender.male, senior: true, handicap: 12.4),
    'Priya Kapoor': (gender: Gender.female, senior: false, handicap: -1.0),
    'Erin Walsh': (gender: Gender.female, senior: false, handicap: 8.9),
    'Dana Reyes': (gender: Gender.female, senior: true, handicap: 15.1),
    'Sam Ortiz': (gender: Gender.male, senior: false, handicap: 5.5),
    'Jordan Blake': (gender: Gender.male, senior: false, handicap: 6.7),
    'Casey Nguyen': (gender: Gender.female, senior: false, handicap: 10.3),
    'Devon Lee': (gender: Gender.male, senior: true, handicap: 4.8),
    'Riley Foster': (gender: Gender.male, senior: false, handicap: 18.6),
    'Taylor Brooks': (gender: Gender.male, senior: false, handicap: 9.2),
  };

  ({Gender gender, bool senior, double handicap}) lookup(String player) =>
      _seed[player] ?? (gender: Gender.unspecified, senior: false, handicap: 10.0);

  Map<String, double> handicapsFor(Iterable<String> players) =>
      {for (final p in players) p: lookup(p).handicap};
}
