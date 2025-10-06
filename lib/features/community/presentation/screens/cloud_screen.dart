import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

// [수정] ConsumerWidget을 ConsumerStatefulWidget으로 변경
class CloudScreen extends ConsumerStatefulWidget {
  final String cloudId;
  final String? name;

  const CloudScreen({super.key, required this.cloudId, this.name});

  @override
  ConsumerState<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends ConsumerState<CloudScreen> {
  // [수정] 스크롤 컨트롤러 추가
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // [수정] 스크롤 리스너 추가
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // [수정] 스크롤 리스너 함수
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 화면 거의 끝에 도달하면 다음 페이지 요청
      final providerParam = _getProviderParam();
      ref.read(paginatedGrainsProvider(providerParam).notifier).fetchNextPage();
    }
  }

  // [수정] Provider 파라미터를 가져오는 헬퍼 함수
  CloudProviderParam _getProviderParam() {
    final typeString =
        GoRouterState.of(context).uri.queryParameters['type'] ?? 'dynamic';
    final cloudType = typeString == 'static'
        ? CloudType.static
        : CloudType.dynamic;
    return CloudProviderParam(id: widget.cloudId, type: cloudType);
  }

  @override
  Widget build(BuildContext context) {
    final providerParam = _getProviderParam();
    // [수정] 새로운 paginatedGrainsProvider를 watch
    final postsAsync = ref.watch(paginatedGrainsProvider(providerParam));

    final appBarTitle = widget.name ?? '구름 게시판';

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: SafeArea(
        top: false,
        child: postsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('게시물을 불러올 수 없습니다: $err')),
          data: (paginatedPosts) {
            final posts = paginatedPosts.posts;

            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  '이 구름에는 아직 알갱이가 없어요.\n첫 번째 알갱이를 만들어 보세요!',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              // [수정] 스크롤 컨트롤러 연결
              controller: _scrollController,
              // [수정] itemCount 계산: 다음 페이지가 있으면 로딩 인디케이터를 위해 +1
              itemCount: posts.length + (paginatedPosts.hasNext ? 1 : 0),
              itemBuilder: (context, index) {
                // [수정] 마지막 아이템이면 로딩 인디케이터 표시
                if (index == posts.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final post = posts[index];
                return IssueGrainItem(
                  grain: post,
                  displayMode: IssueGrainDisplayMode.boardPreview,
                  onTap: () async {
                    context.push(
                      '/cloud/${widget.cloudId}/grain/${post.postId}',
                    );

                    ref.invalidate(paginatedGrainsProvider(providerParam));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
