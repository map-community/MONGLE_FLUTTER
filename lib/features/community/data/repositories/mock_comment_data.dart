import 'dart:math';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/comment.dart';

// --- 테스트를 위한 다양한 가짜 유저 목록 ---
// ✨ [추가] 차단 테스트를 위한 악성 사용자 정의 (ID: 9999)
final _maliciousUser = Author(
  id: 'bad_user_9999',
  nickname: '악성유저',
  profileImageUrl: 'https://i.pravatar.cc/150?u=user9999',
);

final mockCurrentUser = Author(
  id: 'user_daegu_789',
  nickname: '대구토박이',
  profileImageUrl: 'https://i.pravatar.cc/150?u=user2',
);

final _mockAuthors = List.generate(
  15,
  (i) => Author(
    id: 'user_id_${i + 1}',
    nickname: '몽글러${i + 1}',
    profileImageUrl: 'https://i.pravatar.cc/150?u=user${i + 1}',
  ),
);

// --- 테스트를 위한 다양한 가짜 댓글 내용 ---
const _sampleContents = [
  '오, 정말 좋은 정보네요! 감사합니다.',
  '이거 완전 꿀팁인데요?',
  '혹시 더 자세하게 알려주실 수 있나요?',
  '저도 항상 그게 궁금했어요.',
  '와... 이건 몰랐네 ㄷㄷ',
  '좋은 글 잘 보고 갑니다~',
  'ㅋㅋㅋㅋㅋ완전 공감',
  '이따가 한번 확인해봐야겠네요.',
  '다른 분들 생각은 어떠신가요?',
  '이 문제에 대해 아시는 분 계신가요?',
];

/// postId 'grain_101'에 대한 50개의 가짜 댓글을 생성하는 함수
List<Comment> _generateLargeMockComments() {
  final List<Comment> comments = [];
  final random = Random();

  for (int i = 0; i < 50; i++) {
    final author = _mockAuthors[random.nextInt(_mockAuthors.length)];
    final hasReply = random.nextDouble() < 0.3; // 30% 확률로 대댓글 생성

    comments.add(
      Comment(
        commentId: 'comment_${50 - i}',
        content: _sampleContents[random.nextInt(_sampleContents.length)],
        author: author,
        likeCount: random.nextInt(100),
        dislikeCount: random.nextInt(5),
        createdAt: DateTime.now().subtract(
          Duration(minutes: i * 5 + random.nextInt(5)),
        ),
        replies: hasReply
            ? [
                Comment(
                  commentId: 'reply_for_${50 - i}',
                  content:
                      '${_sampleContents[random.nextInt(_sampleContents.length)]}',
                  author: _mockAuthors[random.nextInt(_mockAuthors.length)],
                  likeCount: random.nextInt(20),
                  dislikeCount: 0,
                  createdAt: DateTime.now().subtract(
                    Duration(minutes: i * 5 - 2),
                  ),
                ),
              ]
            : [],
      ),
    );
  }
  return comments;
}

// --- 최종 목업 데이터 ---
final Map<String, List<Comment>> mockCommentsData = {
  // grain_101 게시글에 대한 댓글 목록 (50개 생성)
  'grain_101': [
    // ✨ [추가] 악성 사용자가 작성한 댓글을 목록 가장 위에 추가
    Comment(
      commentId: 'comment_999',
      content: '이 글쓴이 말 다 거짓말임. 믿지 마세요.',
      author: _maliciousUser,
      likeCount: 0,
      dislikeCount: 50,
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    ..._generateLargeMockComments(), // 기존에 생성되던 50개 댓글
  ],
  'grain_102': [],
  'grain_105': _generateLargeMockComments(),
};
