import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    // 상태가 변경될 때마다 리스닝하여 에러 메시지를 SnackBar로 표시합니다.
    ref.listen(writeGrainProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
                            hintText: '지금 무슨 일이 일어나고 있나요?',
                            border: InputBorder.none,
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
                tooltip: '사진/동영상 추가',
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
        '사진/동영상 최대 10개 (동영상 1개)',
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
