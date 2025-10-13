// [기존 코드]와 [수정된 코드]를 주석으로 구분했습니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/common/widgets/more_options_menu.dart'; // ✨ 1. [추가] 공통 메뉴 위젯 import
import 'package:mongle_flutter/features/auth/providers/user_provider.dart';
import 'package:mongle_flutter/features/community/domain/entities/author.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/entities/report_models.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/image_carousel.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/interaction_toolbar.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/user_profile_line.dart';
import 'package:mongle_flutter/features/community/providers/block_providers.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/community/providers/report_providers.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';
import 'package:timeago/timeago.dart' as timeago;

enum IssueGrainDisplayMode { mapPreview, boardPreview, fullView }

class IssueGrainItem extends ConsumerStatefulWidget {
  final IssueGrain grain;
  final VoidCallback? onTap;
  final IssueGrainDisplayMode displayMode;
  final CloudProviderParam? cloudProviderParam;

  const IssueGrainItem({
    super.key,
    required this.grain,
    this.onTap,
    this.displayMode = IssueGrainDisplayMode.mapPreview,
    this.cloudProviderParam,
  });

  @override
  ConsumerState<IssueGrainItem> createState() => _IssueGrainItemState();
}

class _IssueGrainItemState extends ConsumerState<IssueGrainItem> {
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

  Widget _buildMapPreviewLayout(BuildContext context, IssueGrain grain) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: grain.content,
        style: const TextStyle(height: 1.5, fontSize: 15),
      ),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - 32);

    final isTextOverflow = textPainter.didExceedMaxLines;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                grain.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.5, fontSize: 15),
              ),
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
    final currentMemberId = ref.watch(currentMemberIdProvider).valueOrNull;
    final isAuthor = grain.author.id == currentMemberId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          grain.author.nickname,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          timeago.format(grain.createdAt.toLocal(), locale: 'ko'),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const Spacer(),
        // 기존 PopupMenuButton을 공통 위젯으로 교체합니다.
        MoreOptionsMenu(
          contentId: grain.postId,
          contentType: ReportContentType.POST,
          author: grain.author,
          isAuthor: isAuthor,
          onDelete: () async {
            bool success;

            // [분기 1] '구름 게시판' 또는 '구름 게시판 -> 상세 페이지'에서 삭제하는 경우
            // cloudProviderParam이 존재하면 구름 게시판 관련 로직으로 처리합니다.
            if (widget.cloudProviderParam != null) {
              success = await ref
                  .read(
                    paginatedGrainsProvider(
                      widget.cloudProviderParam!,
                    ).notifier,
                  )
                  .deletePostOptimistically(grain.postId, grain.author.id!);

              // '상세 페이지'에서 삭제가 성공했다면, 이전 화면(게시판 목록)으로 돌아갑니다.
              if (success &&
                  widget.displayMode == IssueGrainDisplayMode.fullView) {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  // SnackBar는 화면 전환 후 표시해야 자연스럽습니다.
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('게시글이 삭제되었습니다.')),
                      );
                    }
                  });
                }
                return; // 여기서 함수를 종료합니다.
              }
            }
            // [분기 2] '지도' 또는 '지도 -> 상세 페이지'에서 삭제하는 경우
            else {
              success = await ref
                  .read(postCommandProvider.notifier)
                  .deletePost(grain.postId, grain.author.id!);

              if (success) {
                // '지도 위 미리보기(바텀시트)'에서 삭제한 경우
                if (widget.displayMode == IssueGrainDisplayMode.mapPreview) {
                  ref
                      .read(mapSheetStrategyProvider.notifier)
                      .minimize(); // 바텀시트를 내립니다.
                  ref
                      .read(mapViewModelProvider.notifier)
                      .retry(); // 지도 데이터를 새로고침합니다.
                }
                // '지도에서 진입한 상세 페이지'에서 삭제한 경우
                else if (widget.displayMode == IssueGrainDisplayMode.fullView) {
                  ref
                      .read(mapSheetStrategyProvider.notifier)
                      .minimize(); // 바텀시트를 내립니다.
                  ref
                      .read(mapViewModelProvider.notifier)
                      .retry(); // 지도 데이터를 새로고침합니다.

                  // 화면 전환(pop)과 SnackBar 표시는 build가 끝난 후에 안전하게 처리합니다.
                  if (context.mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        Navigator.of(context).pop(); // 상세 페이지를 닫습니다.

                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('게시글이 삭제되었습니다.')),
                            );
                          }
                        });
                      }
                    });
                  }
                  return; // 여기서 함수를 종료합니다.
                }
              }
            }

            // [공통 처리] 삭제 성공/실패에 대한 최종 SnackBar 알림
            // (상세 페이지에서 삭제 후 뒤로 가는 경우는 위에서 return 되었으므로 실행되지 않음)
            if (context.mounted) {
              if (success) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('게시글이 삭제되었습니다.')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('게시글 삭제에 실패했습니다.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
