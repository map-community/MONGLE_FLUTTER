import '../entities/issue_grain.dart';

/// '이슈 알갱이' 데이터 통신을 위한 계약서(추상 클래스)
abstract class IssueGrainRepository {
  /// 특정 구름(Cloud)에 속한 모든 이슈 알갱이 목록을 가져옵니다.
  Future<List<IssueGrain>> getIssueGrainsInCloud(String cloudId);

  /// 고유 ID를 통해 단일 이슈 알갱이 정보를 가져옵니다.
  Future<IssueGrain> getIssueGrainById(String id);

  /// 이슈 알갱이에 대한 좋아요를 요청합니다.
  Future<void> likeIssueGrain(String id);

  /// 이슈 알갱이에 대한 싫어요를 요청합니다.
  Future<void> dislikeIssueGrain(String id);

  /// 이슈 알갱이의 조회수를 증가시킵니다.
  Future<void> incrementViewCount(String id);
}
