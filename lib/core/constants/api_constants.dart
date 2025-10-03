class ApiConstants {
  // private 생성자로 외부에서 인스턴스 생성을 막습니다.
  ApiConstants._();

  static const String login = '/auth/login';
  static const String signUp = '/auth/sign-up';
  static const String reissue = '/auth/reissue';

  static const String posts = '/posts';
  static const String postFileUploadUrls = '/post-files/upload-urls';

  static String postById(String postId) => '/posts/$postId';

  static String getComments(String postId) => '/posts/$postId/comments';
  static String getReplies(String parentCommentId) =>
      '/comments/$parentCommentId/replies';
  static String addComment(String postId) => '/posts/$postId/comments';
  static String addReply(String parentCommentId) =>
      '/comments/$parentCommentId/replies';

  static const String mapObjects = '/map/objects';
}
