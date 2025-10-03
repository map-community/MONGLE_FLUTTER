import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mongle_flutter/features/auth/domain/entities/token_info.dart';

// 1. 이 서비스를 앱 전역에서 사용할 수 있도록 Provider로 만듭니다.
final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService(const FlutterSecureStorage());
});

// 토큰을 안전하게 저장하고 관리하는 '금고' 클래스
class TokenStorageService {
  final FlutterSecureStorage _storage;

  TokenStorageService(this._storage);

  // 저장소에 있는 Key 값들을 상수로 관리하여 오타를 방지합니다.
  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';

  // TokenInfo 객체를 통째로 받아 각 토큰을 저장합니다.
  Future<void> saveTokens(TokenInfo tokenInfo) async {
    await _storage.write(key: _accessTokenKey, value: tokenInfo.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokenInfo.refreshToken);
  }

  // AccessToken을 읽어옵니다.
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  // RefreshToken을 읽어옵니다.
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  // 모든 토큰을 삭제합니다. (로그아웃 시 사용)
  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
