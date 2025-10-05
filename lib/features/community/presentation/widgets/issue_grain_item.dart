import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/image_carousel.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/interaction_toolbar.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/user_profile_line.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/community/providers/report_providers.dart';
import 'package:timeago/timeago.dart' as timeago;

enum IssueGrainDisplayMode { mapPreview, boardPreview, fullView }

class IssueGrainItem extends ConsumerStatefulWidget {
  final IssueGrain grain;
  final VoidCallback? onTap;
  final IssueGrainDisplayMode displayMode;

  const IssueGrainItem({
    super.key,
    required this.grain,
    this.onTap,
    this.displayMode = IssueGrainDisplayMode.mapPreview,
  });

  @override
  ConsumerState<IssueGrainItem> createState() => _IssueGrainItemState();
}

class _IssueGrainItemState extends ConsumerState<IssueGrainItem> {
  final GlobalKey _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final grain = widget.grain;

    Widget content;
    switch (widget.displayMode) {
      case IssueGrainDisplayMode.mapPreview:
        content = _buildMapPreviewLayout(context, grain);
        break;
      case IssueGrainDisplayMode.boardPreview:
        content = _buildBoardPreviewLayout(context, grain);
        break;
      case IssueGrainDisplayMode.fullView:
        content = _buildFullLayout(context, grain);
        break;
    }

    if (widget.displayMode == IssueGrainDisplayMode.mapPreview) {
      return content;
    }

    return InkWell(onTap: widget.onTap, child: content);
  }

  /// 지도 미리보기 전용 레이아웃입니다. (단순 카드 형태)
  Widget _buildMapPreviewLayout(BuildContext context, IssueGrain grain) {
    // 1. TextPainter를 사용해 텍스트가 3줄을 넘어가는지 미리 계산합니다.
    final textPainter =
        TextPainter(
          text: TextSpan(
            text: grain.content,
            style: const TextStyle(height: 1.5, fontSize: 15),
          ),
          maxLines: 3, // 미리보기에서는 최대 3줄로 제한
          textDirection: TextDirection.ltr,
        )..layout(
          maxWidth: MediaQuery.of(context).size.width - 32,
        ); // 양쪽 패딩(16*2) 제외

    // 텍스트가 실제로 3줄을 넘어가는지 여부를 저장합니다.
    final isTextOverflow = textPainter.didExceedMaxLines;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      // [핵심 수정] Expanded가 없는 단순 Column으로 변경
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Column이 내용물 만큼의 높이만 차지하도록 설정
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              UserProfileLine(profileImageUrl: grain.author.profileImageUrl),
              const SizedBox(width: 8),
              Expanded(child: _buildAuthorRow(context, grain)),
            ],
          ),
          const SizedBox(height: 16),

          // Column을 사용하여 텍스트 관련 위젯들을 세로로 쌓습니다.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. 기본 텍스트를 표시합니다. (넘치면 ...으로 자동 처리)
              Text(
                grain.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.5, fontSize: 15),
              ),

              // 3. [핵심] 텍스트가 3줄을 넘어갈 경우에만 '...더보기'를 표시합니다.
              if (isTextOverflow)
                const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    "...더보기",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // 4. [핵심] 사진이 있을 경우에만, 요청하신 사진 개수 위젯을 표시합니다.
              if (grain.photoUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '사진 ${grain.photoUrls.length}장 보기',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          InteractionToolbar(grain: grain, onTap: widget.onTap),
        ],
      ),
    );
  }

  Widget _buildBoardPreviewLayout(BuildContext context, IssueGrain grain) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _buildBoardPreviewContent(context, ref, grain),
        ),
        Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _buildBoardPreviewContent(
    BuildContext context,
    WidgetRef ref,
    IssueGrain grain,
  ) {
    const maxLinesForBoardPreview = 5;
    final textPainter = TextPainter(
      text: TextSpan(
        text: grain.content,
        style: const TextStyle(height: 1.5, fontSize: 15),
      ),
      maxLines: maxLinesForBoardPreview,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 64);
    final isTextOverflow = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UserProfileLine(profileImageUrl: grain.author.profileImageUrl),
            const SizedBox(width: 8),
            Expanded(child: _buildAuthorRow(context, grain)),
          ],
        ),
        const SizedBox(height: 16),
        if (isTextOverflow)
          InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grain.content,
                  maxLines: maxLinesForBoardPreview,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.5, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  "...더보기",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            grain.content,
            style: const TextStyle(height: 1.5, fontSize: 15),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        if (grain.photoUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ImageCarousel(imageUrls: grain.photoUrls),
          ),
        InteractionToolbar(grain: grain, onTap: widget.onTap),
      ],
    );
  }

  Widget _buildFullLayout(BuildContext context, IssueGrain grain) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserProfileLine(profileImageUrl: grain.author.profileImageUrl),
              const SizedBox(width: 8),
              Expanded(child: _buildAuthorRow(context, grain)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            grain.content,
            style: const TextStyle(height: 1.6, fontSize: 15),
          ),
          if (grain.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            ImageCarousel(imageUrls: grain.photoUrls),
          ],
          InteractionToolbar(grain: grain, onTap: widget.onTap),
        ],
      ),
    );
  }

  Widget _buildAuthorRow(BuildContext context, IssueGrain grain) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          grain.author.nickname,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          timeago.format(grain.createdAt, locale: 'ko'),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const Spacer(),
        _buildMoreMenu(context, grain),
      ],
    );
  }

  void _showBlockConfirmationDialog(BuildContext context, Author author) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('사용자 차단'),
          content: Text(
            "'${author.nickname}'님을 차단하시겠습니까?\n차단한 사용자의 모든 게시물과 댓글이 더 이상 보이지 않게 됩니다.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('차단', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // ✅ [수정] author.id가 null이 아닌지 확인하는 안전장치 추가
                final authorId = author.id;
                if (authorId != null) {
                  ref.read(blockedUsersProvider.notifier).blockUser(authorId);
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${author.nickname}님을 차단했습니다.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // IssueGrainItem 클래스 내부에 추가
  /// 게시글 우측 상단의 '더보기' 팝업 메뉴
  Widget _buildMoreMenu(BuildContext context, IssueGrain grain) {
    return PopupMenuButton<String>(
      key: _menuKey,
      icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade600),
      tooltip: '더보기',
      onSelected: (value) {
        if (value == 'report') {
          Future.delayed(
            const Duration(milliseconds: 100),
            () => _showReportReasonMenu(context, grain),
          );
        } else if (value == 'block') {
          _showBlockConfirmationDialog(context, grain.author);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'report', child: Text('신고하기')),
        const PopupMenuItem<String>(value: 'block', child: Text('이 사용자 차단하기')),
      ],
    );
  }

  void _showReportReasonMenu(BuildContext context, IssueGrain grain) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox renderBox =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    showMenu<ReportReason>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
        Offset.zero & overlay.size,
      ),
      items: ReportReason.values.map((reason) {
        return PopupMenuItem<ReportReason>(
          value: reason,
          child: Text(reason.korean),
        );
      }).toList(),
    ).then((selectedReason) {
      if (selectedReason != null) {
        ref
            .read(reportRepositoryProvider)
            .reportContent(
              contentId: grain.postId,
              contentType: ReportContentType.POST,
              reason: selectedReason,
            );
        ref
            .read(reportedContentProvider.notifier)
            .addReportedContent(
              contentId: grain.postId,
              contentType: ReportContentType.POST,
            );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다.')));
      }
    });
  }
}
