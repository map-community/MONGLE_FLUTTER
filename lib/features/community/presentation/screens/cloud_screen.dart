import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/community/providers/cloud_posts_provider.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

// ✅ 1. ConsumerStatefulWidget으로 변경
class CloudScreen extends ConsumerStatefulWidget {
  final String cloudId;
  const CloudScreen({super.key, required this.cloudId});

  @override
  ConsumerState<CloudScreen> createState() => _CloudScreenState();
}

// ✅ 2. ConsumerState 클래스 생성
class _CloudScreenState extends ConsumerState<CloudScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // ✅ 3. 스크롤 리스너 추가
    _scrollController.addListener(() {
      // 스크롤 위치가 최대 스크롤 범위의 80%를 넘어가면 다음 페이지 요청
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        // providerParam을 생성하여 notifier에 접근
        final providerParam = _getProviderParam();
        ref.read(cloudPostsProvider(providerParam).notifier).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ Helper method to get the current provider parameter
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

    // ✅ 4. ref.watch 대상을 새로운 cloudPostsProvider로 변경
    final postsInCloudAsync = ref.watch(cloudPostsProvider(providerParam));

    return Scaffold(
      appBar: AppBar(title: const Text("구름 게시판")),
      body: SafeArea(
        top: false,
        child: postsInCloudAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('게시물을 불러올 수 없습니다: $err')),
          data: (paginatedData) {
            final posts = paginatedData.posts;
            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  '이 구름에는 아직 알갱이가 없어요.\n첫 번째 알갱이를 만들어 보세요!',
                  textAlign: TextAlign.center,
                ),
              );
            }
            // ✅ 5. ListView.builder 로직 수정
            return ListView.builder(
              controller: _scrollController, // 컨트롤러 연결
              // 다음 페이지가 있으면 로딩 인디케이터를 보여줄 공간 +1
              itemCount: posts.length + (paginatedData.hasNext ? 1 : 0),
              itemBuilder: (context, index) {
                // 마지막 아이템 인덱스에 도달했고, 다음 페이지가 있다면 로딩 인디케이터 표시
                if (index == posts.length && paginatedData.hasNext) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final post = posts[index];
                return IssueGrainItem(
                  postId: post.postId,
                  displayMode: IssueGrainDisplayMode.boardPreview,
                  onTap: () {
                    context.push(
                      '/cloud/${widget.cloudId}/grain/${post.postId}',
                    );
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
