import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// .env 파일에서 개발자 ID 목록을 읽어와 List<String> 형태로 제공하는 Provider
final developerIdsProvider = Provider<List<String>>((ref) {
  // .env 파일에서 'DEVELOPER_MEMBER_IDS' 키의 값을 문자열로 가져옵니다.
  final idsString = dotenv.env['DEVELOPER_MEMBER_IDS'];

  // 값이 비어있거나 null인 경우, 빈 리스트를 반환합니다.
  if (idsString == null || idsString.isEmpty) {
    return [];
  }

  // "id1,id2,id3" 형태의 문자열을 쉼표(,) 기준으로 잘라서 리스트로 만듭니다.
  // 중간에 공백이 있을 수 있으므로 trim()으로 양 끝 공백을 제거합니다.
  return idsString.split(',').map((id) => id.trim()).toList();
});
