// lib/features/map/presentation/viewmodels/map_viewmodel.dart

import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/map/data/models/map_objects_response.dart';
import 'package:mongle_flutter/features/map/domain/repositories/map_repository.dart';
import 'package:mongle_flutter/features/map/providers/map_providers.dart';
import 'package:permission_handler/permission_handler.dart';

part 'map_viewmodel.freezed.dart';

/// ## MapState: 지도 화면의 상태를 나타내는 설계도
///
/// 지도 UI를 그리는 데 필요한 모든 데이터를 담는 불변(immutable) 상태 클래스입니다.
/// Freezed를 사용하여 로딩, 에러, 데이터 로드 성공 세 가지 상태를 명확하게 표현합니다.
@freezed
class MapState with _$MapState {
  /// 로딩 중인 상태 (예: 초기 위치 정보를 가져오는 중)
  const factory MapState.loading() = _Loading;

  /// 에러가 발생한 상태
  const factory MapState.error(String message) = _Error;

  /// 데이터 로드가 성공한 상태
  const factory MapState.data({
    // 지도의 초기 카메라 위치를 설정하기 위한 좌표
    required NLatLng initialPosition,
    // API로부터 받아온 지도 객체(알갱이, 구름) 데이터. 아직 로드 전일 수 있으므로 nullable.
    MapObjectsResponse? mapObjects,
  }) = _Data;
}

/// ## MapViewModel: 지도 화면의 두뇌 (StateNotifier)
///
/// 지도와 관련된 모든 비즈니스 로직과 상태 변화를 책임지는 컨트롤 타워입니다.
/// 데이터(Repository)와 UI(View) 사이의 다리 역할을 합니다.
class MapViewModel extends StateNotifier<MapState> {
  final Ref _ref;
  final MapRepository _mapRepository;

  MapViewModel(this._ref)
    // 생성 시점에 ref를 통해 MapRepository의 구현체(지금은 Fake)를 주입받습니다.
    : _mapRepository = _ref.read(mapRepositoryProvider),
      // ViewModel이 처음 생성될 때의 초기 상태는 '로딩 중' 입니다.
      super(const MapState.loading()) {
    // 생성과 동시에 초기화 로직을 실행합니다.
    _init();
  }

  /// ViewModel이 처음 생성될 때 실행되는 초기화 메서드
  Future<void> _init() async {
    // 1. 위치 권한을 확인하고 요청합니다.
    final status = await Permission.location.request();

    if (status.isGranted) {
      // 2. 권한이 허용되었다면, 현재 GPS 위치를 가져옵니다.
      try {
        final position = await Geolocator.getCurrentPosition();
        // 3. 위치 정보를 성공적으로 가져오면, 상태를 'data'로 변경합니다.
        //    이때 지도 객체(mapObjects)는 아직 없으므로 null 입니다.
        state = MapState.data(
          initialPosition: NLatLng(position.latitude, position.longitude),
        );
      } catch (e) {
        // 위치 정보를 가져오다 실패하면 'error' 상태로 변경합니다.
        state = MapState.error('현재 위치를 가져오는 데 실패했습니다: ${e.toString()}');
      }
    } else {
      // 권한이 거부되면 'error' 상태로 변경합니다.
      state = const MapState.error('지도 서비스를 이용하려면 위치 권한이 필요합니다.');
    }
  }

  /// 지도 객체(알갱이, 구름)를 불러오는 핵심 비즈니스 로직 메서드
  Future<void> fetchMapObjects(NLatLngBounds bounds) async {
    try {
      final response = await _mapRepository.getMapObjects(bounds);

      // ✅ 2. [필터링 로직 추가]
      // 현재 차단된 사용자 목록을 가져옵니다.
      final blockedUserIds = _ref.read(blockedUsersProvider);

      // 최종적으로 지도에 표시될 데이터를 담을 변수
      MapObjectsResponse visibleMapObjects;

      if (blockedUserIds.isNotEmpty) {
        // response에서 'grains' 목록만 필터링합니다.
        final visibleGrains = response.grains.where((grain) {
          // ❗️ 중요: DTO의 ID와 Author 모델의 ID 타입을 맞춰야 합니다.
          // 우선 String으로 가정하고 진행합니다. 만약 타입이 다르다면 맞춰야 합니다.
          // (이전 단계에서 Author ID를 String으로 되돌렸다고 가정)
          return !blockedUserIds.contains(
            grain.author.id,
          ); // postId 대신 author.id로 변경
        }).toList();

        // 필터링된 grains 목록으로 새로운 MapObjectsResponse를 만듭니다.
        visibleMapObjects = response.copyWith(grains: visibleGrains);
      } else {
        // 차단 목록이 비어있으면 원본 데이터를 그대로 사용합니다.
        visibleMapObjects = response;
      }

      state.whenOrNull(
        data: (initialPosition, _) {
          state = MapState.data(
            initialPosition: initialPosition,
            // ✅ 3. 필터링된 데이터를 상태에 업데이트합니다.
            mapObjects: visibleMapObjects,
          );
        },
      );
    } catch (e) {
      state = MapState.error('지도 정보를 불러오는 데 실패했습니다: ${e.toString()}');
    }
  }
}

/// ## mapViewModelProvider: ViewModel 공급자
///
/// UI 위젯이 MapViewModel의 인스턴스에 접근할 수 있도록 해주는 전역 Provider입니다.
/// autoDispose는 지도 화면이 위젯 트리에서 제거될 때 ViewModel을 자동으로 파기하여 메모리를 절약해줍니다.
final mapViewModelProvider =
    StateNotifierProvider.autoDispose<MapViewModel, MapState>((ref) {
      // ✅ 4. [상태 감시] blockedUsersProvider를 watch 합니다.
      // 이로써 차단 목록이 변경될 때마다 MapViewModel이 재실행되고,
      // 지도 객체를 다시 불러와 필터링하게 됩니다.
      ref.watch(blockedUsersProvider);

      return MapViewModel(ref);
    });
