import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

class GrainDetailScreen extends ConsumerWidget {
  final String grainId;
  const GrainDetailScreen({super.key, required this.grainId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // grainId를 사용하여 특정 게시글의 상태를 watch합니다.
    final grainAsync = ref.watch(issueGrainProvider(grainId));

    return Scaffold(
      // 데이터 로딩 상태에 따라 AppBar의 제목을 동적으로 변경합니다.
      appBar: AppBar(
        title: grainAsync.when(
          data: (grain) => Text(grain.author.nickname), // 로딩 완료 시 작성자 닉네임
          loading: () => const Text(''), // 로딩 중
          error: (_, __) => const Text('오류'), // 에러 발생 시
        ),
      ),
      body: grainAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('게시글을 불러올 수 없습니다: $err')),
        data: (grain) {
          // 데이터 로딩이 완료되면, fullView 모드로 IssueGrainItem을 렌더링합니다.
          return SingleChildScrollView(
            child: IssueGrainItem(
              postId: grain.postId,
              displayMode: IssueGrainDisplayMode.fullView,
            ),
          );
        },
      ),
    );
  }
}
