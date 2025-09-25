import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/data/repositories/fake_comment_repository_impl.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_comments.dart';
import 'package:mongle_flutter/features/community/domain/repositories/comment_repository.dart';

// --- Data Layer Provider ---
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return FakeCommentRepositoryImpl();
});

// --- State Management Layer Provider  ---

/// CommentNotifier를 UI에 제공하는 Provider입니다.
/// .family를 사용하여 postId별로 독립적인 상태를 관리합니다.
final commentProvider = StateNotifierProvider.autoDispose
    .family<CommentNotifier, AsyncValue<PaginatedComments>, String>((
      ref,
      postId,
    ) {
      final repository = ref.watch(commentRepositoryProvider);
      return CommentNotifier(repository: repository, postId: postId);
    });

/// 특정 게시글의 댓글 상태와 비즈니스 로직을 관리하는 클래스입니다.
class CommentNotifier extends StateNotifier<AsyncValue<PaginatedComments>> {
  final CommentRepository _repository;
  final String _postId;

  // Notifier가 생성될 때, 초기 상태를 loading으로 설정하고 첫 페이지를 불러옵니다.
  CommentNotifier({
    required CommentRepository repository,
    required String postId,
  }) : _repository = repository,
       _postId = postId,
       super(const AsyncValue.loading()) {
    _fetchFirstPage();
  }

  /// 첫 페이지의 댓글을 불러옵니다.
  Future<void> _fetchFirstPage() async {
    try {
      final paginatedComments = await _repository.getComments(postId: _postId);
      // 위젯이 아직 화면에 마운트되어 있을 때만 상태를 업데이트합니다.
      if (mounted) {
        state = AsyncValue.data(paginatedComments);
      }
    } catch (e, s) {
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  /// 다음 페이지의 댓글을 불러옵니다 (무한 스크롤).
  Future<void> fetchNextPage() async {
    // 1. 현재 상태가 데이터가 아니거나, 다음 페이지가 없거나, 이미 로딩 중이면 실행하지 않습니다.
    if (!state.hasValue || !state.value!.hasNext || state is AsyncLoading) {
      return;
    }

    final currentState = state.value!;

    try {
      // 2. Repository에 다음 페이지를 요청합니다. (cursor 사용)
      final nextPageData = await _repository.getComments(
        postId: _postId,
        cursor: currentState.nextCursor,
      );

      if (mounted) {
        // 3. 기존 댓글 목록에 새로 불러온 댓글 목록을 이어붙여 상태를 업데이트합니다.
        state = AsyncValue.data(
          currentState.copyWith(
            comments: [...currentState.comments, ...nextPageData.comments],
            nextCursor: nextPageData.nextCursor,
            hasNext: nextPageData.hasNext,
          ),
        );
      }
    } catch (e) {
      // 에러 처리는 필요에 따라 구현합니다. (예: 스낵바 표시)
      print('댓글 다음 페이지 로딩 실패: $e');
    }
  }

  // TODO: 댓글/대댓글 추가 로직 구현
  // Future<void> addComment(String content) async { ... }
  // Future<void> addReply(String parentCommentId, String content) async { ... }
}
