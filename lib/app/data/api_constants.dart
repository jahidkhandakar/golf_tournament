class ApiConstants{
/// google maps

  static String googleBaseUrl="https://maps.googleapis.com/maps/api/place/autocomplete/json";
  static String estimatedTimeUrl="https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&";
   /// App Url
    static String baseUrl="https://wn85j8p6-9090.asse.devtunnels.ms/v1"; // Server
    //static String baseUrl="https://ariful9090.sobhoy.com/v1"; // local
    static String  imageBaseUrl="https://wn85j8p6-9090.asse.devtunnels.ms";
    static String socketUrl="https://wn85j8p6-9090.asse.devtunnels.ms";

  //static String googleApiKey="AIzaSyBFi80uuJIWkkLCpodFa8oXmD8XD_h8LMc"; //Company
  static String googleApiKey="AIzaSyBI8fHu17r7bJcDz4eV8MdiVOIbYVG6fTI"; //client


///>>>>>>>>>>>>>>>>>>>>>>>>>>> User Auth>>>>>>>>>>>>>>>>>>>

static String registerUrl= '$baseUrl/auth/register';

static String emailSendUrl= '$baseUrl/auth/forgot-password';
static String verifyEmailWithOtpUrl= '$baseUrl/auth/verify-email';
static String resendOtpUrl= '$baseUrl/auth/re-send-otp';
static String logInUrl= '$baseUrl/auth/login';
static String resetPasswordUrl= '$baseUrl/auth/reset-password';
static String createTournamentUrl= '$baseUrl/tournament/create';
static String createSponsorTournamentUrl= '$baseUrl/sponser-tournament';
static String lookingToPlayCreationUrl= '$baseUrl/looking-toplay';
static String invitationSendUrl= '$baseUrl/invitation';
static String myTournamentShowingUrl= '$baseUrl/looking-toplay/show-tournament';
static String createSmallTournamentUrl= '$baseUrl/small-tournament/create';
static String clubTournamentUrl= '$baseUrl/tournament/getAll-tournament';
static String smallTournamentUrl= '$baseUrl/small-tournament/getAll-small-tournament';
static String locationUpdateUrl= '$baseUrl/location/update';
static String requestToPlayUrl= '$baseUrl/invitation';
static String allInvitationUrl= '$baseUrl/invitation';
static String myTournamentUrl= '$baseUrl/entered';
static String myTournamentNameUrl= '$baseUrl/teeSheet/serchTournament';
static String assignPlayerUrl= '$baseUrl/teeSheet';
static String notificationUrl= '$baseUrl/notification';
static String createChallengeUrl= '$baseUrl/chaleng';
static String sponsorContentUrl= '$baseUrl/sponser-tournament';
  static String sendRequestToPlayUrl = '$baseUrl/request-to-play';
  static String completeGamerUrl = '$baseUrl/complite-tournament';
  static String to50GolfersUrl = '$baseUrl/top-playear';
  static String subscribeUrl = '$baseUrl/subscrib';
  static String singleChatUrl = '$baseUrl/chat-room/single';
  static String groupChatUrl = '$baseUrl/chat-room/group';
  static String smallOutingRequestToPlayUrl(dynamic tournamentId) => '$baseUrl/small-tournament/makerequest-toplay';
  static String teeSheetUrl(String tournamentId,String tournamentType) => '$baseUrl/teeSheet?id=$tournamentId&type=$tournamentType';
  static String winnersUrl(dynamic completeTourId) => '$baseUrl/winner?id=$completeTourId';
  static String winnersConfirmationUrl(String completeTourId) => '$baseUrl/winner?id=$completeTourId';
  static String postWinnersUrl(String sectionName) => '$baseUrl/winner-$sectionName';
  static String updateSkinUrl = '$baseUrl/winner-skin';
  static String golfersNameUrl(String name) => '$baseUrl/users/showgolfer?name=$name';
  static String golfersNameDirectUrl = '$baseUrl/users/showgolfer';
  static String messageUrl = '$baseUrl/chat-room';
  static String playerListUrl(String tournamentId,String sectionName) => '$baseUrl/winner-$sectionName/allUser?id=$tournamentId';
  static String markAsReadNotificationUrl(dynamic notificationId) => '$baseUrl/notification?id=$notificationId';
  static String invitationDeleteUrl(dynamic invitationId) => '$baseUrl/invitation/delete?id=$invitationId';
  static String invitationAcceptUrl(dynamic invitationId) => '$baseUrl/invitation/accept?id=$invitationId';
  static String requestToPlayApprovedUrl(dynamic id) => '$baseUrl/request-to-play?id=$id';
  static String requestToPlayRejectUrl(dynamic id) => '$baseUrl/request-to-play/cancleRequest?id=$id';
  static String userProfileByIdUrl(dynamic userID) => '$baseUrl/users/$userID';
  static String challengeDeleteUrl(dynamic challengeId) => '$baseUrl/chaleng?id=$challengeId';
  static String requestToPlaylistUrl(String type,int page,int limit) => '$baseUrl/request-to-play?typename=big&page=$page&limit=$limit';
  static String tournamentDetailsUrl(String type,String tournamentId) => '$baseUrl/entered/details?id=$tournamentId&type=$type';
  static String tournamentPlayerUrl(String type,String tournamentId) => '$baseUrl/teeSheet/showTournamentById?id=$tournamentId&typeName=$type';
  static String showAllPlayerUrl(String type,String tournamentId) => '$baseUrl/chaleng/showAllplayer?type=$type&id=$tournamentId';
  static String showAllMatchesUrl(String type,String tournamentId) => '$baseUrl/chaleng?id=$tournamentId&type=$type';
  static String tournamentCompletionStatusUrl(String type,String tournamentId) => '$baseUrl/small-tournament/make-tournament-complete?id=$tournamentId&type=$type';

//===================X===============================================

static String timelinePostUrl= '$baseUrl/post/home';
static String myPostUrl= '$baseUrl/post';
static String createPostUrl= '$baseUrl/post';
static String createGroupPostUrl= '$baseUrl/post';
static String allGroupListUrl= '$baseUrl/group';
static String createGroupUrl= '$baseUrl/group';
static String otherGroupListUrl= '$baseUrl/group/joined';
static String myGroupListUrl= '$baseUrl/group/my';
static String friendRequestListUrl= '$baseUrl/friend/requests';
static String myFriendLIstUrl= '$baseUrl/friend/friends';
static String subscriptionPackageListUrl= '$baseUrl/subscription';
static String paymentSubscriptionUrl= '$baseUrl/subscription';
static String chatListUrl= '$baseUrl/chat/chart-list';
static String sendMessageUrl= '$baseUrl/message';
static String privacyPolicyUrl= '$baseUrl/setting/privacy';
static String termAndConditionUrl= '$baseUrl/setting/terms';
static String aboutUsUrl= '$baseUrl/setting/about-us';
static String supportUrl= '$baseUrl/setting/support';
static String removeGroupMemberUrl= '$baseUrl/group/remove-member';
static String addGroupMemberUrl= '$baseUrl/group/add-member';
static String createChatUrl= '$baseUrl/chat';
static String addGroupChatMember= '$baseUrl/chat/group';
static String removeGroupChatMember= '$baseUrl/chat/group/remove';
static String leaveGroupChatUrl= '$baseUrl/chat/group/live';
static String rewardPaymentUrl= '$baseUrl/payment/post/reward';
static String userProfileUrl= '$baseUrl/users/profile';

static String getMessageUrl(String chatId) => '$baseUrl/message?chatid=$chatId';
static String updateGroupChatUrl(dynamic chatId) => '$baseUrl/chat?id=$chatId';
static String deleteGroupUrl(dynamic groupId) => '$baseUrl/group/$groupId';
static String inviteFriendUrl(dynamic groupId) => '$baseUrl/group/all-invite-friend?groupId=$groupId';
static String updateGroupUrl(dynamic groupId) => '$baseUrl/group/update/$groupId';
static String groupSearchResultUrl(String name) => '$baseUrl/group/search?name=$name';
static String searchMyFriendListUrl(String name) => '$baseUrl/friend/friends?fullName=$name';
static String searchMyGroupChatMemberListUrl(String name) => '$baseUrl/chat/group/all-member?fullName=$name';
static String groupJoinUrl(dynamic groupId) => '$baseUrl/group/join?groupId=$groupId';
static String leaveGroupUrl(dynamic groupId) => '$baseUrl/group/left?groupId=$groupId';
static String acceptFriendRequestUrl(dynamic requestId) => '$baseUrl/friend/accept?requestId=$requestId';
static String removeFriendUrl(dynamic friendId) => '$baseUrl/friend/remove?friendId=$friendId';
static String groupAboutUrl(dynamic groupId) => '$baseUrl/group/$groupId';
static String deletePostUrl(dynamic postId)=> '$baseUrl/post/$postId';
static String  likeUrl (dynamic postId)=> '$baseUrl/post/like-toggle?postId=$postId';
static String  getCommentsUrl (dynamic postId)=> '$baseUrl/post/comments?postId=$postId';
static String  postCommentsUrl (dynamic postId)=> '$baseUrl/post/comment?postId=$postId';
static String  getProfileUrl (dynamic postId)=> '$baseUrl/users/$postId';
static String  updateProfileUrl (dynamic postId)=> '$baseUrl/users/$postId';
static String  sendFriendRequestUrl (dynamic postId)=> '$baseUrl/friend/request?receiverId=$postId';
static String  searchNameUrl (String name)=> '$baseUrl/users?fullName=$name';
static String  accountDeleteUrl (String userId)=> '$baseUrl/users/delete?userId=$userId';


}