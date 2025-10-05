// lib/features/map/presentation/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/comment_input_field.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/comment_section.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/community/providers/comment_providers.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/map_view.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/multi_stage_bottom_sheet.dart';

// 1. ConsumerWidget에서 ConsumerStatefulWidget으로 변경
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  // 2. createState 메서드 구현
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

// 3. State 클래스를 ConsumerState<MapScreen>으로 상속
class _MapScreenState extends ConsumerState<MapScreen> {
  // 4. 기존 build 메서드 및 모든 헬퍼 메서드를 State 클래스 안으로 이동
  @override
  Widget build(BuildContext context) {
    // 이제 'ref'는 클래스의 멤버이므로 어디서든 접근 가능합니다.
    final mapState = ref.watch(mapViewModelProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetState = ref.watch(mapSheetStrategyProvider);
    final selectedGrainId = sheetState.selectedGrainId;

    final List<double> snapSizes;
    if (selectedGrainId != null) {
      snapSizes = [peekFraction, grainPreviewFraction, fullFraction];
    } else {
      snapSizes = [peekFraction, fullFraction];
    }

    final canPop = sheetState.mode == SheetMode.minimized;

    final isFabVisible = sheetState.mode == SheetMode.minimized;

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        if (didPop) return;

        final notifier = ref.read(mapSheetStrategyProvider.notifier);
        switch (sheetState.mode) {
          case SheetMode.full:
            notifier.showGrainPreview(selectedGrainId!);
            break;
          case SheetMode.preview:
          case SheetMode.localFeed:
            notifier.minimize();
            break;
          case SheetMode.minimized:
            break;
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 1. 지도
            mapState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(child: Text(message)),
              data: (initialPosition, mapObjects) {
                return MapView(
                  initialPosition: initialPosition,
                  bottomPadding: screenHeight * sheetState.height,
                );
              },
            ),

            // 2. FAB (지도 바로 위에 그려짐)
            Positioned(
              right: 16,
              bottom: (screenHeight * peekFraction) + 16,
              child: AnimatedOpacity(
                opacity: isFabVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !isFabVisible,
                  child: FloatingActionButton(
                    onPressed: () {
                      context.push('/write');
                    },
                    child: const Icon(Icons.edit),
                  ),
                ),
              ),
            ),

            // 3. 바텀시트 (FAB 위에 그려짐)
            MultiStageBottomSheet(
              strategyProvider: mapSheetStrategyProvider,
              minSnapSize: peekFraction,
              maxSnapSize: fullFraction,
              snapSizes: snapSizes,
              builder: (context, scrollController) {
                switch (sheetState.mode) {
                  case SheetMode.full:
                    return _buildFullScrollView(
                      context,
                      scrollController,
                      selectedGrainId!,
                    );
                  case SheetMode.preview:
                    return _buildPreviewCard(
                      context,
                      selectedGrainId!,
                      scrollController,
                    );
                  case SheetMode.localFeed:
                    return _buildLocalFeedSheet(context, scrollController);
                  case SheetMode.minimized:
                  default:
                    return _buildDefaultSheet(scrollController);
                }
              },
            ),

            // 4. 댓글 입력창 (가장 위에 그려짐)
            if (sheetState.mode == SheetMode.full)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: CommentInputField(postId: sheetState.selectedGrainId!),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 기본 상태의 바텀시트
  Widget _buildDefaultSheet(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        _buildHandle(),
        const ListTile(title: Text("주변 이슈 목록(구름)")),
      ],
    );
  }

  /// 미리보기 상태의 바텀시트 (고정 크기 카드)
  Widget _buildPreviewCard(
    BuildContext context,
    String grainId,
    ScrollController scrollController,
  ) {
    final grainAsync = ref.watch(issueGrainProvider(grainId));

    return GestureDetector(
      onTap: () {
        ref.read(mapSheetStrategyProvider.notifier).showGrainDetail(grainId);
      },
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        child: AbsorbPointer(
          child: Column(
            children: [
              _buildHandle(),
              // [수정] grainAsync의 상태에 따라 UI를 분기 처리합니다.
              grainAsync.when(
                loading: () => const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: Text('오류: $e')),
                ),
                data: (grain) => IssueGrainItem(
                  // [수정] postId 대신 가져온 grain 객체를 전달합니다.
                  grain: grain,
                  displayMode: IssueGrainDisplayMode.mapPreview,
                  onTap: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 전체보기 상태의 바텀시트 (스크롤 뷰)
  Widget _buildFullScrollView(
    BuildContext context,
    ScrollController scrollController,
    String grainId,
  ) {
    final grainAsync = ref.watch(issueGrainProvider(grainId));

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        final commentState = ref.watch(commentProvider(grainId));
        final isFetchingNextPage =
            commentState.valueOrNull?.isSubmitting ?? commentState.isLoading;

        if (!isFetchingNextPage &&
            metrics.pixels >= metrics.maxScrollExtent - 200) {
          ref.read(commentProvider(grainId).notifier).fetchNextPage();
        }
        return false;
      },
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildHandle()),
          grainAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text('오류: $e')),
              ),
            ),
            data: (grain) => SliverToBoxAdapter(
              child: IssueGrainItem(
                // [수정] postId 대신 가져온 grain 객체를 전달합니다.
                grain: grain,
                displayMode: IssueGrainDisplayMode.fullView,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade200,
            ),
          ),
          CommentSection(postId: grainId),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  /// 주변 알갱이 목록을 보여주는 '로컬 피드' 위젯
  Widget _buildLocalFeedSheet(
    BuildContext context,
    ScrollController scrollController,
  ) {
    final mapState = ref.watch(mapViewModelProvider);

    return mapState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (message) => Center(child: Text(message)),
      data: (_, mapObjects) {
        final grainDtos = mapObjects?.grains ?? [];

        if (grainDtos.isEmpty) {
          return Column(
            children: [
              _buildHandle(),
              const Expanded(
                child: Center(child: Text('현재 위치에 알갱이가 없어요.\n첫 알갱이를 만들어 보세요!')),
              ),
            ],
          );
        }

        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildHandle()),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '주변 알갱이 목록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverList.builder(
              itemCount: grainDtos.length,
              itemBuilder: (context, index) {
                final grainDto = grainDtos[index];
                // [수정] 각 리스트 아이템을 Consumer로 감싸서
                // DTO의 postId를 사용해 issueGrainProvider를 개별적으로 watch 합니다.
                // 이렇게 하면 각 아이템이 필요한 전체 데이터를 스스로 가져옵니다.
                return Consumer(
                  builder: (context, ref, child) {
                    final grainAsync = ref.watch(
                      issueGrainProvider(grainDto.postId),
                    );
                    return grainAsync.when(
                      loading: () => const SizedBox(
                        height: 150,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text('게시글을 불러올 수 없습니다: $e'),
                      ),
                      data: (grain) => IssueGrainItem(
                        // [수정] 가져온 grain 객체를 전달합니다.
                        grain: grain,
                        displayMode: IssueGrainDisplayMode.boardPreview,
                        onTap: () {
                          ref
                              .read(mapSheetStrategyProvider.notifier)
                              .showGrainPreview(grain.postId);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// 바텀시트 핸들 UI
  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        width: 40,
        height: 5.0,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
