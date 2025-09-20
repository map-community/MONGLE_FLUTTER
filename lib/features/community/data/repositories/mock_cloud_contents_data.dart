// lib/features/community/data/repositories/mock_cloud_contents_data.dart

/// 각 클라우드 ID에 어떤 게시물 ID들이 속해있는지를 매핑하는 목업 데이터입니다.
/// Key: 클라우드의 고유 ID (예: 'static_cloud_1')
/// Value: 해당 클라우드에 속한 postId 리스트
final Map<String, List<String>> mockCloudContents = {
  // IT 5호관 (정적 클라우드)에 속한 게시물들
  'static_cloud_1': ['grain_101', 'grain_102'],

  // 중앙도서관 (정적 클라우드)에 속한 게시물들 (예시)
  'static_cloud_2': ['grain_101'],

  // 동적 클라우드에 속한 게시물들 (예시)
  'dynamic_cloud_21': ['grain_101', 'grain_102', 'grain_103'],
};
