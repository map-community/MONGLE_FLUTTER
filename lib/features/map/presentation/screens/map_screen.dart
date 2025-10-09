// lib/features/map/presentation/screens/map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
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
import 'package:mongle_flutter/features/map/providers/map_providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // 👇 에러 상태를 추적하기 위한 변수
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    // 👇 ref.listen은 반드시 build 메서드 안에서 호출해야 합니다!
    ref.listen<MapState>(mapViewModelProvider, (previous, next) {
      next.when(
        loading: () {
          // 로딩 중에는 에러 상태 해제
          if (_hasError) {
            setState(() => _hasError = false);
          }
        },
        error: (message) {
          print("🔴 [MapScreen] 에러 감지: $message");
          // 에러 플래그 설정
          if (!_hasError) {
            setState(() => _hasError = true);
          }

          // SnackBar 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message)),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        data: (_, mapObjects, __) {
          // 데이터가 성공적으로 로드되면 에러 상태 해제
          if (mapObjects != null && _hasError) {
            setState(() => _hasError = false);
          } else if (mapObjects == null && !_hasError) {
            // mapObjects가 null이면 에러 상태로 설정
            setState(() => _hasError = true);
          }
        },
      );
    });
    final mapState = ref.watch(mapViewModelProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetState = ref.watch(mapSheetStrategyProvider);
    final selectedGrainId = sheetState.selectedGrainId;

    final List<double> snapSizes;
    if (selectedGrainId != null) {
      snapSizes = [peekFraction, grainPreviewFraction, fullFraction];
    } else {
      snapSizes = [peekFraction];
    }

    final canPop = sheetState.mode == SheetMode.minimized;
    final isFabVisible = sheetState.mode == SheetMode.minimized;

    final NLatLng initialPosition =
        mapState.whenOrNull(data: (pos, _, __) => pos) ??
        const NLatLng(35.890, 128.612);

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
            // 1. 지도 (항상 표시)
            MapView(
              initialPosition: initialPosition,
              bottomPadding: screenHeight * sheetState.height,
            ),

            // 👇 2. 에러 오버레이 (반투명 검은색 + 인디케이터 + 재시도 버튼)
            if (_hasError)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '서버 연결 중...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '10초마다 자동으로 재시도합니다',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          print("🔄 [MapScreen] 수동 재시도 버튼 클릭");
                          ref.read(mapViewModelProvider.notifier).retry();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('지금 다시 시도'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 👇 3. 초기 로딩 오버레이 (밝은 배경)
            mapState.whenOrNull(
                  loading: () => Container(
                    color: Colors.white,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            '지도를 불러오는 중...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ) ??
                const SizedBox.shrink(),

            // 4. FAB
            // 4. FAB
            Positioned(
              right: 16,
              bottom: (screenHeight * peekFraction) + 16,
              child: AnimatedOpacity(
                opacity: isFabVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !isFabVisible,
                  child: Material(
                    color: const Color(0xFF3182F6),
                    borderRadius: BorderRadius.circular(24),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        context.push('/write');
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14, // 👈 좌우 여백 조절
                          vertical: 10, // 👈 상하 여백 조절
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_location_alt,
                              color: Colors.white,
                              size: 20, // 👈 아이콘 크기
                            ),
                            const SizedBox(width: 6), // 👈 아이콘-텍스트 간격
                            const Text(
                              '알갱이 만들기',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13, // 👈 텍스트 크기
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 5. 바텀시트
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

            // 6. 댓글 입력창
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

  Widget _buildDefaultSheet(ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildHandle(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app_outlined, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                "지도에서 알갱이를 선택해 보세요",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

  Widget _buildLocalFeedSheet(
    BuildContext context,
    ScrollController scrollController,
  ) {
    final mapState = ref.watch(mapViewModelProvider);

    final NLatLngBounds? visibleBounds = mapState.whenOrNull(
      data: (initialPosition, mapObjects, currentBounds) => currentBounds,
    );

    if (visibleBounds == null) {
      return Column(
        children: [
          _buildHandle(),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      );
    }

    final nearbyGrainsAsync = ref.watch(nearbyGrainsProvider(visibleBounds));

    return nearbyGrainsAsync.when(
      loading: () => Column(
        children: [
          _buildHandle(),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
      error: (e, _) => Column(
        children: [
          _buildHandle(),
          Expanded(child: Center(child: Text('오류: $e'))),
        ],
      ),
      data: (paginatedPosts) {
        final posts = paginatedPosts.posts;

        if (posts.isEmpty) {
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
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return IssueGrainItem(
                  grain: post,
                  displayMode: IssueGrainDisplayMode.boardPreview,
                  onTap: () {
                    ref
                        .read(mapSheetStrategyProvider.notifier)
                        .showGrainPreview(post.postId);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

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
