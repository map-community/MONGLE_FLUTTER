import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/comment_section.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/issue_grain_item.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
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
    final selectedGrainId = ref.watch(selectedGrainIdProvider);

    final List<double> snapSizes;
    if (selectedGrainId != null) {
      snapSizes = [peekFraction, grainPreviewFraction, fullFraction];
    } else {
      snapSizes = [peekFraction, fullFraction];
    }

    return Scaffold(
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
              // 알갱이가 선택되지 않았다면 기본 UI 표시
              if (selectedGrainId == null) {
                return _buildDefaultSheet(scrollController);
              }

              // [핵심] 시트 높이를 기준으로 '미리보기'와 '전체보기'를 분기
              final bool isPreview = sheetState.height < (fullFraction - 0.1);

              if (isPreview) {
                // 미리보기 상태: 스크롤 없는 고정 크기 카드
                return _buildPreviewCard(
                  context,
                  selectedGrainId,
                  ref,
                  scrollController,
                );
              } else {
                // 전체보기 상태: 스크롤 가능한 전체 뷰
                return _buildFullScrollView(
                  context,
                  scrollController,
                  selectedGrainId,
                );
              }
            },
          ),
        ],
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
