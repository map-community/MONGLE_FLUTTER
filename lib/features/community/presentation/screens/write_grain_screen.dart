import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
// wechat_assets_picker 패키지를 import하여 AssetEntityImage 위젯 등을 사용합니다.
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:mongle_flutter/features/community/providers/write_grain_providers.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class WriteGrainScreen extends ConsumerStatefulWidget {
  final NLatLng? location;

  const WriteGrainScreen({super.key, this.location});

  @override
  ConsumerState<WriteGrainScreen> createState() => _WriteGrainScreenState();
}

class _WriteGrainScreenState extends ConsumerState<WriteGrainScreen> {
  final TextEditingController _textController = TextEditingController();
  static const int maxTextLength = 2000;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod provider를 통해 상태를 감시하고 notifier를 가져옵니다.
    final writeState = ref.watch(writeGrainProvider);
    final notifier = ref.read(writeGrainProvider.notifier);

    ref.listen(writeGrainProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        // 👇 위치 권한 거부
        if (next.permissionDenialType != null) {
          _showPermissionDeniedDialog(
            context,
            next.errorMessage!,
            next.permissionDenialType!,
            false,
          );
        }
        // 👇 사진 권한 거부 (추가)
        else if (next.photosPermissionDenialType != null) {
          _showPermissionDeniedDialog(
            context,
            next.errorMessage!,
            next.photosPermissionDenialType!,
            true,
          );
        } else {
          // 일반 에러는 SnackBar로 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });

    final totalMediaCount = writeState.photos.length + writeState.videos.length;
    final hasMedia = totalMediaCount > 0;
    final textLength = _textController.text.length;
    final isTextNearLimit = textLength > maxTextLength * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('알갱이 만들기'),
        actions: [
          TextButton(
            // 제출 중일 때는 버튼을 비활성화합니다.
            onPressed: writeState.isSubmitting
                ? null
                : () async {
                    FocusScope.of(context).unfocus(); // 키보드를 내립니다.
                    final success = await notifier.submitPost(
                      content: _textController.text,
                      designatedLocation: widget.location,
                    );
                    // 게시글 등록이 성공하면 이전 화면으로 돌아갑니다.
                    if (success && context.mounted) {
                      ref.invalidate(mapViewModelProvider); // 지도 데이터를 갱신합니다.
                      context.pop();
                    }
                  },
            child: const Text('등록'),
          ),
        ],
      ),
      body: AbsorbPointer(
        // 제출 중일 때 UI 상호작용을 막습니다.
        absorbing: writeState.isSubmitting,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText:
                                '지금 있는 위치에 대한 이야기를 남겨보세요!\n지도 위에 게시글이 표시됩니다.',
                            border: InputBorder.none,
                            helperText:
                                '\n\n\n\n몽글은 누구나 기분 좋게 참여할 수 있는 커뮤니티를 함께 만들어가고 있습니다. '
                                '아래와 같은 내용은 모두의 즐거운 경험을 위해 삼가주세요.\n\n'
                                '• 타인의 명예를 훼손하거나 불쾌감을 주는 행위\n'
                                '• 욕설, 비방, 음란물 등 불쾌감을 주는 내용\n'
                                '• 허위 사실 유포 및 타인 사칭\n'
                                '• 저작권 등 다른 사람의 권리를 침해하는 행위\n'
                                '• 상업적인 홍보 또는 광고성 활동\n\n'
                                '위반 시 게시물이 삭제되고 서비스 이용이 제한될 수 있습니다.',
                            helperStyle: TextStyle(
                              color: Color.fromARGB(255, 189, 189, 189),
                              fontSize: 12,
                              height: 1.5,
                            ),
                            helperMaxLines: 15,
                          ),
                          maxLines: null,
                          maxLength: maxTextLength,
                          keyboardType: TextInputType.multiline,
                          onChanged: (value) {
                            // 텍스트가 변경될 때마다 UI를 다시 빌드하여 글자 수를 업데이트합니다.
                            setState(() {});
                          },
                          // 기본 글자 수 카운터를 숨깁니다.
                          buildCounter:
                              (
                                context, {
                                required currentLength,
                                required isFocused,
                                maxLength,
                              }) {
                                return null;
                              },
                        ),
                        if (hasMedia) ...[
                          const SizedBox(height: 16),
                          // 선택된 미디어를 그리드 형태로 표시합니다.
                          _buildMediaGrid(writeState, notifier),
                        ],
                      ],
                    ),
                  ),
                ),
                // 하단 툴바 (미디어 추가 버튼, 제약 조건 정보, 글자 수 카운터)
                _buildBottomToolbar(
                  writeState,
                  notifier,
                  totalMediaCount,
                  textLength,
                  isTextNearLimit,
                ),
              ],
            ),
            // 제출 중일 때 로딩 인디케이터를 화면 중앙에 표시합니다.
            if (writeState.isSubmitting)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  // 👇 권한 거부 다이얼로그 표시
  // write_grain_screen.dart의 _showPermissionDeniedDialog 메서드만 교체

  void _showPermissionDeniedDialog(
    BuildContext context,
    String message,
    LocationPermissionDenialType denialType,
    bool isPhotoPermission,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPhotoPermission
                      ? Icons.photo_library_outlined
                      : Icons.location_off,
                  color: Colors.red.shade700,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isPhotoPermission ? '사진 권한 필요' : '위치 권한 필요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isPhotoPermission
                            ? '설정 → 권한 → 사진 및 동영상에서\n"항상 모두 허용"으로 변경해주세요'
                            : '몽글은 위치 기반 커뮤니티입니다.\n알갱이를 작성하려면 위치 권한이 필요합니다.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        foregroundColor: Colors.grey.shade700,
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:
                        (denialType == LocationPermissionDenialType.permanent ||
                            denialType ==
                                LocationPermissionDenialType.restricted)
                        ? ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await openAppSettings();
                            },
                            icon: const Icon(Icons.settings, size: 18),
                            label: const Text(
                              '설정 열기',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isPhotoPermission
                                        ? '사진 추가 버튼을 다시 눌러 권한을 허용해주세요.'
                                        : '등록 버튼을 다시 눌러 권한을 허용해주세요.',
                                  ),
                                  backgroundColor: Colors.blue.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '확인',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 선택된 사진과 동영상을 그리드로 표시하는 위젯입니다.
  Widget _buildMediaGrid(
    WriteGrainState writeState,
    WriteGrainNotifier notifier,
  ) {
    final allMedia = [...writeState.photos, ...writeState.videos];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allMedia.map((asset) {
        final isVideo = writeState.videos.contains(asset);
        return _buildMediaThumbnail(asset, notifier, isVideo);
      }).toList(),
    );
  }

  // 개별 미디어 파일의 썸네일을 생성하는 위젯입니다.
  Widget _buildMediaThumbnail(
    AssetEntity asset,
    WriteGrainNotifier notifier,
    bool isVideo,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: (MediaQuery.of(context).size.width - 40) / 2,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            // 동영상과 이미지에 따라 다른 위젯을 표시합니다.
            child: isVideo
                ? _buildVideoThumbnail(asset)
                // 사진의 경우, `wechat_assets_picker`에서 제공하는 `AssetEntityImage` 위젯을 사용하면 편리합니다.
                : AssetEntityImage(asset, isOriginal: false, fit: BoxFit.cover),
          ),
        ),
        // 삭제 버튼
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              // `asset` 타입이 `AssetEntity`이므로 notifier의 삭제 메서드를 올바르게 호출할 수 있습니다.
              if (isVideo) {
                notifier.removeVideo(asset);
              } else {
                notifier.removePhoto(asset);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  // 동영상 파일의 썸네일을 생성하는 위젯입니다.
  Widget _buildVideoThumbnail(AssetEntity asset) {
    // `AssetEntity`로부터 `File` 객체를 비동기적으로 가져옵니다.
    return FutureBuilder<File?>(
      future: asset.file,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final file = snapshot.data;
        if (file == null) {
          return const Center(child: Icon(Icons.error));
        }

        // 파일 경로를 얻은 후, `video_thumbnail` 패키지를 사용하여 썸네일 이미지를 생성합니다.
        return FutureBuilder<String?>(
          future: VideoThumbnail.thumbnailFile(
            video: file.path,
            imageFormat: ImageFormat.PNG,
            maxHeight: 160,
            quality: 75,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData &&
                snapshot.data != null) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(snapshot.data!), fit: BoxFit.cover),
                  // 동영상임을 나타내는 아이콘을 중앙에 표시합니다.
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ],
              );
            }
            // 썸네일을 로딩하는 동안 기본 아이콘을 표시합니다.
            return Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.videocam, color: Colors.grey, size: 48),
              ),
            );
          },
        );
      },
    );
  }

  // 화면 하단의 툴바 위젯입니다.
  Widget _buildBottomToolbar(
    WriteGrainState writeState,
    WriteGrainNotifier notifier,
    int totalMediaCount,
    int textLength,
    bool isTextNearLimit,
  ) {
    final videoCount = writeState.videos.length;
    final isMaxFiles = totalMediaCount >= PostFileUploadConstants.maxFileCount;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library_outlined),
                iconSize: 28,
                color: isMaxFiles ? Colors.grey : null,
                onPressed: isMaxFiles
                    ? null
                    // 올바른 메서드 이름(`pickMediaWithAssetsPicker`)을 호출하고 `context`를 전달합니다.
                    : () => notifier.pickMediaWithAssetsPicker(context),
                tooltip: '사진 추가',
              ),
              const SizedBox(width: 8),
              Expanded(
                // 파일 첨부 제약 조건을 표시하는 위젯입니다.
                child: _buildConstraintInfo(
                  totalMediaCount,
                  videoCount,
                  isMaxFiles,
                ),
              ),
              const SizedBox(width: 8),
              // 글자 수 카운터
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isTextNearLimit
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$textLength/$maxTextLength',
                  style: TextStyle(
                    fontSize: 12,
                    color: isTextNearLimit
                        ? Colors.orange
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 파일 첨부 개수와 관련된 정보를 시각적으로 표시하는 위젯입니다.
  Widget _buildConstraintInfo(
    int totalMediaCount,
    int videoCount,
    bool isMaxFiles,
  ) {
    if (totalMediaCount == 0) {
      return Text(
        '사진 최대 10개',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isMaxFiles ? Colors.red.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMaxFiles ? Colors.red.shade200 : Colors.blue.shade200,
              width: 1,
            ),
          ),
          child: Text(
            '전체 $totalMediaCount/10',
            style: TextStyle(
              fontSize: 11,
              color: isMaxFiles ? Colors.red.shade700 : Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (videoCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: videoCount >= PostFileUploadConstants.maxVideoCount
                  ? Colors.red.shade50
                  : Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: videoCount >= PostFileUploadConstants.maxVideoCount
                    ? Colors.red.shade200
                    : Colors.purple.shade200,
                width: 1,
              ),
            ),
            child: Text(
              '동영상 $videoCount/1',
              style: TextStyle(
                fontSize: 11,
                color: videoCount >= PostFileUploadConstants.maxVideoCount
                    ? Colors.red.shade700
                    : Colors.purple.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// 참조 에러를 해결하기 위한 임시 mapViewModelProvider
final mapViewModelProvider = Provider((ref) => {});
