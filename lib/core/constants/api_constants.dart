class ApiConstants {
  // private 생성자로 외부에서 인스턴스 생성을 막습니다.
  ApiConstants._();

  static const String signUp = '/auth/sign-up';
  static const String verificationCode = '/auth/verification-code';

  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String reissue = '/auth/reissue';

  static const String postFileUploadUrls = '/post-files/upload-urls';
  static const String posts = '/posts';

  static String postById(String postId) => '/posts/$postId';
  static String getComments(String postId) => '/posts/$postId/comments';
  static String getReplies(String parentCommentId) =>
      '/comments/$parentCommentId/replies';
  static String addComment(String postId) => '/posts/$postId/comments';
  static String addReply(String parentCommentId) =>
      '/comments/$parentCommentId/replies';

  static String reaction(String targetType, String targetId) =>
      '/$targetType/$targetId/reaction';

  static const String mapObjects = '/map/objects';

  // 게시글 삭제 경로
  static String deletePost(String postId) => '/posts/$postId';

  // 댓글 삭제 경로
  static String deleteComment(String commentId) => '/comments/$commentId';

  // 사용자 차단 및 차단 해제 경로
  static String blockUser(String userId) => '/blocks/$userId';
  // 내 차단 목록 조회 경로
  static const String myBlockedUsers = '/blocks/me';

  static const String reports = '/reports';
}
