import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/core/providers/config_provider.dart';
import 'package:mongle_flutter/features/auth/providers/user_provider.dart';
import 'package:mongle_flutter/features/map/presentation/manager/map_overlay_manager.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/marker_factory.dart';

// ConsumerStatefulWidget으로 위젯의 생명주기와 ref를 모두 사용합니다.
class MapView extends ConsumerStatefulWidget {
  final NLatLng initialPosition;
  final double bottomPadding;

  const MapView({
    super.key,
    required this.initialPosition,
    this.bottomPadding = 0,
  });

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  NaverMapController? _mapController;
  MapOverlayManager? _overlayManager;
  final MarkerFactory _markerFactory = MarkerFactory();
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    print("🔄 [MapView] build 호출");

    // 👇 mapObjects가 실제로 변경되었을 때만 업데이트
    ref.listen<MapState>(mapViewModelProvider, (previous, next) {
      if (previous != next) {
        next.whenOrNull(
          data: (_, mapObjects, __) {
            if (_overlayManager != null && mapObjects != null) {
              print("✅ [MapView] 오버레이 업데이트");
              _overlayManager!.updateOverlays(mapObjects);
            }
          },
        );
      }
    });

    final developerIds = ref.watch(developerIdsProvider);
    final currentMemberId = ref.watch(currentMemberIdProvider);

    final screenHeight = MediaQuery.of(context).size.height;
    final sheetState = ref.watch(mapSheetStrategyProvider);
    final isButtonVisible =
        sheetState.mode == SheetMode.minimized; // 👈 FAB과 동일

    return Stack(
      children: [
        // 👇 지도는 한 번만 빌드되고 재빌드되지 않음
        _NaverMapWidget(
          initialPosition: widget.initialPosition,
          onMapReady: (controller) {
            print("✅ [MapView] onMapReady: 지도 컨트롤러 준비 완료.");
            _mapController = controller;
            _overlayManager = MapOverlayManager(
              controller: controller,
              ref: ref,
              markerFactory: _markerFactory,
              context: context,
            );

            WidgetsBinding.instance.addPostFrameCallback((_) {
              onCameraIdle();
            });
          },
          onCameraIdle: onCameraIdle,
          onMapTapped: (point, latLng) {
            ref.read(mapSheetStrategyProvider.notifier).minimize();
          },
          onCameraChange: (reason, animated) {
            if (reason == NCameraUpdateReason.gesture) {
              final currentSheetHeight = ref
                  .read(mapSheetStrategyProvider)
                  .height;
              if (currentSheetHeight > peekFraction) {
                ref.read(mapSheetStrategyProvider.notifier).minimize();
              }
            }
          },
          onMapLongTapped: (point, latLng) {
            currentMemberId.whenData((id) {
              if (id != null && developerIds.contains(id)) {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('📍 임의 위치에 글쓰기'),
                    content: Text(
                      '이 위치에 글을 작성하시겠습니까?\n\nLat: ${latLng.latitude.toStringAsFixed(5)}\nLng: ${latLng.longitude.toStringAsFixed(5)}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          context.push('/write', extra: latLng);
                        },
                        child: const Text('작성하기'),
                      ),
                    ],
                  ),
                );
              }
            });
          },
        ),

        // 투명 오버레이
        const _BottomPaddingOverlay(),

        // 👇 커스텀 현위치 버튼 (우측 상단, 세련된 디자인)
        Positioned(
          left: 16,
          bottom: (screenHeight * peekFraction) + 16,
          child: AnimatedOpacity(
            opacity: isButtonVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !isButtonVisible,
              child: _CustomLocationButton(
                onPressed: () {
                  if (_mapController != null) {
                    _mapController!.setLocationTrackingMode(
                      NLocationTrackingMode.follow,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// 카메라 이동이 멈췄을 때 호출되는 공통 함수
  void onCameraIdle() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (_mapController == null) return;

      final cameraPosition = await _mapController!.getCameraPosition();
      final currentZoom = cameraPosition.zoom;
      print("📸 현재 지도 줌 레벨: $currentZoom");

      if (currentZoom > 13) {
        print("➡️ [MapView] onCameraIdle: 줌 레벨이 13보다 크므로 데이터 요청을 시작합니다.");
        final bounds = await _mapController!.getContentBounds();
        ref.read(mapViewModelProvider.notifier).fetchMapObjects(bounds);
      } else {
        print("ℹ️ 줌 레벨이 13 이하이므로 API 요청을 보내지 않습니다.");
      }
    });
  }
}

// 👇 지도 위젯을 별도 StatelessWidget으로 완전히 분리
class _NaverMapWidget extends StatelessWidget {
  final NLatLng initialPosition;
  final Function(NaverMapController) onMapReady;
  final Function() onCameraIdle;
  final Function(NPoint, NLatLng) onMapTapped;
  final Function(NCameraUpdateReason, bool) onCameraChange;
  final Function(NPoint, NLatLng) onMapLongTapped;

  const _NaverMapWidget({
    required this.initialPosition,
    required this.onMapReady,
    required this.onCameraIdle,
    required this.onMapTapped,
    required this.onCameraChange,
    required this.onMapLongTapped,
  });

  @override
  Widget build(BuildContext context) {
    print("🗺️ [_NaverMapWidget] build 호출 - 지도 재빌드");

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: initialPosition,
          zoom: 15,
        ),
        // 네이버 로고를 우측 상단으로
        logoAlign: NLogoAlign.rightTop,
        logoMargin: const EdgeInsets.only(right: 12, top: 30),
        // 기본 UI 요소는 모두 끄기 (커스텀으로 대체)
        scaleBarEnable: false,
        locationButtonEnable: false,
      ),
      onMapReady: onMapReady,
      onCameraIdle: onCameraIdle,
      onMapTapped: onMapTapped,
      onCameraChange: onCameraChange,
      onMapLongTapped: onMapLongTapped,
    );
  }
}

// 👇 바텀시트에 따른 투명 오버레이 (터치는 통과시킴)
class _BottomPaddingOverlay extends ConsumerWidget {
  const _BottomPaddingOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetState = ref.watch(mapSheetStrategyProvider);
    final bottomPadding = screenHeight * sheetState.height;

    print("📐 [_BottomPaddingOverlay] build 호출 - 패딩: $bottomPadding");

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: bottomPadding,
      child: IgnorePointer(child: Container(color: Colors.transparent)),
    );
  }
}

class _CustomLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CustomLocationButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6, // 👈 그림자 강화 (2 → 6)
      shadowColor: Colors.black.withOpacity(0.3), // 👈 그림자 진하게
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300, // 👈 테두리 진하게 (shade200 → shade300)
              width: 1.5, // 👈 테두리 두껍게 (1 → 1.5)
            ),
          ),
          child: const Icon(
            Icons.my_location,
            color: Color(0xFF3182F6),
            size: 22,
          ),
        ),
      ),
    );
  }
}
