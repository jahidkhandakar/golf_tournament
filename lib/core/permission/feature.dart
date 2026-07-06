/// Every gate-able capability in the app. Add new entries here as features
/// grow — the backend will eventually decide which of these a given user
/// (or plan tier) is entitled to.
enum Feature {
  auth,
  home,
  club,
  top50,
  messages,
  profile,
  notifications,
  createOuting,
  lookingToPlayPost,
  challengePlayer,
  changeLocation,
}
