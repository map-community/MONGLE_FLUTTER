import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/community/providers/report_providers.dart';

/// 게시글, 댓글 등에서 공통으로 사용할 '더보기' 메뉴 위젯입니다.
class MoreOptionsMenu extends ConsumerWidget {
  /// 신고 또는 삭제 대상의 고유 ID (게시글 ID 또는 댓글 ID)
  final String contentId;

  /// 신고 대상의 타입 (게시글인지 댓글인지)
  final ReportContentType contentType;

  /// 콘텐츠 작성자 정보 (차단 시 필요)
  final Author author;

  /// 현재 사용자가 이 콘텐츠의 작성자인지 여부
  final bool isAuthor;

  /// '삭제' 메뉴를 선택했을 때 실행될 콜백 함수
  final VoidCallback onDelete;

  const MoreOptionsMenu({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.author,
    required this.isAuthor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade600),
      tooltip: '더보기',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'report':
            _showReportDialog(context, ref);
            break;
          case 'block':
            _showBlockDialog(context, ref);
            break;
          case 'delete':
            _showDeleteDialog(context);
            break;
        }
      },
      itemBuilder: (context) {
        if (isAuthor) {
          // 내가 쓴 글일 경우: '삭제' 메뉴만 반환
          return [
            PopupMenuItem<String>(
              value: 'delete',
              child: const Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('삭제', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ];
        } else {
          // 다른 사람의 글일 경우: '신고', '차단' 메뉴 반환
          return [
            PopupMenuItem<String>(
              value: 'report',
              child: const Row(
                children: [
                  Icon(Icons.report_outlined, size: 20, color: Colors.orange),
                  SizedBox(width: 12),
                  Text('신고'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block_outlined, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 12),
                  const Text('사용자 차단'),
                ],
              ),
            ),
          ];
        }
      },
    );
  }

  // 삭제 확인 다이얼로그
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '${contentType == ReportContentType.POST ? '게시글' : '댓글'} 삭제',
        ),
        content: const Text('정말로 삭제하시겠습니까?'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(dialogContext);
              onDelete(); // 부모 위젯으로부터 전달받은 삭제 함수 실행
            },
          ),
        ],
      ),
    );
  }

  // 차단 확인 다이얼로그
  void _showBlockDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('사용자 차단'),
        content: Text(
          "'${author.nickname}'님을 차단하시겠습니까?\n모든 게시물과 댓글이 보이지 않게 됩니다.",
        ),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: const Text('차단', style: TextStyle(color: Colors.red)),
            onPressed: () {
              final authorId = author.id;
              if (authorId != null) {
                ref.read(blockedUsersProvider.notifier).blockUser(authorId);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${author.nickname}님을 차단했습니다.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 신고 확인 다이얼로그 (신고 사유 선택 로직은 필요에 따라 추가)
  void _showReportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('신고하기'),
        content: Text(
          "이 ${contentType == ReportContentType.POST ? '게시글' : '댓글'}을(를) 신고하시겠습니까?",
        ),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: const Text('신고', style: TextStyle(color: Colors.orange)),
            onPressed: () {
              ref
                  .read(reportRepositoryProvider)
                  .reportContent(
                    contentId: contentId,
                    contentType: contentType,
                    reason: ReportReason.INAPPROPRIATE, // 예시: '기타 부적절한 콘텐츠'로 신고
                  );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
            },
          ),
        ],
      ),
    );
  }
}
