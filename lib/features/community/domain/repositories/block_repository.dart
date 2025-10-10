/// '사용자 차단'과 관련된 데이터 통신 규칙을 정의하는 추상 클래스(인터페이스)입니다.
///
/// 이 클래스를 통해 앱의 다른 부분(StateNotifier 등)은
/// 실제 데이터 소스가 Fake(가짜)인지 Real(실제 API)인지 신경 쓰지 않고
/// 일관된 방식으로 차단 기능을 사용할 수 있습니다.
abstract class BlockRepository {
  /// 특정 사용자를 차단 목록에 추가합니다.
  ///
  /// [userId]는 차단할 사용자의 고유 ID입니다.
  Future<void> blockUser(String userId);

  /// 특정 사용자를 차단 목록에서 해제합니다.
  ///
  /// [userId]는 차단 해제할 사용자의 고유 ID입니다.
  Future<void> unblockUser(String userId);

  /// 현재 내가 차단한 모든 사용자의 ID 목록을 가져옵니다.
  ///
  /// 앱이 시작되거나 필요할 때 이 메서드를 호출하여
  /// 어떤 사용자의 콘텐츠를 필터링해야 하는지 결정합니다.
  Future<List<String>> getBlockedUserIds();
}
