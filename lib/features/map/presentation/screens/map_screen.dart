import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/comment_section.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/map_view.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/multi_stage_bottom_sheet.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // [핵심 2] Scaffold를 PopScope로 감싸기
    return PopScope(
      // 바텀시트가 최소화 상태일 때만 뒤로가기로 화면을 나갈 수 있음
      canPop: canPop, // 모드 기준으로 변경
      // 뒤로가기가 시도되었을 때 호출되는 콜백
      onPopInvoked: (didPop) {
        if (didPop) return;

        final notifier = ref.read(mapSheetStrategyProvider.notifier);
        // [핵심] 현재 모드에 따라 다음 상태를 명확하게 지시
        switch (sheetState.mode) {
          case SheetMode.full:
            notifier.showGrainPreview(selectedGrainId!);
            break;
          case SheetMode.preview:
          case SheetMode.localFeed:
            notifier.minimize();
            break;
          case SheetMode.minimized:
            break; // 아무것도 안 함
        }
      },
      child: Scaffold(
        // Stack 위젯으로 지도와 바텀시트를 겹치게 함
        body: Stack(
          children: [
            // 지도 UI (화면 전체를 차지)
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

            // 바텀시트 UI
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
                      ref,
                      scrollController,
                    );
                  case SheetMode.localFeed:
                    return _buildLocalFeedSheet(context, scrollController, ref);
                  case SheetMode.minimized:
                  default:
                    return _buildDefaultSheet(scrollController);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// [신규] 기본 상태의 바텀시트
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

  /// [신규] 미리보기 상태의 바텀시트 (고정 크기 카드)
  Widget _buildPreviewCard(
    BuildContext context,
    String grainId,
    WidgetRef ref,
    ScrollController scrollController,
  ) {
    // [수정] SingleChildScrollView로 감싸 스크롤이 가능하도록 변경
    return SingleChildScrollView(
      controller: scrollController,
      // DraggableScrollableSheet와 스크롤을 연동하기 위해 physics 설정
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          _buildHandle(),
          IssueGrainItem(
            postId: grainId,
            displayMode: IssueGrainDisplayMode.mapPreview,
            onTap: () {
              ref
                  .read(mapSheetStrategyProvider.notifier)
                  .showGrainDetail(grainId);
            },
          ),
        ],
      ),
    );
  }

  /// [신규] 전체보기 상태의 바텀시트 (스크롤 뷰)
  Widget _buildFullScrollView(
    BuildContext context,
    ScrollController scrollController,
    String grainId,
  ) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // SliverToBoxAdapter는 일반 위젯을 Sliver로 만들어줍니다.
        SliverToBoxAdapter(child: _buildHandle()),
        SliverToBoxAdapter(
          child: IssueGrainItem(
            postId: grainId,
            displayMode: IssueGrainDisplayMode.fullView,
          ),
        ),
        // 댓글과 본문 사이의 구분선
        SliverToBoxAdapter(
          child: Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
        ),
        // CommentSection은 이미 SliverList로 구현되어 있어 바로 사용 가능
        CommentSection(postId: grainId),
        // 댓글 입력창에 가려지지 않도록 하단 여백 추가
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  /// [신규] 주변 알갱이 목록을 보여주는 '로컬 피드' 위젯
  Widget _buildLocalFeedSheet(
    BuildContext context,
    ScrollController scrollController,
    WidgetRef ref,
  ) {
    // ViewModel을 통해 현재 지도에 보이는 객체들의 데이터를 가져옵니다.
    final mapState = ref.watch(mapViewModelProvider);

    return mapState.when(
      // 로딩 및 에러 상태 처리
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (message) => Center(child: Text(message)),
      // 데이터가 있을 때 UI를 그립니다.
      data: (_, mapObjects) {
        // mapObjects에서 grain(알갱이) 목록만 추출합니다.
        final grains = mapObjects?.grains ?? [];

        if (grains.isEmpty) {
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
              itemCount: grains.length,
              itemBuilder: (context, index) {
                final grain = grains[index];
                return IssueGrainItem(
                  postId: grain.postId,
                  displayMode: IssueGrainDisplayMode.boardPreview,
                  onTap: () {
                    // 아이템 클릭 시 해당 알갱이의 미리보기로 전환
                    ref
                        .read(mapSheetStrategyProvider.notifier)
                        .showGrainPreview(grain.postId);
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
