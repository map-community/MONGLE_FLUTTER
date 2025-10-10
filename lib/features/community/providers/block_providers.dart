import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/features/community/data/repositories/block_repository_impl.dart';
import 'package:mongle_flutter/features/community/data/repositories/fake_block_repository_impl.dart';
import 'package:mongle_flutter/features/community/domain/repositories/block_repository.dart';

// 1. [서비스 제공] BlockRepository의 구현체(Fake)를 제공하는 Provider
// "BlockRepository 주세요" 라고 요청하면 FakeBlockRepositoryImpl 인스턴스를 반환합니다.
// 나중에 실제 API를 연동할 때 이 Provider 내부만 RealRepository로 교체하면 됩니다.
final blockRepositoryProvider = Provider<BlockRepository>((ref) {
  final dio = ref.watch(dioProvider);
  // ✅ 수정: 생성자에 ref와 dio 인스턴스를 모두 전달합니다.
  return BlockRepositoryImpl(ref, dio);
});

// 2. [상태 관리 및 제공] 차단된 사용자 목록 상태를 관리하고 외부에 노출하는 Provider
// UI는 이 Provider를 통해 차단 목록을 얻고, 차단/해제 기능을 호출합니다.
final blockedUsersProvider =
    StateNotifierProvider<BlockedUsersNotifier, List<String>>((ref) {
      // ref를 통해 다른 Provider(blockRepositoryProvider)를 가져와 의존성을 주입합니다.
      final repository = ref.watch(blockRepositoryProvider);
      return BlockedUsersNotifier(repository);
    });

/// '차단된 사용자 목록'이라는 상태(State)와
/// 그 상태를 변경하는 비즈니스 로직(Notifier)을 캡슐화한 클래스입니다.
class BlockedUsersNotifier extends StateNotifier<List<String>> {
  final BlockRepository _repository;

  // 생성될 때, 의존성 주입(DI)으로 repository를 받고, 초기 상태를 빈 리스트([])로 설정합니다.
  BlockedUsersNotifier(this._repository) : super([]) {
    // Notifier가 처음 생성될 때, 저장소에서 초기 차단 목록을 불러옵니다.
    _loadBlockedUsers();
  }

  // 저장소에서 차단 목록을 가져와 상태를 초기화하는 내부 메서드
  Future<void> _loadBlockedUsers() async {
    state = await _repository.getBlockedUserIds();
  }

  // 사용자를 차단하는 외부 공개 메서드
  Future<void> blockUser(String userId) async {
    // 이미 차단된 사용자인지 확인 (불필요한 요청 방지)
    if (state.contains(userId)) return;

    // 1. 서버에 차단 요청을 보냅니다. (느릴 수 있음)
    await _repository.blockUser(userId);

    // 2. 요청 성공 시, 즉시 로컬 상태를 업데이트하여 UI에 바로 반영합니다. (Optimistic UI)
    state = [...state, userId]; // 기존 state 리스트에 새로운 userId를 추가
  }

  // 사용자를 차단 해제하는 외부 공개 메서드
  Future<void> unblockUser(String userId) async {
    if (!state.contains(userId)) return;

    await _repository.unblockUser(userId);
    // where((id) => id != userId) : 리스트에서 특정 userId만 제외하고 새 리스트를 만듭니다.
    state = state.where((id) => id != userId).toList();
  }
}
