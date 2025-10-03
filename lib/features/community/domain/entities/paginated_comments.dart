import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';

part 'paginated_comments.freezed.dart';
part 'paginated_comments.g.dart'; // ✨ 다시 .g.dart 파일을 사용합니다.

// ✨ 1. JSON의 'data' 객체 안으로 들어가서 파싱을 시작하게 해주는 헬퍼 함수
PaginatedComments _paginatedCommentsFromJson(Map<String, dynamic> json) {
  // 'data' 키에 해당하는 값을 가져와서,
  // build_runner가 생성할 _$PaginatedCommentsFromJson 함수에 전달합니다.
  return _$PaginatedCommentsFromJson(json['data'] as Map<String, dynamic>);
}

@freezed
abstract class PaginatedComments with _$PaginatedComments {
  const factory PaginatedComments({
    // ✨ 2. 'values' 키를 'comments' 필드에 매핑하라는 규칙을 알려줍니다.
    @Default([]) List<Comment> comments,

    String? nextCursor,

    @Default(true) bool hasNext,
    // 현재 답글을 다는 대상 댓글 정보를 저장합니다. 백엔드에서 받는 정보가 아니라, 앱 내에서 상태로 관리하는 용도입니다.
    Comment? replyingTo,

    // 댓글/대댓글 전송이 진행 중인지 여부를 나타내는 UI 상태
    @Default(false) bool isSubmitting,
  }) = _PaginatedComments;

  // ✨ 3. fromJson 팩토리가 우리가 만든 헬퍼 함수를 사용하도록 연결합니다.
  factory PaginatedComments.fromJson(Map<String, dynamic> json) =>
      _paginatedCommentsFromJson(json);
}
