import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/comment_input_field.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/comment_section.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/community/providers/comment_providers.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

// ✨ 1. ConsumerStatefulWidget으로 변경
class GrainDetailScreen extends ConsumerStatefulWidget {
  final String grainId;
  final String? boardName;
  final CloudProviderParam? cloudProviderParam;

  const GrainDetailScreen({
    super.key,
    required this.grainId,
    this.boardName,
    this.cloudProviderParam,
  });

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
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    print("--- 💀 GrainDetailScreen State가 파괴되었습니다! ---"); // <-- 추가
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // lib/features/community/presentation/screens/grain_detail_screen.dart

  @override
  Widget build(BuildContext context) {
    // issueGrainProvider를 구독하여 게시물 데이터의 상태(로딩, 성공, 실패)를 추적합니다.
    final grainAsync = ref.watch(issueGrainProvider(widget.grainId));

    // ref.listen을 사용하여 데이터 로딩 중 에러가 발생했을 때 사용자에게 SnackBar로 알려줍니다.
    // 이렇게 하면 화면 전체를 덮어쓰지 않고도 오류를 효과적으로 전달할 수 있습니다.
    ref.listen<AsyncValue>(issueGrainProvider(widget.grainId), (_, state) {
      if (state.hasError && state.error is Exception) {
        // 위젯 빌드가 완료된 후에 SnackBar를 표시하기 위해 microtask를 사용합니다.
        Future.microtask(() {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('데이터 일부를 불러오는데 실패했습니다: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    });

    // Scaffold는 화면의 기본 구조(뼈대)이므로, 데이터 상태와 관계없이 항상 먼저 그립니다.
    return Scaffold(
      // AppBar: 제목은 데이터 상태에 따라 다르게 표시됩니다.
      appBar: AppBar(
        title: grainAsync.when(
          data: (grain) =>
              Text(widget.boardName ?? '${grain.author.nickname}님의 글'),
          loading: () => const Text(''), // 로딩 중에는 제목을 비워둡니다.
          error: (_, __) {
            // 에러가 발생했더라도 이전에 불러온 데이터가 있다면, 그 데이터의 제목을 그대로 보여줍니다.
            if (grainAsync.hasValue) {
              final grain = grainAsync.value!;
              return Text(widget.boardName ?? '${grain.author.nickname}님의 글');
            }
            // 기존 데이터도 없다면 '오류'라고 표시합니다.
            return const Text('오류');
          },
        ),
      ),
      // 댓글 입력창은 데이터 상태와 관계없이 항상 표시됩니다.
      bottomNavigationBar: CommentInputField(postId: widget.grainId),
      // body: 화면의 내용물은 데이터 상태에 따라 다르게 그려집니다.
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // grainAsync.when을 사용하여 데이터 상태에 따라 다른 Sliver 위젯들을 렌더링합니다.
            grainAsync.when(
              // 로딩 중일 때: 화면 중앙에 로딩 인디케이터를 표시합니다.
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              // 에러 발생 시:
              error: (err, stack) {
                // [핵심] 에러가 발생했더라도, 이전에 성공적으로 불러온 데이터(grainAsync.value)가 있다면
                // 그 데이터를 우선적으로 보여주어 사용자 경험을 해치지 않습니다.
                // (예: 글 내용은 성공, 사진 URL만 실패한 경우)
                if (grainAsync.hasValue) {
                  final grain = grainAsync.value!;
                  // 기존 데이터로 UI를 그리되, 에러 발생 사실은 위의 ref.listen을 통해 SnackBar로 알려줍니다.
                  return SliverMainAxisGroup(
                    slivers: [
                      _buildGrainContent(grain),
                      CommentSection(postId: grain.postId),
                      _buildBottomPadding(),
                    ],
                  );
                }
                // 기존 데이터조차 없다면 (첫 로딩부터 실패한 경우) 에러 메시지를 표시합니다.
                return SliverFillRemaining(
                  child: Center(child: Text('게시글을 불러올 수 없습니다: $err')),
                );
              },
              // 데이터 로딩 성공 시:
              data: (grain) {
                // 게시글 본문, 댓글 등 여러 Sliver 위젯들을 그룹으로 묶어 반환합니다.
                return SliverMainAxisGroup(
                  slivers: [
                    _buildGrainContent(grain), // 게시글 본문 Sliver
                    CommentSection(postId: grain.postId), // 댓글 목록 Sliver
                    _buildBottomPadding(), // 하단 여백 Sliver
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 게시글 본문과 구분선을 묶어서 반환하는 헬퍼 위젯입니다. 코드를 재사용하고 구조를 명확하게 합니다.
  SliverMainAxisGroup _buildGrainContent(IssueGrain grain) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: IssueGrainItem(
            grain: grain,
            displayMode: IssueGrainDisplayMode.fullView,
            cloudProviderParam: widget.cloudProviderParam,
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Divider(height: 3, thickness: 1, color: Colors.grey.shade200),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  // 댓글 입력창에 가려지지 않도록 하단에 여백을 주는 헬퍼 위젯입니다.
  SliverToBoxAdapter _buildBottomPadding() {
    return const SliverToBoxAdapter(child: SizedBox(height: 80));
  }

  void _onScroll() {
    final currentPixels = _scrollController.position.pixels;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final triggerPoint = maxScroll - 200;

    print('현재 스크롤: $currentPixels, 최대 스크롤: $maxScroll, 호출 지점: $triggerPoint');

    if (currentPixels >= maxScroll - 200) {
      print('---------fetch next page 실행!!!------------');
      ref.read(commentProvider(widget.grainId).notifier).fetchNextPage();
    }
  }
}
