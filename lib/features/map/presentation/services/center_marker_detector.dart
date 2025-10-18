import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mongle_flutter/features/map/data/models/map_objects_response.dart';
import 'package:mongle_flutter/features/map/presentation/services/map_distance_calculator.dart';

/// 화면 중앙 마커 감지 결과
class CenterMarkerDetectionResult {
  /// 감지된 마커 (없으면 null)
  final IssueGrainDto? marker;

  /// 중앙으로부터의 거리 (미터)
  final double? distanceMeters;

  /// 임계값 내에 있는지 여부
  final bool isWithinThreshold;

  const CenterMarkerDetectionResult({
    this.marker,
    this.distanceMeters,
    required this.isWithinThreshold,
  });

  /// 마커 없음 (빈 결과)
  const CenterMarkerDetectionResult.empty()
    : marker = null,
      distanceMeters = null,
      isWithinThreshold = false;

  /// 디버깅용 문자열
  @override
  String toString() {
    if (marker == null) {
      return 'CenterMarkerDetectionResult(없음)';
    }
    return 'CenterMarkerDetectionResult('
        'postId: ${marker!.postId}, '
        'distance: ${distanceMeters?.toStringAsFixed(1)}m, '
        'withinThreshold: $isWithinThreshold)';
  }
}

/// 화면 중앙에 위치한 마커를 감지하는 서비스
///
/// 책임:
/// - 중앙 좌표와 가장 가까운 마커 찾기
/// - 임계값 기반 판정
/// - 히스테리시스 로직 적용
class CenterMarkerDetector {
  /// 현재 활성화된 마커 (히스테리시스 추적용)
  String? _currentActiveMarkerId;

  /// 화면 중앙에서 가장 가까운 마커를 감지
  ///
  /// [centerPosition]: 화면 중앙 좌표
  /// [markers]: 검사할 마커 목록
  /// [zoomLevel]: 현재 줌 레벨
  /// 반환: 감지 결과
  CenterMarkerDetectionResult detectCenterMarker({
    required NLatLng centerPosition,
    required List<IssueGrainDto> markers,
    required double zoomLevel,
  }) {
    // 1. 마커가 없으면 빈 결과 반환
    if (markers.isEmpty) {
      _currentActiveMarkerId = null;
      return const CenterMarkerDetectionResult.empty();
    }

    // 2. 중앙에서 가장 가까운 마커 찾기
    IssueGrainDto? closestMarker;
    double minDistance = double.infinity;

    for (final marker in markers) {
      final markerPosition = NLatLng(marker.latitude, marker.longitude);
      final distance = MapDistanceCalculator.calculateDistance(
        centerPosition,
        markerPosition,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestMarker = marker;
      }
    }

    // 3. 가장 가까운 마커가 없으면 빈 결과
    if (closestMarker == null) {
      _currentActiveMarkerId = null;
      return const CenterMarkerDetectionResult.empty();
    }

    // 4. 히스테리시스 적용
    final isCurrentlyActive = _currentActiveMarkerId == closestMarker.postId;
    final threshold = MapDistanceCalculator.getHysteresisThreshold(
      zoomLevel,
      !isCurrentlyActive, // 현재 활성화 안 되어 있으면 활성화 임계값 사용
    );

    final isWithinThreshold = minDistance <= threshold;

    // 5. 활성화 상태 업데이트
    if (isWithinThreshold) {
      _currentActiveMarkerId = closestMarker.postId;
    } else if (isCurrentlyActive) {
      // 히스테리시스: 현재 활성화된 마커는 더 먼 거리까지 허용됨
      _currentActiveMarkerId = null;
    }

    return CenterMarkerDetectionResult(
      marker: closestMarker,
      distanceMeters: minDistance,
      isWithinThreshold: isWithinThreshold,
    );
  }

  /// 상태 초기화 (지도 이동이 크게 일어났을 때 호출)
  void reset() {
    _currentActiveMarkerId = null;
  }

  /// 현재 활성화된 마커 ID 조회
  String? get currentActiveMarkerId => _currentActiveMarkerId;
}
