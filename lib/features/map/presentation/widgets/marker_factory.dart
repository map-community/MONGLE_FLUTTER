import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class MarkerFactory {
  // ⭐️ 1. 캐시 저장 타입을 NOverlayImage에서 Uint8List (이미지 데이터)로 변경합니다.
  final Map<String, Uint8List> _processedImageCache = {};

  Future<NOverlayImage> createProfileMarkerIcon({
    required BuildContext context,
    String? imageUrl,
  }) async {
    final cacheKey = (imageUrl != null && imageUrl.isNotEmpty)
        ? imageUrl
        : 'default_profile_asset';

    // 2. 가공된 이미지 데이터가 캐시에 있는지 확인합니다.
    if (_processedImageCache.containsKey(cacheKey)) {
      // 캐시된 데이터로 NOverlayImage를 '새로' 생성하여 반환합니다.
      return await NOverlayImage.fromByteArray(_processedImageCache[cacheKey]!);
    }

    // 3. 이미지 원본 데이터를 가져옵니다.
    Uint8List? imageData;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageData = await _getBytesFromUrl(imageUrl);
    }
    imageData ??= await _getBytesFromAsset('assets/images/default_profile.png');

    if (imageData != null) {
      // 이미지 데이터가 성공적으로 확보된 경우
      final Uint8List processedImageBytes = _processImage(imageData, context);
      _processedImageCache[cacheKey] = processedImageBytes;
      return await NOverlayImage.fromByteArray(processedImageBytes);
    } else {
      // 진정한 최종 안전장치
      // 네트워크와 로컬 애셋 로딩이 모두 실패한 심각한 경우입니다.
      // 이 경우, 우리가 추가하는 파일이 아닌 네이버 지도 패키지 자체에 내장된
      // 가장 기본적인 마커 아이콘을 표시합니다.
      print(
        "CRITICAL ERROR: Default asset 'assets/images/default_profile.png' could not be loaded.",
      );
      return NOverlayImage.fromAssetImage('assets/marker_icon.png');
    }
  }

  // ⭐️ 헬퍼 메서드들은 변경할 필요가 없습니다.
  Future<Uint8List?> _getBytesFromAsset(String path) async {
    try {
      final byteData = await rootBundle.load(path);
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('애셋 이미지 로드 실패: $e');
      return null;
    }
  }

  Uint8List _processImage(Uint8List bytes, BuildContext context) {
    final img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return bytes;

    img.Image processedImage = originalImage.convert(numChannels: 4);
    final img.Image resized = img.copyResizeCropSquare(
      processedImage,
      size: 100,
    );
    final img.Image circularImage = img.copyCropCircle(resized);
    final canvas = img.Image(
      width: circularImage.width + 10,
      height: circularImage.height + 10,
      numChannels: 4,
    );
    canvas.clear(img.ColorRgba8(0, 0, 0, 0));
    final primaryColor = Theme.of(context).primaryColor;
    final borderColor = img.ColorRgb8(
      primaryColor.red,
      primaryColor.green,
      primaryColor.blue,
    );
    img.fillCircle(
      canvas,
      x: canvas.width ~/ 2,
      y: canvas.height ~/ 2,
      radius: canvas.width ~/ 2,
      color: borderColor,
    );
    img.compositeImage(canvas, circularImage, dstX: 5, dstY: 5);
    return img.encodePng(canvas);
  }

  Future<Uint8List?> _getBytesFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) return response.bodyBytes;
    } catch (e) {
      print('이미지 로드 실패 (MarkerFactory): $e');
    }
    return null;
  }
}
