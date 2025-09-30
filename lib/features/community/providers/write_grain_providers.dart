import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

part 'write_grain_providers.freezed.dart';

// 1. 글쓰기 화면의 '상태'를 정의하는 클래스
@freezed
abstract class WriteGrainState with _$WriteGrainState {
  const factory WriteGrainState({
    @Default(false) bool isSubmitting, // 현재 제출 중인지 여부 (로딩 상태)
    String? errorMessage, // 에러가 발생했을 때 메시지
  }) = _WriteGrainState;
}

// 2. 상태를 관리하고 비즈니스 로직을 수행하는 '두뇌' 클래스
class WriteGrainNotifier extends StateNotifier<WriteGrainState> {
  final Ref _ref;

  WriteGrainNotifier(this._ref) : super(const WriteGrainState());

  Future<bool> submitPost({
    required String content,
    required List<String> photoUrls,
  }) async {
    // 내용이 비어있으면 실패 처리
    if (content.trim().isEmpty) {
      state = state.copyWith(errorMessage: '내용을 입력해주세요.');
      return false;
    }

    // 로딩 상태 시작
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      // Repository를 가져옵니다.
      final repository = _ref.read(issueGrainRepositoryProvider);

      // 현재 위치를 가져옵니다.
      final position = await Geolocator.getCurrentPosition();

      // Repository의 createIssueGrain 메서드를 호출합니다.
      await repository.createIssueGrain(
        content: content,
        photoUrls: photoUrls,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // 로딩 상태 종료 및 성공
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      // 에러 발생 시 로딩 상태 종료 및 실패 처리
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }
}

// 3. UI가 WriteGrainNotifier에 접근할 수 있도록 해주는 Provider
final writeGrainProvider =
    StateNotifierProvider.autoDispose<WriteGrainNotifier, WriteGrainState>(
      (ref) => WriteGrainNotifier(ref),
    );
