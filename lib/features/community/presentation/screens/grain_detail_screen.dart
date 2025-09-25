import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/comment_section.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/community/providers/comment_providers.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

// ✨ 1. ConsumerStatefulWidget으로 변경
class GrainDetailScreen extends ConsumerStatefulWidget {
  final String grainId;
  const GrainDetailScreen({super.key, required this.grainId});

  @override
  ConsumerState<GrainDetailScreen> createState() => _GrainDetailScreenState();
}

// ✨ 2. State 대신 ConsumerState를 상속
class _GrainDetailScreenState extends ConsumerState<GrainDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // 스크롤이 맨 아래 근처에 도달하면 다음 페이지 로딩
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // ✨ 3. widget.grainId 사용
        ref.read(commentProvider(widget.grainId).notifier).fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✨ 3. widget.grainId 사용
    final grainAsync = ref.watch(issueGrainProvider(widget.grainId));

    return Scaffold(
      appBar: AppBar(
        title: grainAsync.when(
          data: (grain) => Text(grain.author.nickname),
          loading: () => const Text(''),
          error: (_, __) => const Text('오류'),
        ),
      ),
      body: grainAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('게시글을 불러올 수 없습니다: $err')),
        data: (grain) {
          return SafeArea(
            top: false,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: IssueGrainItem(
                    postId: grain.postId,
                    displayMode: IssueGrainDisplayMode.fullView,
                    // ✨ 4. fullView 모드에서는 더 이상 CommentSection을 직접 포함하지 않음
                  ),
                ),
                // ✨ 5. CommentSection을 GrainDetailScreen의 Sliver로 직접 추가
                CommentSection(postId: grain.postId),
              ],
            ),
          );
        },
      ),
    );
  }
}
