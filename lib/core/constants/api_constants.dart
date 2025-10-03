class ApiConstants {
  // private 생성자로 외부에서 인스턴스 생성을 막습니다.
  ApiConstants._();

  static const String login = '/auth/login';
  static const String signUp = '/auth/sign-up';
  static const String reissue = '/auth/reissue';

  static const String posts = '/posts';
}
