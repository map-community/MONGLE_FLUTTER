import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/community/data/repositories/comment_repository_impl.dart';
import 'package:mongle_flutter/features/community/data/repositories/fake_comment_repository_impl.dart';
import 'package:mongle_flutter/features/community/data/repositories/mock_comment_data.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_comments.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/domain/repositories/comment_repository.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/community/providers/reply_providers.dart';
import 'package:mongle_flutter/features/community/providers/report_providers.dart';

// --- Data Layer Provider ---
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  // return FakeCommentRepositoryImpl();
  final dio = ref.watch(dioProvider);
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  return CommentRepositoryImpl(dio, tokenStorage);
});

// --- State Management Layer Provider  ---

/// CommentNotifier를 UI에 제공하는 Provider입니다.
/// .family를 사용하여 postId별로 독립적인 상태를 관리합니다.
final commentProvider = StateNotifierProvider.autoDispose
    .family<CommentNotifier, AsyncValue<PaginatedComments>, String>((
      ref,
      postId,
    ) {
      // 2. 여기서 blockedUsersProvider를 watch 합니다.
      // 이 한 줄 덕분에, 사용자를 차단/해제할 때마다 blockedUsersProvider의 상태가 바뀌고,
      // Riverpod는 이 Provider를 "재생성"하여 CommentNotifier를 새로 만듭니다.
      // 결과적으로 CommentNotifier의 생성자가 다시 호출되며 댓글 목록을 새로 불러오고 필터링하게 됩니다.
      ref.watch(blockedUsersProvider);
      ref.watch(reportedContentProvider);

      final repository = ref.watch(commentRepositoryProvider);
      // 3. CommentNotifier를 생성할 때 ref 자체를 전달해줍니다.
      return CommentNotifier(repository: repository, postId: postId, ref: ref);
    });

/// 특정 게시글의 댓글 상태와 비즈니스 로직을 관리하는 클래스입니다.
class CommentNotifier extends StateNotifier<AsyncValue<PaginatedComments>> {
  final CommentRepository _repository;
  final String _postId;
  final Ref _ref;

  CommentNotifier({
    required CommentRepository repository,
    required String postId,
    required Ref ref,
  }) : _repository = repository,
       _postId = postId,
       _ref = ref,
       super(const AsyncValue.loading()) {
    _fetchFirstPage();
  }

  // '답글 모드'로 상태를 전환하는 메서드
  void enterReplyMode(Comment comment) {
    if (state.valueOrNull?.isSubmitting == true) return; // 전송 중에는 모드 변경 방지
    state = AsyncValue.data(state.value!.copyWith(replyingTo: comment));
  }

  // '답글 모드'를 해제하고 일반 댓글 모드로 돌아가는 메서드
  void exitReplyMode() {
    state = AsyncValue.data(state.value!.copyWith(replyingTo: null));
  }

  /// 주어진 댓글 목록에서 차단된 사용자의 댓글과 대댓글을 필터링합니다.
  List<Comment> _filterVisibleComments(List<Comment> comments) {
    final blockedUserIds = _ref.read(blockedUsersProvider);
    final reportedContents = _ref.read(reportedContentProvider);

    print('--- 🕵️‍♂️ Comment Filter Firing 🕵️‍♂️ ---');
    print('🚫 Blocked User IDs: $blockedUserIds');
    print(
      '🚩 Reported Contents: ${reportedContents.map((c) => '(${c.id}, ${c.type.name})').toList()}',
    );
    print('------------------------------------');

    if (blockedUserIds.isEmpty && reportedContents.isEmpty) {
      return comments;
    }

    final visibleComments = comments
        .where((comment) {
          // 조건 1: 댓글 작성자가 차단된 사용자인지 확인
          final isBlocked = blockedUserIds.contains(comment.author.id);
          // 조건 2: 이 댓글이 내가 신고한 댓글인지 확인
          final isReported = reportedContents.any(
            (reported) =>
                reported.id == comment.commentId &&
                reported.type == ReportContentType.COMMENT,
          );

          print(
            'Checking Comment ID: ${comment.commentId} -> IsBlocked: $isBlocked, IsReported: $isReported',
          );

          if (isBlocked) return false;
          if (isReported) return false;

          return true;
        })
        .map((comment) {
          // 각 댓글의 대댓글(replies) 목록도 동일하게 필터링
          final visibleReplies = comment.replies.where((reply) {
            final isBlocked = blockedUserIds.contains(reply.author.id);
            if (isBlocked) return false;

            final isReported = reportedContents.any(
              (reported) =>
                  reported.id == reply.commentId &&
                  reported.type == ReportContentType.COMMENT,
            );
            if (isReported) return false;

            return true;
          }).toList();
          // 필터링된 대댓글 목록으로 교체
          return comment.copyWith(replies: visibleReplies);
        })
        .toList();

    print(
      'Original comment count: ${comments.length}, Visible comment count: ${visibleComments.length}',
    );
    print('--- 🕵️‍♂️ Filter End 🕵️‍♂️ ---\n');

    return visibleComments;
  }

  /// 첫 페이지의 댓글을 불러옵니다.
  Future<void> _fetchFirstPage() async {
    print('➡️ [_fetchFirstPage] Start fetching comments for postId: $_postId');
    final previousState = state.valueOrNull;
    try {
      final paginatedComments = await _repository.getComments(postId: _postId);
      print(
        '✅ [_fetchFirstPage] Successfully fetched data. Comment count: ${paginatedComments.comments.length}',
      );

      // ✅ 분리된 필터링 메서드 호출
      final visibleComments = _filterVisibleComments(
        paginatedComments.comments,
      );
      final filteredPaginatedComments = paginatedComments.copyWith(
        comments: visibleComments,
      );

      if (mounted) {
        state = AsyncValue.data(
          filteredPaginatedComments.copyWith(
            replyingTo: previousState?.replyingTo,
          ),
        );
      }
    } catch (e, s) {
      print(
        '🚨 [_fetchFirstPage] ERROR CAUGHT! \n--- ERROR: $e \n--- STACK TRACE: $s',
      );

      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  /// 다음 페이지의 댓글을 불러옵니다 (무한 스크롤).
  Future<void> fetchNextPage() async {
    print(
      '➡️ [fetchNextPage] Attempting to fetch next page for postId: $_postId',
    );
    // 현재 상태가 데이터 로딩 중이거나, 다음 페이지가 없거나, 다른 제출(전송) 작업 중이면 아무것도 하지 않습니다.
    if (!state.hasValue || !state.value!.hasNext || state.value!.isSubmitting) {
      return;
    }

    final currentState = state.value!;
    // 다음 페이지 로딩 중임을 UI에 알리기 위해 isSubmitting 상태를 true로 잠시 변경합니다.
    state = AsyncValue.data(currentState.copyWith(isSubmitting: true));

    try {
      // Repository를 통해 다음 페이지 댓글 데이터를 가져옵니다.
      final nextPageData = await _repository.getComments(
        postId: _postId,
        cursor: currentState.nextCursor,
      );

      // 위젯이 아직 화면에 마운트되어 있는지 확인합니다.
      if (mounted) {
        // [핵심] 새로 불러온 댓글 목록도 동일하게 필터링 메서드를 호출합니다.
        final visibleNextComments = _filterVisibleComments(
          nextPageData.comments,
        );

        // 기존 댓글 목록 뒤에 필터링된 새 댓글 목록을 추가하여 상태를 업데이트합니다.
        state = AsyncValue.data(
          currentState.copyWith(
            comments: [...currentState.comments, ...visibleNextComments],
            nextCursor: nextPageData.nextCursor,
            hasNext: nextPageData.hasNext,
            isSubmitting: false, // 로딩이 끝났으므로 isSubmitting을 false로 복원합니다.
          ),
        );
      }
    } catch (e) {
      // 에러 발생 시에도 isSubmitting 상태를 false로 복원하여 앱이 멈추지 않도록 합니다.
      if (mounted) {
        state = AsyncValue.data(currentState.copyWith(isSubmitting: false));
      }
      print('댓글 다음 페이지 로딩 실패: $e');
    }
  }

  Future<void> addComment(String content) async {
    print('------------------------------------');
    print("댓글 addcomment실행" + _postId + " " + content);
    print('------------------------------------');
    final previousState = state.valueOrNull;
    print('------------------------------------');
    print("0" + _postId + " " + content);
    print('------------------------------------');
    if (previousState == null || previousState.isSubmitting) return;
    print('------------------------------------');
    print("1" + _postId + " " + content);
    print('------------------------------------');
    final newComment = Comment(
      commentId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      author: mockCurrentUser,
      createdAt: DateTime.now(),
    );
    print('------------------------------------');
    print("2" + _postId + " " + content);
    print('------------------------------------');
    // ✨ 1. UI를 즉시 업데이트하면서, isSubmitting 상태를 true로 설정합니다.
    state = AsyncValue.data(
      previousState.copyWith(
        comments: [newComment, ...previousState.comments],
        isSubmitting: true,
      ),
    );

    try {
      print('------------------------------------');
      print("댓글 impl addComment 테스트 로그 try 문" + _postId + " " + content);
      print('------------------------------------');
      await _repository.addComment(postId: _postId, content: content);

      // ✨ 2. 성공 후 목록을 새로고침하면, isSubmitting은 자동으로 기본값(false)으로 돌아옵니다.
      await _fetchFirstPage();
    } catch (e) {
      print('------------------------------------');
      print("댓글 impl addComment 테스트 로그 catch 문" + _postId + " " + content);
      print('------------------------------------');
      // ✨ 3. 실패 시, 이전 상태로 되돌리면서 isSubmitting을 false로 풀어줍니다.
      if (mounted) {
        state = AsyncValue.data(previousState.copyWith(isSubmitting: false));
      }
    }
  }

  Future<void> addReply(String parentCommentId, String content) async {
    exitReplyMode();
    final previousState = state.valueOrNull;
    if (previousState == null || previousState.isSubmitting) return;

    // 1. 전송 시작을 알리기 위해 isSubmitting 상태를 true로 설정
    state = AsyncValue.data(previousState.copyWith(isSubmitting: true));

    // 2. [UI 즉시 업데이트]
    // 첫 대댓글인 경우, 대댓글 영역이 보이도록 부모 댓글의 hasReplies만 true로 변경
    final parentComment = previousState.comments.firstWhere(
      (c) => c.commentId == parentCommentId,
    );
    if (!parentComment.hasReplies) {
      final updatedComments = previousState.comments.map((comment) {
        if (comment.commentId == parentCommentId) {
          return comment.copyWith(hasReplies: true);
        }
        return comment;
      }).toList();
      // hasReplies가 true로 변경된 상태를 UI에 우선 반영
      state = AsyncValue.data(state.value!.copyWith(comments: updatedComments));
    }

    try {
      // 3. 서버에 실제 대댓글 등록 요청
      await _repository.addReply(
        parentCommentId: parentCommentId,
        content: content,
      );

      // 4. [핵심] 대댓글 목록 Provider를 무효화하여 새로고침하도록 지시
      // 이제 _RepliesSection이 화면에 확실히 존재하므로, 이 신호를 받아 동작하게 됨
      _ref.invalidate(repliesProvider(parentCommentId));
    } finally {
      // 5. 성공/실패 여부와 관계없이 전송 상태(isSubmitting)를 false로 복원
      if (mounted) {
        // hasReplies가 true로 변경된 현재 상태는 그대로 유지하면서 전송 상태만 변경
        state = AsyncValue.data(state.value!.copyWith(isSubmitting: false));
      }
    }
  }
}
