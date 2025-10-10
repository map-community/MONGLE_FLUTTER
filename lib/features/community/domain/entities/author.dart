import 'package:freezed_annotation/freezed_annotation.dart';

part 'author.freezed.dart';
part 'author.g.dart';

// json에서 'id' 키를 먼저 찾고, 없으면 'authorId' 키를 대신 사용합니다.
Object? _readAuthorId(Map json, String key) => json['id'] ?? json['authorId'];

@freezed
abstract class Author with _$Author {
  const factory Author({
    @JsonKey(readValue: _readAuthorId) required String? id,
    required String nickname,
    String? profileImageUrl,
  }) = _Author;

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);
}
