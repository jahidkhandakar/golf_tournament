/// Maps app entities to the bundled photos under assets/pics/ by name, so an
/// image is matched to who/what it depicts (no random reuse):
///
///   people/     — one photo per named golfer (gender-matched), e.g.
///                 person('Marcus Thompson') -> people/marcus_thompson.jpg
///   field/      — one photo per club, e.g. field('Oakmont Hills') ->
///                 field/oakmont_hills.jpg
///   equipments/ — one photo per product type, keyed by a slug the listing
///                 carries (imageKey), e.g. equipment('driver')
///   scene_N     — group/scene shots, used for club galleries
///
/// Every render site has an errorBuilder fallback, so an unmatched name simply
/// degrades to initials / a placeholder icon.
class AppImages {
  AppImages._();

  static const int sceneCount = 4;

  static String person(String name) => 'assets/pics/people/${_slug(name)}.jpg';
  static String field(String clubName) => 'assets/pics/field/${_slug(clubName)}.jpg';
  static String equipment(String imageKey) => 'assets/pics/equipments/$imageKey.jpg';
  static String scene(int i) => 'assets/pics/people/scene_${(i % sceneCount) + 1}.jpg';

  static String _slug(String s) => s
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}
