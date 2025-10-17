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

  // ref.listen을 build 메서드 안에 배치하여 상태 변화를 감지하고 UI 부수 효과를 처리합니다.
  void _setupErrorListener() {
    ref.listen<MapState>(mapViewModelProvider, (previous, next) {
      next.when(
        loading: () {
          if (_hasError) {
            setState(() => _hasError = false);
          }
        },
        error: (message) {
          if (!_hasError) {
            setState(() => _hasError = true);
          }
          // SnackBar는 build가 완료된 후에 표시하는 것이 안전합니다.
          Future.microtask(
            () => ScaffoldMessenger.of(context).showSnackBar(
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
            ),
          );
        },
        data: (_, mapObjects, __) {
          if (mapObjects != null && _hasError) {
            setState(() => _hasError = false);
          } else if (mapObjects == null && !_hasError) {
            setState(() => _hasError = true);
          }
        },
      );
    });

    // selectedGrainId를 가져옵니다.
    final selectedGrainId = ref.watch(mapSheetStrategyProvider).selectedGrainId;

    // selectedGrainId가 유효한 값일 때만 개별 게시글 상태를 감시합니다.
    if (selectedGrainId != null && selectedGrainId.isNotEmpty) {
      ref.listen<AsyncValue>(issueGrainProvider(selectedGrainId), (_, state) {
        // 에러가 있고, 이전에 성공한 데이터가 있는 경우 (부분 실패)에만 SnackBar 표시
        if (state.hasError && state.hasValue) {
          Future.microtask(() {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('게시글 일부 정보를 불러오지 못했습니다.'),
                backgroundColor: Colors.orange[700],
              ),
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // build 메서드 내에서 리스너를 설정합니다.
    _setupErrorListener();

    // (기존 build 메서드의 나머지 코드는 동일)
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
            // notifier.showGrainPreview(selectedGrainId!);
            notifier.minimize();
            break;
          case SheetMode.preview:
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
                      selectedGrainId,
                    );
                  case SheetMode.preview:
                    return _buildPreviewCard(
                      context,
                      selectedGrainId,
                      scrollController,
                    );
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
    String? grainId,
    ScrollController scrollController,
  ) {
    // grainId가 유효하지 않을 경우 기본 시트(핸들+안내문구)를 표시합니다.
    if (grainId == null || grainId.isEmpty) {
      return _buildDefaultSheet(scrollController);
    }

    final grainAsync = ref.watch(issueGrainProvider(grainId));

    return GestureDetector(
      onTap: () {
        ref.read(mapSheetStrategyProvider.notifier).showGrainDetail(grainId);
      },
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildHandle(),
            // [핵심] 이제 when 구문은 위젯을 교체하는 대신,
            // IssueGrainItem에 어떤 파라미터를 전달할지만 결정합니다.
            grainAsync.when(
              loading: () => const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              ),
              // 👇 data와 error 블록 모두 IssueGrainItem을 호출합니다.
              data: (grain) => IssueGrainItem(
                grain: grain, // 성공 시 grain 데이터를 전달
                displayMode: IssueGrainDisplayMode.mapPreview,
              ),
              error: (e, _) => IssueGrainItem(
                error: e, // 실패 시 error 객체를 전달
                displayMode: IssueGrainDisplayMode.mapPreview,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullScrollView(
    BuildContext context,
    ScrollController scrollController,
    String? grainId,
  ) {
    // grainId가 유효하지 않을 경우 에러 메시지를 표시합니다.
    if (grainId == null || grainId.isEmpty) {
      return CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(child: _buildHandle()),
          const SliverFillRemaining(
            child: Center(child: Text("게시글 정보를 표시할 수 없습니다.")),
          ),
        ],
      );
    }

    // issueGrainProvider를 구독하여 특정 게시물의 데이터 상태를 추적합니다.
    final grainAsync = ref.watch(issueGrainProvider(grainId));

    // 댓글 무한 스크롤을 위해 스크롤 이벤트를 감지하는 리스너입니다.
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
      // 스크롤 가능한 UI 요소들을 조합하기 위해 CustomScrollView를 사용합니다.
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // 바텀시트 상단의 핸들 UI
          SliverToBoxAdapter(child: _buildHandle()),

          // [핵심 수정] grainAsync.when 구문을 아래와 같이 변경합니다.
          grainAsync.when(
            // 로딩 중일 때는 화면 전체를 차지하는 로딩 인디케이터를 표시합니다.
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),

            // 데이터 로딩 성공 시:
            data: (grain) => SliverMainAxisGroup(
              slivers: [
                // 1. 게시글 본문 위젯 (성공한 grain 데이터 전달)
                SliverToBoxAdapter(
                  child: IssueGrainItem(
                    grain: grain,
                    displayMode: IssueGrainDisplayMode.fullView,
                  ),
                ),
                // 2. 구분선
                SliverToBoxAdapter(
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade200,
                  ),
                ),
                // 3. 댓글 섹션
                CommentSection(postId: grainId),
                // 4. 하단 여백
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),

            // 데이터 로딩 실패 시:
            error: (e, _) => SliverMainAxisGroup(
              slivers: [
                // 1. 게시글 본문 위젯 (error 객체 전달)
                // IssueGrainItem은 error를 받아 뼈대는 유지하되, 내용만 에러 UI로 표시합니다.
                SliverToBoxAdapter(
                  child: IssueGrainItem(
                    error: e,
                    displayMode: IssueGrainDisplayMode.fullView,
                  ),
                ),
                // 2. 구분선 (에러가 나도 유지)
                SliverToBoxAdapter(
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade200,
                  ),
                ),
                // 3. 댓글 섹션 (에러가 나도 유지)
                CommentSection(postId: grainId),
                // 4. 하단 여백 (에러가 나도 유지)
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        ],
      ),
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
