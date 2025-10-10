import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/features/community/domain/entities/paginated_posts.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/map/data/repositories/fake_map_repository_impl.dart';
import 'package:mongle_flutter/features/map/data/repositories/map_repository_impl.dart';
import 'package:mongle_flutter/features/map/domain/repositories/map_repository.dart';

/// MapRepository의 구현체를 제공하는 Provider
/// 앱의 다른 부분에서는 이 Provider를 통해 MapRepository에 접근하게 됩니다.
final mapRepositoryProvider = Provider<MapRepository>((ref) {
  // 나중에 실제 백엔드를 연동할 때, 여기서 FakeMapRepositoryImpl을
  // RealMapRepositoryImpl로 교체하기만 하면 됩니다.
  // return FakeMapRepositoryImpl();
  return MapRepositoryImpl(ref.watch(dioProvider));
});

final nearbyGrainsProvider = FutureProvider.autoDispose
    .family<PaginatedPosts, NLatLngBounds>((ref, bounds) async {
      final repository = ref.watch(issueGrainRepositoryProvider);
      return repository.getNearbyGrains(bounds);
    });
