import 'dart:io';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mime/mime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:mongle_flutter/core/services/profanity_filter_service.dart';

part 'write_grain_providers.freezed.dart';

/// 파일 업로드 관련 상수 클래스
class PostFileUploadConstants {
  static const int maxFileCount = 10;
  static const int maxVideoCount = 1;
  static const int maxTotalImageSizeBytes = 50 * 1024 * 1024; // 50MB
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSizeBytes = 100 * 1024 * 1024; // 100MB

  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];
  static const List<String> allowedVideoExtensions = ['mp4', 'mov', 'avi'];
}

/// 글쓰기 화면의 상태를 관리하는 클래스 (freezed 사용)
@freezed
abstract class WriteGrainState with _$WriteGrainState {
  const factory WriteGrainState({
    @Default(false) bool isSubmitting,
    String? errorMessage,
    @Default([]) List<AssetEntity> photos,
    @Default([]) List<AssetEntity> videos,
  }) = _WriteGrainState;
}

/// 글쓰기 상태를 관리하는 StateNotifier
class WriteGrainNotifier extends StateNotifier<WriteGrainState> {
  final Ref _ref;

  WriteGrainNotifier(this._ref) : super(const WriteGrainState());

  /// wechat_assets_picker를 사용하여 갤러리에서 미디어를 선택하는 메서드
  Future<void> pickMediaWithAssetsPicker(BuildContext context) async {
    try {
      final remainingSlots =
          PostFileUploadConstants.maxFileCount -
          (state.photos.length + state.videos.length);

      if (remainingSlots <= 0) {
        state = state.copyWith(
          errorMessage:
              '파일은 최대 ${PostFileUploadConstants.maxFileCount}개까지 첨부할 수 있습니다.',
        );
        return;
      }

      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          dragToSelect: false,
          maxAssets: remainingSlots,
          requestType: RequestType.common, // 사진 + 동영상
          specialPickerType: SpecialPickerType.noPreview,
          textDelegate: const KoreanAssetPickerTextDelegate(),
          pickerTheme: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );

      if (result == null || result.isEmpty) return;

      final List<AssetEntity> newPhotos = [];
      final List<AssetEntity> newVideos = [];

      for (final asset in result) {
        if (asset.type == AssetType.video) {
          newVideos.add(asset);
        } else if (asset.type == AssetType.image) {
          newPhotos.add(asset);
        }
      }

      if ((state.videos.length + newVideos.length) >
          PostFileUploadConstants.maxVideoCount) {
        state = state.copyWith(
          errorMessage:
              '동영상은 최대 ${PostFileUploadConstants.maxVideoCount}개까지 첨부할 수 있습니다.',
        );
        return;
      }

      // ================== FIX START ==================
      // 파일 크기를 확인하는 로직을 올바르게 수정합니다.
      for (final photo in newPhotos) {
        final file = await photo.file;
        if (file == null) continue; // 파일 접근 불가 시 건너뜀
        final size = await file.length();
        if (size > PostFileUploadConstants.maxImageSizeBytes) {
          state = state.copyWith(errorMessage: '이미지 파일은 개별 10MB를 초과할 수 없습니다.');
          return;
        }
      }

      for (final video in newVideos) {
        final file = await video.file;
        if (file == null) continue;
        final size = await file.length();
        if (size > PostFileUploadConstants.maxVideoSizeBytes) {
          state = state.copyWith(errorMessage: '동영상 파일은 100MB를 초과할 수 없습니다.');
          return;
        }
      }

      int totalImageSize = 0;
      for (final photo in [...state.photos, ...newPhotos]) {
        final file = await photo.file;
        if (file == null) continue;
        totalImageSize += await file.length();
      }
      // =================== FIX END ===================

      if (totalImageSize > PostFileUploadConstants.maxTotalImageSizeBytes) {
        state = state.copyWith(errorMessage: '총 이미지 용량은 50MB를 초과할 수 없습니다.');
        return;
      }

      state = state.copyWith(
        photos: [...state.photos, ...newPhotos],
        videos: [...state.videos, ...newVideos],
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: '파일 선택 중 오류가 발생했습니다: $e');
    }
  }

  void removePhoto(AssetEntity asset) {
    state = state.copyWith(
      photos: state.photos.where((p) => p.id != asset.id).toList(),
    );
  }

  void removeVideo(AssetEntity asset) {
    state = state.copyWith(
      videos: state.videos.where((v) => v.id != asset.id).toList(),
    );
  }

  Future<void> _uploadFileToPresignedUrl(File file, String url) async {
    final dio = Dio();
    final fileSize = await file.length();
    final stream = file.openRead();
    final mimeType = lookupMimeType(file.path);

    await dio.put(
      url,
      data: stream,
      options: Options(
        headers: {
          Headers.contentLengthHeader: fileSize,
          if (mimeType != null) Headers.contentTypeHeader: mimeType,
        },
      ),
    );
  }

  Future<String?> _validateFiles() async {
    final photos = state.photos;
    final videos = state.videos;

    if (photos.length + videos.length > PostFileUploadConstants.maxFileCount) {
      return '파일은 최대 ${PostFileUploadConstants.maxFileCount}개까지 첨부할 수 있습니다.';
    }
    if (videos.length > PostFileUploadConstants.maxVideoCount) {
      return '동영상은 최대 ${PostFileUploadConstants.maxVideoCount}개까지 첨부할 수 있습니다.';
    }

    // ================== FIX START ==================
    // 파일 유효성 검사 로직을 올바르게 수정합니다.
    int totalImageSize = 0;
    for (final photo in photos) {
      final file = await photo.file;
      if (file == null) return "일부 파일에 접근할 수 없습니다.";
      final size = await file.length();

      if (size > PostFileUploadConstants.maxImageSizeBytes) {
        return '이미지 파일 크기는 각각 ${PostFileUploadConstants.maxImageSizeBytes / 1024 / 1024}MB를 초과할 수 없습니다.';
      }
      totalImageSize += size;
    }
    for (final video in videos) {
      final file = await video.file;
      if (file == null) return "일부 파일에 접근할 수 없습니다.";
      final size = await file.length();

      if (size > PostFileUploadConstants.maxVideoSizeBytes) {
        return '동영상 파일 크기는 ${PostFileUploadConstants.maxVideoSizeBytes / 1024 / 1024}MB를 초과할 수 없습니다.';
      }
    }
    // =================== FIX END ===================

    if (totalImageSize > PostFileUploadConstants.maxTotalImageSizeBytes) {
      return '총 이미지 파일 용량은 ${PostFileUploadConstants.maxTotalImageSizeBytes / 1024 / 1024}MB를 초과할 수 없습니다.';
    }

    return null;
  }

  Future<bool> submitPost({
    required String content,
    NLatLng? designatedLocation,
  }) async {
    if (content.trim().isEmpty &&
        state.photos.isEmpty &&
        state.videos.isEmpty) {
      state = state.copyWith(errorMessage: '내용을 입력하거나 미디어를 추가해주세요.');
      return false;
    }

    final filterService = _ref.read(profanityFilterProvider);
    final foundProfanity = filterService.findFirstProfanity(content);
    if (foundProfanity != null) {
      state = state.copyWith(
        errorMessage: "'$foundProfanity'은(는) 사용할 수 없는 단어입니다.",
      );
      return false;
    }

    final fileValidationError = await _validateFiles();
    if (fileValidationError != null) {
      state = state.copyWith(errorMessage: fileValidationError);
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final repository = _ref.read(issueGrainRepositoryProvider);
      final NLatLng position;
      if (designatedLocation != null) {
        position = designatedLocation;
      } else {
        final gpsPosition = await Geolocator.getCurrentPosition();
        position = NLatLng(gpsPosition.latitude, gpsPosition.longitude);
      }

      final allAssets = [...state.photos, ...state.videos];

      if (allAssets.isEmpty) {
        await repository.createPost(
          content: content,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } else {
        final List<File> files = [];
        for (final asset in allAssets) {
          final file = await asset.file;
          if (file != null) {
            files.add(file);
          }
        }

        final List<UploadFileInfo> filesToRequest = files
            .map(
              (file) => UploadFileInfo(
                fileName: file.path.split('/').last,
                fileSize: file.lengthSync(),
              ),
            )
            .toList();

        final List<IssuedUrlInfo> issuedUrls = await repository
            .requestUploadUrls(files: filesToRequest);

        await Future.wait(
          List.generate(
            files.length,
            (index) => _uploadFileToPresignedUrl(
              files[index],
              issuedUrls[index].presignedUrl,
            ),
          ),
        );

        final fileKeyList = issuedUrls.map((info) => info.fileKey).toList();
        await repository.completePostCreation(
          content: content,
          fileKeyList: fileKeyList,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: "게시글 등록 중 오류가 발생했습니다: $e",
      );
      return false;
    }
  }
}

class KoreanAssetPickerTextDelegate extends AssetPickerTextDelegate {
  const KoreanAssetPickerTextDelegate();
  @override
  String get confirm => '확인';
  @override
  String get cancel => '취소';
  @override
  String get edit => '편집';
  @override
  String get gifIndicator => 'GIF';
  @override
  String get loadFailed => '로드 실패';
  @override
  String get original => '원본';
  @override
  String get preview => '미리보기';
  @override
  String get select => '선택';
  @override
  String get emptyList => '목록이 비어있습니다';
  @override
  String get unSupportedAssetType => '지원하지 않는 형식입니다';
  @override
  String get unableToAccessAll => '모든 파일에 접근할 수 없습니다';
  @override
  String get viewingLimitedAssetsTip => '일부 사진과 동영상만 표시됩니다';
  @override
  String get changeAccessibleLimitedAssets => '접근 가능한 사진 변경';
  @override
  String get accessAllTip =>
      '앱이 기기의 일부 파일에만 접근할 수 있습니다. 시스템 설정으로 이동하여 앱이 기기의 모든 미디어에 접근하도록 허용하세요.';
  @override
  String get goToSystemSettings => '시스템 설정으로 이동';
  @override
  String get accessLimitedAssets => '제한된 접근으로 계속';
  @override
  String get accessiblePathName => '접근 가능한 파일';
  @override
  String get sTypeAudioLabel => '오디오';
  @override
  String get sTypeImageLabel => '사진';
  @override
  String get sTypeVideoLabel => '동영상';
  @override
  String get sTypeOtherLabel => '기타';
  @override
  String get sActionPlayHint => '재생';
  @override
  String get sActionPreviewHint => '미리보기';
  @override
  String get sActionSelectHint => '선택';
  @override
  String get sActionSwitchPathLabel => '경로 변경';
  @override
  String get sActionUseCameraHint => '카메라 사용';
  @override
  String get sNameDurationLabel => '길이';
  @override
  String get sUnitAssetCountLabel => '개수';
}

final writeGrainProvider =
    StateNotifierProvider.autoDispose<WriteGrainNotifier, WriteGrainState>(
      (ref) => WriteGrainNotifier(ref),
    );

final profanityFilterProvider = Provider((ref) => ProfanityFilterService());

// --- 컴파일 에러 방지를 위한 임시 클래스 및 Provider ---
final issueGrainRepositoryProvider = Provider<IssueGrainRepository>((ref) {
  throw UnimplementedError();
});

class IssueGrainRepository {
  Future<void> createPost({
    required String content,
    required double latitude,
    required double longitude,
  }) async {}
  Future<List<IssuedUrlInfo>> requestUploadUrls({
    required List<UploadFileInfo> files,
  }) async {
    return [];
  }

  Future<void> completePostCreation({
    required String content,
    required List<String> fileKeyList,
    required double latitude,
    required double longitude,
  }) async {}
}

class UploadFileInfo {
  final String fileName;
  final int fileSize;
  UploadFileInfo({required this.fileName, required this.fileSize});
}

class IssuedUrlInfo {
  final String presignedUrl;
  final String fileKey;
  IssuedUrlInfo({required this.presignedUrl, required this.fileKey});
}
