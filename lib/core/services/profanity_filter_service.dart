import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:korean_profanity_filter/korean_profanity_filter.dart';
import 'package:mongle_flutter/core/utils/profanity_list.dart';

// 이 서비스의 인스턴스를 앱 전체에 제공하는 Riverpod Provider
final profanityFilterProvider = Provider<ProfanityFilterService>((ref) {
  return ProfanityFilterService();
});

/// 욕설/비속어 필터링 기능을 담당하는 서비스 클래스 (어댑터 역할)
/// 앱의 다른 부분은 korean_profanity_filter 패키지의 존재를 전혀 알 필요 없이,
/// 오직 이 클래스를 통해서만 필터링 기능을 사용하게 됩니다.
class ProfanityFilterService {
  // 생성자에서 초기 단어를 추가할 수도 있습니다.
  ProfanityFilterService() {
    // 예시: 패키지에 기본적으로 없는 단어 추가
    ProfanityFilter.addPattern(profanityList.join('|'));
  }

  /// 텍스트에 금칙어가 포함되어 있는지 확인하고, 발견된 첫 단어를 반환합니다.
  /// 없으면 null을 반환합니다.
  String? findFirstProfanity(String text) {
    // 1. 패키지가 기본으로 제공하는 필터로 검사
    if (text.containsBadWords) {
      // 패키지가 어떤 단어를 찾았는지 알려주므로, 그 단어를 반환합니다.
      return text.getListOfBadWords.first;
    }
    // 2. 우리가 직접 추가한 목록으로 한번 더 검사 (패키지가 놓칠 경우를 대비)
    for (final word in profanityList) {
      if (text.contains(word)) {
        return word;
      }
    }

    return null;
  }

  /// 텍스트에 금칙어가 포함되어 있는지 확인합니다.
  /// 내부적으로 korean_profanity_filter 패키지의 기능을 호출합니다.
  bool containsProfanity(String text) {
    return text.containsBadWords;
  }

  /// 텍스트의 모든 금칙어를 대체 문자로 변경합니다.
  String replaceProfanity(String text, {String replacement = '***'}) {
    return text.replaceBadWords(replacement);
  }

  /// 동적으로 금칙어 패턴을 추가합니다. (운영 기능에 활용 가능)
  void addProfanity(String pattern) {
    ProfanityFilter.addPattern(pattern);
  }
}
