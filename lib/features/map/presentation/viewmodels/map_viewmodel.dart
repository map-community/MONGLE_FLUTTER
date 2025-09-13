import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

part 'map_viewmodel.freezed.dart';

// 1. 지도 화면이 가질 수 있는 상태들을 정의합니다.
@freezed
class MapState with _$MapState {
  const factory MapState.loading() = _Loading;
  const factory MapState.error(String message) = _Error;
  const factory MapState.data({required NLatLng initialPosition}) = _Data;
}

// 2. 상태를 관리하고 비즈니스 로직을 수행할 ViewModel(Notifier)을 구현합니다.
class MapViewModel extends StateNotifier<MapState> {
  MapViewModel() : super(const MapState.loading()) {
    _init(); // ViewModel이 생성되자마자 초기화 로직을 실행합니다.
  }

  Future<void> _init() async {
    // 2. permission_handler로 권한 요청 및 상태 확인
    final status = await Permission.location.request();

    if (status.isGranted) {
      // 3. 권한이 허용되었다면, 위치 정보 가져오기 시도
      try {
        final position = await Geolocator.getCurrentPosition();
        state = MapState.data(
          initialPosition: NLatLng(position.latitude, position.longitude),
        );
      } catch (e) {
        state = MapState.error('위치를 가져오는 데 실패했습니다: ${e.toString()}');
      }
    } else if (status.isDenied) {
      // 4. 권한이 거부된 경우
      state = const MapState.error('위치 권한이 거부되었습니다.');
    } else if (status.isPermanentlyDenied) {
      // 5. 권한이 영구적으로 거부된 경우 (사용자가 직접 설정으로 가야 함)
      state = const MapState.error('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 허용해주세요.');
      // openAppSettings(); // 이 함수를 호출해 바로 앱 설정 화면으로 보낼 수 있습니다.
    }
  }
}

// 3. ViewModel을 앱 전역에서 사용할 수 있도록 Provider를 생성합니다.
final mapViewModelProvider =
    StateNotifierProvider.autoDispose<MapViewModel, MapState>(
      (ref) => MapViewModel(),
    );
