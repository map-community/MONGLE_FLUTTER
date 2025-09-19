import 'package:flutter/material.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';

class StatsAndComments extends StatelessWidget {
  final IssueGrain grain;
  const StatsAndComments({super.key, required this.grain});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 1. 탭했을 때 물결 효과를 주기 위해 InkWell 사용
      onTap: () {
        // TODO: 댓글 상세 화면으로 이동하는 로직 구현
        print('댓글 보기 탭!');
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Text(
          // 2. 여러 데이터를 하나의 문자열로 합치는 방법
          '조회수 ${grain.viewCount} · 좋아요 ${grain.likeCount} · 댓글 ${grain.commentCount}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
