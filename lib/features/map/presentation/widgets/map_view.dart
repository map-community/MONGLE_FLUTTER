import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/core/providers/config_provider.dart';
import 'package:mongle_flutter/features/auth/providers/user_provider.dart';
import 'package:mongle_flutter/features/map/presentation/manager/map_overlay_manager.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/services/center_marker_detector.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_state.dart';
import 'package:mongle_flutter/features/map/presentation/strategy/map_sheet_strategy.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/center_indicator_overlay.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/marker_factory.dart';

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

  // 👇 새로 추가: 중앙 마커 감지기
  final CenterMarkerDetector _centerMarkerDetector = CenterMarkerDetector();

  Timer? _debounce;
  Timer? _throttleTimer;
  Timer? _bottomSheetDebounceTimer; // 👈 새로 추가

  // 👇 중앙 인디케이터 상태
  CenterIndicatorState _indicatorState = CenterIndicatorState.idle;

  // 👇 새로 추가: 현재 인디케이터가 가리키는 마커 ID 추적
  String? _currentCenterMarkerId;

  @override
  Widget build(BuildContext context) {
    print("🔄 [MapView] build 호출");

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
    final isButtonVisible = sheetState.mode == SheetMode.minimized;

    return Stack(
      children: [
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
          // 👇 핵심: onCameraChange에서 Throttle 처리
          onCameraChange: (reason, animated) {
            // gesture로 인한 카메라 이동만 처리
            if (reason == NCameraUpdateReason.gesture) {
              _handleCameraChangeWithThrottle();
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

        const _BottomPaddingOverlay(),

        // 👇 새로 추가: 중앙 인디케이터
        Positioned.fill(child: CenterIndicatorOverlay(state: _indicatorState)),

        // 현위치 버튼
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
    _throttleTimer?.cancel();
    _bottomSheetDebounceTimer?.cancel(); // 👈 정리
    super.dispose();
  }

  /// Throttle 처리된 카메라 변경 핸들러
  void _handleCameraChangeWithThrottle() {
    if (_throttleTimer?.isActive ?? false) return;

    _throttleTimer = Timer(const Duration(milliseconds: 150), () async {
      await _checkCenterMarkerAndUpdateIndicator();
      _prepareBottomSheetTrigger();
    });
  }

  /// 바텀시트 트리거 준비 (Debounce)
  void _prepareBottomSheetTrigger() {
    _bottomSheetDebounceTimer?.cancel();

    _bottomSheetDebounceTimer = Timer(
      const Duration(milliseconds: 200),
      () async {
        await _triggerBottomSheetIfCentered();
      },
    );
  }

  /// 중앙에 마커가 있으면 바텀시트 트리거
  Future<void> _triggerBottomSheetIfCentered() async {
    if (_mapController == null) return;

    try {
      final cameraPosition = await _mapController!.getCameraPosition();
      final centerLatLng = cameraPosition.target;
      final zoomLevel = cameraPosition.zoom;

      if (zoomLevel < 14) return;

      final mapState = ref.read(mapViewModelProvider);
      final markers =
          mapState.whenOrNull(
            data: (_, mapObjects, __) => mapObjects?.grains ?? [],
          ) ??
          [];

      final result = _centerMarkerDetector.detectCenterMarker(
        centerPosition: centerLatLng,
        markers: markers,
        zoomLevel: zoomLevel,
      );

      print("🎯 [BottomSheetTrigger] 중앙 마커 감지: $result");

      final strategyNotifier = ref.read(mapSheetStrategyProvider.notifier);
      final currentSheetState = ref.read(mapSheetStrategyProvider);

      if (result.isWithinThreshold && result.marker != null) {
        // 👇 개선: 같은 마커면 중복 호출 방지, 다른 마커면 전환
        if (currentSheetState.selectedGrainId != result.marker!.postId) {
          print("✅ [BottomSheetTrigger] 바텀시트 올림/전환: ${result.marker!.postId}");
          strategyNotifier.showGrainPreview(result.marker!.postId);
        } else {
          print("ℹ️ [BottomSheetTrigger] 같은 마커 → 유지");
        }
      } else {
        // 👇 개선: 마커 벗어났을 때만 내림 (이미 _handleMarkerChange에서 처리됨)
        // 여기서는 최종 확인만
        if (currentSheetState.mode == SheetMode.preview &&
            currentSheetState.selectedGrainId != null) {
          print("⬇️ [BottomSheetTrigger] 최종 확인: 바텀시트 내림");
          strategyNotifier.minimize();
        }
      }
    } catch (e) {
      print("⚠️ [BottomSheetTrigger] 오류: $e");
    }
  }

  /// 기존 onCameraIdle 수정 - 바텀시트 로직은 위로 이동했으므로 간소화
  void onCameraIdle() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (_mapController == null) return;

      final cameraPosition = await _mapController!.getCameraPosition();
      final currentZoom = cameraPosition.zoom;
      print("📸 현재 지도 줌 레벨: $currentZoom");

      // 최종 확인
      await _triggerBottomSheetIfCentered();

      // 데이터 페칭
      if (currentZoom > 13) {
        print("➡️ [MapView] onCameraIdle: 줌 레벨이 13보다 크므로 데이터 요청을 시작합니다.");
        final bounds = await _mapController!.getContentBounds();
        ref.read(mapViewModelProvider.notifier).fetchMapObjects(bounds);
      } else {
        print("ℹ️ 줌 레벨이 13 이하이므로 API 요청을 보내지 않습니다.");
      }
    });
  }

  /// 중앙 마커 체크 및 인디케이터 업데이트
  Future<void> _checkCenterMarkerAndUpdateIndicator() async {
    if (_mapController == null) return;

    try {
      final cameraPosition = await _mapController!.getCameraPosition();
      final centerLatLng = cameraPosition.target;
      final zoomLevel = cameraPosition.zoom;

      if (zoomLevel < 14) {
        if (_indicatorState != CenterIndicatorState.disabled) {
          setState(() {
            _indicatorState = CenterIndicatorState.disabled;
            _currentCenterMarkerId = null; // 👈 추적 초기화
          });
        }
        // 👇 새로 추가: 줌 레벨 낮아지면 바텀시트도 내림
        _handleMarkerLost();
        return;
      }

      final mapState = ref.read(mapViewModelProvider);
      final markers =
          mapState.whenOrNull(
            data: (_, mapObjects, __) => mapObjects?.grains ?? [],
          ) ??
          [];

      final result = _centerMarkerDetector.detectCenterMarker(
        centerPosition: centerLatLng,
        markers: markers,
        zoomLevel: zoomLevel,
      );

      print("🎯 [CenterMarker] 감지 결과: $result");

      // 인디케이터 상태 업데이트
      CenterIndicatorState newState;
      String? newCenterMarkerId;

      if (!result.isWithinThreshold) {
        newState = CenterIndicatorState.idle;
        newCenterMarkerId = null;
      } else if (result.distanceMeters! < 8.0) {
        newState = CenterIndicatorState.centered;
        newCenterMarkerId = result.marker?.postId;
      } else {
        newState = CenterIndicatorState.nearby;
        newCenterMarkerId = result.marker?.postId;
      }

      // 👇 핵심: 마커가 변경되었는지 확인
      final markerChanged = _currentCenterMarkerId != newCenterMarkerId;

      if (_indicatorState != newState || markerChanged) {
        setState(() {
          _indicatorState = newState;
          _currentCenterMarkerId = newCenterMarkerId;
        });

        // 👇 마커가 변경되거나 사라졌으면 바텀시트 처리
        if (markerChanged) {
          _handleMarkerChange(newCenterMarkerId);
        }
      }
    } catch (e) {
      print("⚠️ [CenterMarker] 체크 중 오류: $e");
    }
  }

  /// 👇 새로 추가: 마커 변경 시 바텀시트 처리
  void _handleMarkerChange(String? newMarkerId) {
    final currentSheetState = ref.read(mapSheetStrategyProvider);

    // 케이스 1: 마커를 벗어남 (null로 변경)
    if (newMarkerId == null) {
      if (currentSheetState.mode == SheetMode.preview) {
        print("⬇️ [MarkerChange] 마커 벗어남 → 바텀시트 내림");
        ref.read(mapSheetStrategyProvider.notifier).minimize();
      }
      return;
    }

    // 케이스 2: 다른 마커로 이동
    if (currentSheetState.selectedGrainId != null &&
        currentSheetState.selectedGrainId != newMarkerId) {
      print("🔄 [MarkerChange] 다른 마커로 이동 → Debounce 타이머만 리셋");
      // Debounce 타이머가 자연스럽게 새 마커로 전환할 것임
    }
  }

  /// 👇 새로 추가: 마커를 완전히 벗어났을 때 처리
  void _handleMarkerLost() {
    final currentSheetState = ref.read(mapSheetStrategyProvider);
    if (currentSheetState.mode == SheetMode.preview) {
      print("⬇️ [MarkerLost] 바텀시트 내림");
      ref.read(mapSheetStrategyProvider.notifier).minimize();
    }
  }
}

// 👇 기존 위젯들은 그대로 유지
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
        logoAlign: NLogoAlign.rightTop,
        logoMargin: const EdgeInsets.only(right: 12, top: 30),
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
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.3),
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
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
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
