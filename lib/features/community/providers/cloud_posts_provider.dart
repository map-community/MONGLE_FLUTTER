import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_posts.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/community/providers/report_providers.dart';

/// `CloudPostsNotifier`를 UI에 제공하는 Provider입니다.
/// .family를 사용하여 각 구름(`CloudProviderParam`)별로 독립적인 상태를 관리합니다.
final cloudPostsProvider = StateNotifierProvider.autoDispose
    .family<CloudPostsNotifier, AsyncValue<PaginatedPosts>, CloudProviderParam>(
      (ref, param) {
        // ref.watch를 통해 필터링에 필요한 다른 Provider들을 구독합니다.
        // 이 Provider들의 상태가 변경되면, cloudPostsProvider도 자동으로 재실행됩니다.
        ref.watch(blockedUsersProvider);
        ref.watch(reportedContentProvider);

        return CloudPostsNotifier(ref, param);
      },
    );

/// 특정 구름 게시판의 페이지네이션 상태와 비즈니스 로직을 관리하는 클래스입니다.
class CloudPostsNotifier extends StateNotifier<AsyncValue<PaginatedPosts>> {
  final Ref _ref;
  final CloudProviderParam _param;
  // 중복 호출을 방지하기 위한 플래그
  bool _isFetching = false;

  CloudPostsNotifier(this._ref, this._param)
    : super(const AsyncValue.loading()) {
    _fetchFirstPage();
  }

  /// 첫 페이지의 게시글을 불러옵니다.
  Future<void> _fetchFirstPage() async {
    // 이미 데이터를 가져오는 중이면 중복 실행을 방지합니다.
    if (_isFetching) return;
    _isFetching = true;

    try {
      final repository = _ref.read(issueGrainRepositoryProvider);
      final PaginatedPosts paginatedPosts;

      // 파라미터의 타입에 따라 적절한 repository 메서드를 호출합니다.
      if (_param.type == CloudType.static) {
        paginatedPosts = await repository.getGrainsInStaticCloud(
          placeId: _param.id,
        );
      } else {
        paginatedPosts = await repository.getGrainsInDynamicCloud(
          cloudId: _param.id,
        );
      }

      // 필터링 로직을 적용합니다.
      final visibleGrains = _filterVisibleGrains(paginatedPosts.posts);
      final filteredResult = paginatedPosts.copyWith(posts: visibleGrains);

      if (mounted) {
        state = AsyncValue.data(filteredResult);
      }
    } catch (e, s) {
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    } finally {
      // 작업이 끝나면 플래그를 false로 설정합니다.
      _isFetching = false;
    }
  }

  /// 다음 페이지의 게시글을 불러옵니다 (무한 스크롤).
  Future<void> fetchNextPage() async {
    // 로딩 중이거나, 다음 페이지가 없거나, 이미 다른 요청이 진행 중이면 아무것도 하지 않습니다.
    if (state.isLoading ||
        !state.hasValue ||
        !state.value!.hasNext ||
        _isFetching) {
      return;
    }

    _isFetching = true;

    final currentState = state.value!;

    try {
      final repository = _ref.read(issueGrainRepositoryProvider);
      final PaginatedPosts nextPageData;

      if (_param.type == CloudType.static) {
        nextPageData = await repository.getGrainsInStaticCloud(
          placeId: _param.id,
          cursor: currentState.nextCursor,
        );
      } else {
        nextPageData = await repository.getGrainsInDynamicCloud(
          cloudId: _param.id,
          cursor: currentState.nextCursor,
        );
      }

      final visibleNextGrains = _filterVisibleGrains(nextPageData.posts);

      if (mounted) {
        state = AsyncValue.data(
          currentState.copyWith(
            posts: [...currentState.posts, ...visibleNextGrains],
            nextCursor: nextPageData.nextCursor,
            hasNext: nextPageData.hasNext,
          ),
        );
      }
    } catch (e) {
      // 에러 발생 시 특별한 상태 처리는 하지 않지만, 로그를 남길 수 있습니다.
      print('다음 페이지 로딩 실패: $e');
    } finally {
      _isFetching = false;
    }
  }

  /// 주어진 게시글 목록에서 차단/신고된 콘텐츠를 필터링합니다.
  List<IssueGrain> _filterVisibleGrains(List<IssueGrain> grains) {
    final blockedUserIds = _ref.read(blockedUsersProvider);
    final reportedContents = _ref.read(reportedContentProvider);

    if (blockedUserIds.isEmpty && reportedContents.isEmpty) {
      return grains;
    }

    return grains.where((grain) {
      final isBlocked = blockedUserIds.contains(grain.author.id);
      if (isBlocked) return false;

      final isReported = reportedContents.any(
        (reported) =>
            reported.id == grain.postId &&
            reported.type == ReportContentType.POST,
      );
      if (isReported) return false;

      return true;
    }).toList();
  }
}
