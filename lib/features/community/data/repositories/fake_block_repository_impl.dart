import 'package:mongle_flutter/features/community/domain/repositories/block_repository.dart';

// 'implements BlockRepository'를 통해 이 클래스가 BlockRepository의 규칙을
// 모두 따를 것임을 Dart에게 알려줍니다.
class FakeBlockRepositoryImpl implements BlockRepository {
  // 실제 서버의 데이터베이스를 흉내 내는 메모리 내 저장소입니다.
  // Set을 사용하면 중복된 ID가 저장되지 않고, 특정 ID의 존재 여부를 리스트보다 훨씬 빠르게 확인할 수 있습니다.
  final Set<String> _blockedUserIds = {
    // 테스트를 위해 미리 몇 개의 유저 ID를 차단해 둘 수 있습니다.
  };

  // @override는 이 메서드가 부모(BlockRepository)의 메서드를 재정의(구현)하는 것임을
  // 명시하는 안전장치입니다. 만약 메서드 이름을 오타내면 컴파일 에러를 발생시켜 실수를 막아줍니다.
  @override
  Future<void> blockUser(String userId) async {
    // async / await : 비동기 처리를 위한 키워드입니다.
    // Future.delayed를 통해 실제 네트워크 요청처럼 약간의 지연 시간을 줍니다.
    await Future.delayed(const Duration(milliseconds: 200));
    _blockedUserIds.add(userId);
    print(
      '[FakeBlockRepository] User $userId blocked. Current list: $_blockedUserIds',
    );
  }

  @override
  Future<void> unblockUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _blockedUserIds.remove(userId);
    print(
      '[FakeBlockRepository] User $userId unblocked. Current list: $_blockedUserIds',
    );
  }

  @override
  Future<List<String>> getBlockedUserIds() async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('[FakeBlockRepository] Fetched all blocked users.');
    return _blockedUserIds.toList();
  }
}
