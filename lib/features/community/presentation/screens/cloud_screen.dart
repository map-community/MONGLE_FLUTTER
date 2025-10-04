import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

// 1. StatefulWidget이 아닌 ConsumerWidget을 상속받습니다.
class CloudScreen extends ConsumerWidget {
  // 2. GoRouter로부터 전달받을 cloudId를 위한 변수입니다.
  final String cloudId;
  const CloudScreen({super.key, required this.cloudId});

  @override
  // 3. build 메서드에 WidgetRef ref 파라미터가 추가됩니다.
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ [추가] GoRouter의 현재 상태 정보에서 쿼리 파라미터를 가져옵니다.
    final typeString =
        GoRouterState.of(context).uri.queryParameters['type'] ?? 'dynamic';
    final cloudType = typeString == 'static'
        ? CloudType.static
        : CloudType.dynamic;

    // ✅ [추가] Provider에 전달할 파라미터 객체를 생성합니다.
    final providerParam = CloudProviderParam(id: cloudId, type: cloudType);

    // ✅ [수정] 기존 cloudId 대신 새로 만든 providerParam 객체를 전달합니다.
    final postsInCloudAsync = ref.watch(
      issueGrainsInCloudProvider(providerParam),
    );

    return Scaffold(
      appBar: AppBar(
        // TODO: 나중에는 실제 구름의 이름을 표시하도록 수정할 수 있습니다.
        title: const Text("구름 게시판"),
      ),
      // 5. AsyncValue의 when 메서드는 로딩/에러/데이터 상태에 따라
      // 다른 UI를 보여주도록 하여 코드를 매우 깔끔하게 만들어 줍니다.
      body: SafeArea(
        top: false,
        child: postsInCloudAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('게시물을 불러올 수 없습니다: $err')),
          data: (posts) {
            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  '이 구름에는 아직 알갱이가 없어요.\n첫 번째 알갱이를 만들어 보세요!',
                  textAlign: TextAlign.center,
                ),
              );
            }
            // 6. 데이터가 성공적으로 로드되면, ListView.builder를 사용해 목록을 그립니다.
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return IssueGrainItem(
                  postId: post.postId,
                  displayMode: IssueGrainDisplayMode.boardPreview,
                  onTap: () {
                    //    URL 경로를 동적으로 생성하여 전달합니다.
                    debugPrint(
                      "🚀 CloudScreen Navigation 시작 - grainId: ${post.postId}",
                    );
                    context.push('/cloud/$cloudId/grain/${post.postId}');
                    debugPrint("🚀 CloudScreen Navigation 호출 완료");
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
