import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';

/// 현재 로그인된 사용자의 Member ID(sub)를 Access Token에서 추출하여 제공하는 Provider
///
/// 토큰 읽기는 비동기 작업이므로 FutureProvider를 사용합니다.
final currentMemberIdProvider = FutureProvider<String?>((ref) async {
  // 1. TokenStorageService를 통해 저장된 AccessToken을 가져옵니다.
  final tokenStorage = ref.watch(tokenStorageServiceProvider);
  final token = await tokenStorage.getAccessToken();

  // 2. 토큰이 없으면 null을 반환합니다. (로그아웃 상태)
  if (token == null) {
    return null;
  }

  // 3. JWT는 Header, Payload, Signature 세 부분이 .으로 연결된 구조입니다.
  //    우리가 필요한 사용자 정보는 두 번째 부분(Payload)에 들어있습니다.
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null; // 유효하지 않은 토큰 형식

    final payload = parts[1];

    // Base64Url로 인코딩된 Payload를 디코딩합니다.
    // 길이가 4의 배수가 되도록 '=' 패딩을 추가해야 할 수 있습니다.
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(decoded) as Map<String, dynamic>;

    // 4. 디코딩된 정보(Map)에서 'sub' 키의 값을 찾아 반환합니다.
    final memberId = payloadMap['sub'] as String?;
    print('✅ 내 로그인 계정 ID (sub): $memberId');
    return memberId;
  } catch (e) {
    // 디코딩 과정에서 오류 발생 시 null을 반환합니다.
    print('Token decoding failed in currentMemberIdProvider: $e');
    return null;
  }
});
