// lib/features/map/presentation/viewmodels/map_viewmodel.dart

import 'dart:async';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mongle_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/community/providers/report_providers.dart';
import 'package:mongle_flutter/features/map/data/models/map_objects_response.dart';
import 'package:mongle_flutter/features/map/domain/repositories/map_repository.dart';
import 'package:mongle_flutter/features/map/providers/map_providers.dart';
import 'package:permission_handler/permission_handler.dart';

part 'map_viewmodel.freezed.dart';

@freezed
class MapState with _$MapState {
  const factory MapState.loading() = _Loading;
  const factory MapState.error(String message) = _Error;
  const factory MapState.data({
    required NLatLng initialPosition,
    MapObjectsResponse? mapObjects,
    NLatLngBounds? currentBounds,
  }) = _Data;
}

class MapViewModel extends StateNotifier<MapState> {
  final Ref _ref;
  final MapRepository _mapRepository;

  // 👇 자동 재시도를 위한 Timer
  Timer? _retryTimer;

  // 👇 마지막으로 시도한 bounds (재시도 시 사용)
  NLatLngBounds? _lastAttemptedBounds;

  MapViewModel(this._ref)
    : _mapRepository = _ref.read(mapRepositoryProvider),
      super(const MapState.loading()) {
    _init();
  }

  @override
  void dispose() {
    // 👇 Timer 정리
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition();
        const knuPosition = NLatLng(35.890, 128.612);

        // 👇 disposed 체크 추가
        if (!mounted) return;

        state = MapState.data(initialPosition: knuPosition);

        final initialBounds = NLatLngBounds(
          southWest: knuPosition,
          northEast: knuPosition,
        );

        await fetchMapObjects(initialBounds);
      } catch (e) {
        if (!mounted) return;
        state = MapState.error('현재 위치를 가져오는 데 실패했습니다: ${e.toString()}');
        // 👇 에러 발생 시 재시도 타이머 시작하지 않음 (위치 권한 문제는 재시도해도 소용없음)
      }
    } else {
      if (!mounted) return;
      state = const MapState.error('지도 서비스를 이용하려면 위치 권한이 필요합니다.');
    }
  }

  /// 👇 자동 재시도 타이머 시작
  void _startRetryTimer(NLatLngBounds bounds) {
    _retryTimer?.cancel();
    _lastAttemptedBounds = bounds;

    print("⏰ [MapViewModel] 10초 후 자동 재시도 예약됨");

    _retryTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      print("🔄 [MapViewModel] 자동 재시도 시작");
      fetchMapObjects(bounds);
    });
  }

  /// 👇 수동 재시도 (UI에서 호출 가능)
  void retry() {
    if (_lastAttemptedBounds != null) {
      print("🔄 [MapViewModel] 수동 재시도 시작");
      fetchMapObjects(_lastAttemptedBounds!);
    }
  }

  Future<void> fetchMapObjects(NLatLngBounds bounds) async {
    // 👇 재시도 타이머 취소 (새로운 요청이 시작되었으므로)
    _retryTimer?.cancel();
    _lastAttemptedBounds = bounds;

    try {
      final response = await _mapRepository.getMapObjects(bounds);

      final blockedUserIds = _ref.read(blockedUsersProvider);
      final reportedContents = _ref.read(reportedContentProvider);

      final MapObjectsResponse finalMapObjects;

      if (blockedUserIds.isEmpty && reportedContents.isEmpty) {
        finalMapObjects = response;
      } else {
        final visibleGrains = response.grains.where((grain) {
          final isBlocked = blockedUserIds.contains(grain.author.id);
          if (isBlocked) return false;

          final isReported = reportedContents.any(
            (reported) =>
                reported.id == grain.postId &&
                reported.type == ReportContentType.POST,
          );
          if (isReported) return false;

          return true;
        }).toList();

        finalMapObjects = response.copyWith(grains: visibleGrains);
      }

      // 👇 disposed 체크 추가
      if (!mounted) return;

      state.whenOrNull(
        data: (initialPosition, _, __) {
          state = MapState.data(
            initialPosition: initialPosition,
            mapObjects: finalMapObjects,
            currentBounds: bounds,
          );
        },
      );

      print("✅ [MapViewModel] 지도 객체 로드 성공");
    } catch (e) {
      print("❌ [MapViewModel] fetchMapObjects 실패: $e");

      if (!mounted) return;

      // 👇 10초 후 자동 재시도 예약
      _startRetryTimer(bounds);

      // 👇 에러 발생 시 mapObjects를 null로 설정한 data 상태 유지
      // (initialPosition은 유지하여 지도는 계속 표시되도록 함)
      final currentInitialPosition =
          state.whenOrNull(data: (pos, _, __) => pos) ??
          const NLatLng(35.890, 128.612);

      state = MapState.data(
        initialPosition: currentInitialPosition,
        mapObjects: null,
        currentBounds: null,
      );
    }
  }
}

final mapViewModelProvider = StateNotifierProvider<MapViewModel, MapState>((
  ref,
) {
  ref.watch(authProvider);
  ref.watch(blockedUsersProvider);
  ref.watch(reportedContentProvider);

  return MapViewModel(ref);
});
