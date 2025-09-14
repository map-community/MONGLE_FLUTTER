// lib/features/community/providers/issue_grain_providers.dart (새 파일)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/data/repositories/fake_issue_grain_repository_impl.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';

// 1. Data Layer Provider
// 앱 전역에서 IssueGrainRepository의 구현체(현재는 Fake)를 제공합니다.
// 나중에 실제 API를 사용하는 RealRepository로 교체할 때 이 부분만 수정하면 됩니다.
final issueGrainRepositoryProvider = Provider<IssueGrainRepository>((ref) {
  return FakeIssueGrainRepositoryImpl();
});

// 2. Presentation Layer Providers (UI를 위한 데이터 제공)
/// [목록용] '구름 ID'를 받아 해당 구름에 속한 이슈 알갱이 리스트를 제공하는 Provider
/// .family: 외부에서 파라미터(cloudId)를 전달받을 수 있게 해줍니다.
final issueGrainsInCloudProvider = FutureProvider.autoDispose
    .family<List<IssueGrain>, String>((ref, cloudId) {
      // 1. issueGrainRepositoryProvider를 통해 데이터 저장소의 인스턴스를 가져옵니다.
      final repository = ref.watch(issueGrainRepositoryProvider);
      // 2. 저장소의 메서드를 호출하여 데이터를 요청하고, 그 결과를 Riverpod이 관리하게 합니다.
      return repository.getIssueGrainsInCloud(cloudId);
    });

/// [단일용] '알갱이 ID'를 받아 단일 이슈 알갱이 데이터를 제공하는 Provider
final issueGrainProvider = FutureProvider.autoDispose
    .family<IssueGrain, String>((ref, grainId) {
      final repository = ref.watch(issueGrainRepositoryProvider);
      return repository.getIssueGrainById(grainId);
    });
