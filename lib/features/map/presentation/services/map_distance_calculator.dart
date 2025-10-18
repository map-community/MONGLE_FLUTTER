import 'dart:math' as math;
import 'package:flutter_naver_map/flutter_naver_map.dart';

/// 지도 상의 거리 계산 및 임계값 관리를 담당하는 유틸리티 클래스
///
/// 책임:
/// - 두 좌표 간의 거리 계산 (하버사인 공식)
/// - 줌 레벨에 따른 동적 임계값 계산
/// - 화면 픽셀 기반 거리 근사 계산
class MapDistanceCalculator {
  // 지구 반지름 (미터)
  static const double _earthRadiusMeters = 6371000.0;

  /// 두 좌표 간의 거리를 미터 단위로 계산 (하버사인 공식)
  ///
  /// [point1]: 첫 번째 좌표
  /// [point2]: 두 번째 좌표
  /// 반환: 두 지점 간의 거리 (미터)
  static double calculateDistance(NLatLng point1, NLatLng point2) {
    final lat1Rad = _degreesToRadians(point1.latitude);
    final lat2Rad = _degreesToRadians(point2.latitude);
    final deltaLatRad = _degreesToRadians(point2.latitude - point1.latitude);
    final deltaLngRad = _degreesToRadians(point2.longitude - point1.longitude);

    final a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadiusMeters * c;
  }

  /// 줌 레벨에 따른 동적 임계값 계산
  ///
  /// 줌 레벨이 높을수록 (더 확대) 더 작은 임계값 반환
  /// 줌 레벨이 낮을수록 (더 축소) 더 큰 임계값 반환
  ///
  /// [zoomLevel]: 현재 지도 줌 레벨
  /// 반환: 중앙 판정을 위한 임계값 (미터)
  static double getThresholdForZoom(double zoomLevel) {
    // 👇 줌 14 미만은 매우 큰 값 반환 (사실상 비활성화)
    if (zoomLevel < 14) {
      return 1000.0; // 1km (사실상 감지 불가)
    } else if (zoomLevel < 15) {
      return 40.0; // 줌 14: 40m
    } else if (zoomLevel < 16) {
      return 25.0; // 줌 15: 25m
    } else if (zoomLevel < 17) {
      return 15.0; // 줌 16: 15m
    } else if (zoomLevel < 18) {
      return 8.0; // 줌 17: 8m
    } else {
      return 5.0; // 줌 18+: 5m
    }
  }

  /// 히스테리시스를 적용한 임계값 계산
  ///
  /// 바텀시트를 올릴 때와 내릴 때 서로 다른 임계값 사용
  /// 이를 통해 경계선에서 떨림 현상 방지
  ///
  /// [zoomLevel]: 현재 지도 줌 레벨
  /// [isForActivation]: true면 활성화(올림) 임계값, false면 비활성화(내림) 임계값
  /// 반환: 임계값 (미터)
  static double getHysteresisThreshold(double zoomLevel, bool isForActivation) {
    final baseThreshold = getThresholdForZoom(zoomLevel);

    // 활성화(올림): 기본 임계값 사용
    // 비활성화(내림): 기본 임계값의 2배 사용
    return isForActivation ? baseThreshold : baseThreshold * 2.0;
  }

  /// 도를 라디안으로 변환
  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// 간단한 거리 비교를 위한 제곱 거리 계산 (성능 최적화용)
  ///
  /// 실제 거리가 필요 없고 상대적 비교만 필요한 경우 사용
  /// sqrt 연산을 생략하여 성능 향상
  static double calculateSquaredDistance(NLatLng point1, NLatLng point2) {
    final latDiff = point2.latitude - point1.latitude;
    final lngDiff = point2.longitude - point1.longitude;
    return latDiff * latDiff + lngDiff * lngDiff;
  }
}
