import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/community/domain/entities/reaction_models.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

// 1. ConsumerStatefulWidget으로 변경하여 위젯 내부 상태를 관리할 수 있도록 합니다.
class InteractionToolbar extends ConsumerStatefulWidget {
  final IssueGrain grain;
  final VoidCallback? onTap;

  const InteractionToolbar({super.key, required this.grain, this.onTap});

  @override
  ConsumerState<InteractionToolbar> createState() => _InteractionToolbarState();
}

class _InteractionToolbarState extends ConsumerState<InteractionToolbar> {
  // 2. UI 즉시 반응을 위한 로컬 상태 변수들을 선언합니다.
  late int _likeCount;
  late int _dislikeCount;
  late ReactionType? _myReaction;
  bool _isUpdating = false; // 중복 요청을 막기 위한 플래그

  @override
  void initState() {
    super.initState();
    // 3. initState에서 위젯이 처음 생성될 때, 부모에게서 받은 데이터로 로컬 상태를 초기화합니다.
    _likeCount = widget.grain.likeCount;
    _dislikeCount = widget.grain.dislikeCount;
    _myReaction = widget.grain.myReaction;
  }

  // 4. 부모 위젯(IssueGrainItem)에서 전달된 grain 데이터가 변경될 때 로컬 상태도 동기화합니다.
  //    (예: 목록을 새로고침했을 때)
  @override
  void didUpdateWidget(covariant InteractionToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.grain != oldWidget.grain) {
      _likeCount = widget.grain.likeCount;
      _dislikeCount = widget.grain.dislikeCount;
      _myReaction = widget.grain.myReaction;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 조회수
          _buildStatIcon(
            context,
            icon: Icons.visibility_outlined,
            count: widget.grain.viewCount.toString(),
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),

          // 5. 좋아요: UI를 그릴 때 widget.grain 대신 로컬 상태(_myReaction, _likeCount)를 사용합니다.
          _buildStatIcon(
            context,
            icon: _myReaction == ReactionType.LIKE
                ? Icons.thumb_up
                : Icons.thumb_up_outlined,
            count: _likeCount.toString(),
            color: _myReaction == ReactionType.LIKE
                ? Colors.blueAccent
                : Colors.grey.shade600,
            onTap: () => _handleReaction(ReactionType.LIKE),
          ),
          const SizedBox(width: 8),

          // 싫어요
          _buildStatIcon(
            context,
            icon: _myReaction == ReactionType.DISLIKE
                ? Icons.thumb_down
                : Icons.thumb_down_outlined,
            count: _dislikeCount.toString(),
            color: Colors.grey.shade600,
            onTap: () => _handleReaction(ReactionType.DISLIKE),
          ),
          const SizedBox(width: 8),

          // 댓글
          _buildStatIcon(
            context,
            icon: Icons.comment_outlined,
            count: widget.grain.commentCount.toString(),
            color: Colors.grey.shade600,
            onTap: widget.onTap,
          ),
          const Spacer(),

          // 공유
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: 공유 기능 구현
            },
            iconSize: 20,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  // 6. '낙관적 UI' 로직을 처리하는 핵심 함수
  Future<void> _handleReaction(ReactionType newReaction) async {
    if (_isUpdating) return;

    final oldReaction = _myReaction;
    final oldLikeCount = _likeCount;
    final oldDislikeCount = _dislikeCount;

    setState(() {
      _isUpdating = true;
      if (_myReaction == newReaction) {
        if (newReaction == ReactionType.LIKE) _likeCount--;
        if (newReaction == ReactionType.DISLIKE) _dislikeCount--;
        _myReaction = null;
      } else {
        if (_myReaction == ReactionType.LIKE) _likeCount--;
        if (_myReaction == ReactionType.DISLIKE) _dislikeCount--;

        if (newReaction == ReactionType.LIKE) _likeCount++;
        if (newReaction == ReactionType.DISLIKE) _dislikeCount++;
        _myReaction = newReaction;
      }
    });

    try {
      final reactionNotifier = ref.read(
        reactionNotifierProvider(widget.grain.postId),
      );
      final ReactionResponse serverResponse;
      if (newReaction == ReactionType.LIKE) {
        serverResponse = await reactionNotifier.like();
      } else {
        serverResponse = await reactionNotifier.dislike();
      }

      if (mounted) {
        setState(() {
          _likeCount = serverResponse.likeCount;
          _dislikeCount = serverResponse.dislikeCount;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _myReaction = oldReaction;
          _likeCount = oldLikeCount;
          _dislikeCount = oldDislikeCount;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Widget _buildStatIcon(
    BuildContext context, {
    required IconData icon,
    required String count,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
