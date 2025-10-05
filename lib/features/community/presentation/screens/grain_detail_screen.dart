import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/comment_input_field.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/comment_section.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/community/providers/comment_providers.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

// ✨ 1. ConsumerStatefulWidget으로 변경
class GrainDetailScreen extends ConsumerStatefulWidget {
  final String grainId;
  const GrainDetailScreen({super.key, required this.grainId});

  @override
  ConsumerState<GrainDetailScreen> createState() {
    debugPrint("🏗️ createState() 호출됨 - grainId: $grainId");
    return _GrainDetailScreenState();
  }
}

// ✨ 2. State 대신 ConsumerState를 상속
class _GrainDetailScreenState extends ConsumerState<GrainDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    debugPrint("✨ initState() 시작 - grainId: ${widget.grainId}");
    debugPrint("✨ 현재 시간: ${DateTime.now()}");

    super.initState();
    _scrollController.addListener(() {
      final currentPixels = _scrollController.position.pixels;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final triggerPoint = maxScroll - 200;

      print('현재 스크롤: $currentPixels, 최대 스크롤: $maxScroll, 호출 지점: $triggerPoint');
      // 스크롤이 맨 아래 근처에 도달하면 다음 페이지 로딩
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        print('---------fetch next page 실행!!!------------');
        // ✨ 3. widget.grainId 사용
        ref.read(commentProvider(widget.grainId).notifier).fetchNextPage();
      }
      debugPrint("✨ initState() 완료");
    });
  }

  @override
  void dispose() {
    print("--- 💀 GrainDetailScreen State가 파괴되었습니다! ---"); // <-- 추가

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
      bottomNavigationBar: CommentInputField(postId: widget.grainId),
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
                    grain: grain,
                    displayMode: IssueGrainDisplayMode.fullView,
                    // ✨ 4. fullView 모드에서는 더 이상 CommentSection을 직접 포함하지 않음
                  ),
                ),

                // 게시글의 끝부분 구분선과 댓글 섹션 사이에 구분선을 추가
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 8), // 상단 간격
                      Divider(
                        height: 3,
                        thickness: 1,
                        color: Colors.grey.shade200,
                      ),
                      const SizedBox(height: 8), // 하단 간격
                    ],
                  ),
                ),

                // ✨ 5. CommentSection을 GrainDetailScreen의 Sliver로 직접 추가
                CommentSection(postId: grain.postId),

                // 이 공간 덕분에 마지막 댓글이 bottomNavigationBar 위로 스크롤될 수 있습니다.
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80), // 입력창의 대략적인 높이만큼 설정
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
