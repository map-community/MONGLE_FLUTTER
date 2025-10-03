import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongle_flutter/core/services/profanity_filter_service.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

part 'write_grain_providers.freezed.dart';

// 파일 업로드 규칙을 상수로 관리합니다. (백엔드와 동일하게)
class PostFileUploadConstants {
  static const int maxFileCount = 10;
  static const int maxVideoCount = 1;
  static const int maxTotalImageSizeBytes = 50 * 1024 * 1024; // 50MB
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSizeBytes = 100 * 1024 * 1024; // 100MB
}

// -----------------------------------------------------------------------------
// 데이터 모델 (Data Models)
// -----------------------------------------------------------------------------

/// 글쓰기 화면의 모든 상태를 담고 있는 데이터 클래스입니다.
@freezed
abstract class WriteGrainState with _$WriteGrainState {
  const factory WriteGrainState({
    @Default(false) bool isSubmitting,
    String? errorMessage,
    @Default([]) List<XFile> photos,
    @Default([]) List<XFile> videos,
  }) = _WriteGrainState;
}

// -----------------------------------------------------------------------------
// 상태 관리자 (State Notifier)
// -----------------------------------------------------------------------------

/// 글쓰기 화면의 모든 비즈니스 로직을 처리하는 '두뇌' 역할을 합니다.
class WriteGrainNotifier extends StateNotifier<WriteGrainState> {
  final Ref _ref;
  final ImagePicker _picker = ImagePicker();

  WriteGrainNotifier(this._ref) : super(const WriteGrainState());

  /// 사용자의 갤러리를 열어 사진/동영상을 선택하게 합니다.
  Future<void> pickMedia() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    // ✅ [수정] 파일 선택 직후 1차 유효성 검사
    // 1. 총 파일 개수 검사
    if ((state.photos.length + state.videos.length + pickedFiles.length) >
        PostFileUploadConstants.maxFileCount) {
      state = state.copyWith(
        errorMessage:
            '파일은 최대 ${PostFileUploadConstants.maxFileCount}개까지 첨부할 수 있습니다.',
      );
      return;
    }

    final List<XFile> newPhotos = [];
    final List<XFile> newVideos = [];

    for (final file in pickedFiles) {
      final lowercasedPath = file.path.toLowerCase();
      if (lowercasedPath.endsWith('.mp4') ||
          lowercasedPath.endsWith('.mov') ||
          lowercasedPath.endsWith('.avi')) {
        newVideos.add(file);
      } else {
        newPhotos.add(file);
      }
    }

    // 2. 총 비디오 개수 검사
    if ((state.videos.length + newVideos.length) >
        PostFileUploadConstants.maxVideoCount) {
      state = state.copyWith(
        errorMessage:
            '동영상은 최대 ${PostFileUploadConstants.maxVideoCount}개까지 첨부할 수 있습니다.',
      );
      return;
    }

    // 모든 검사를 통과하면 상태에 추가
    state = state.copyWith(
      photos: [...state.photos, ...newPhotos],
      videos: [...state.videos, ...newVideos],
    );
  }

  /// 선택된 사진 목록에서 특정 사진을 제거합니다.
  void removePhoto(XFile file) {
    state = state.copyWith(
      photos: state.photos.where((p) => p.path != file.path).toList(),
    );
  }

  /// 선택된 동영상 목록에서 특정 동영상을 제거합니다.
  void removeVideo(XFile file) {
    state = state.copyWith(
      videos: state.videos.where((v) => v.path != file.path).toList(),
    );
  }

  /// 단일 파일을 Presigned URL로 업로드하는 헬퍼(도우미) 함수입니다.
  Future<void> _uploadFileToPresignedUrl(XFile file, String url) async {
    final dio = Dio();
    // [수정] 파일 내용을 읽기 전에, 전체 크기만 먼저 알아냅니다.
    final fileSize = await file.length();

    // [수정] readAsBytes() 대신 openRead()를 사용하여 파일 스트림을 엽니다.
    // 이 스트림은 파일을 조금씩 청크 단위로 읽어옵니다.
    final stream = file.openRead();

    // 파일 경로의 확장자를 기반으로 MIME 타입을 찾습니다. (예: 'image/jpeg')
    final mimeType = lookupMimeType(file.path);

    // S3 Presigned URL은 일반적으로 PUT 요청을 사용합니다.
    await dio.put(
      url,
      // [수정] 파일을 통째로 보내는 대신, 파일 스트림을 그대로 전달합니다.
      // Dio가 스트림을 읽으면서 알아서 청크 단위로 네트워크에 전송합니다.
      data: stream,
      options: Options(
        headers: {
          // 미리 구해둔 전체 파일 크기를 헤더에 명시합니다.
          Headers.contentLengthHeader: fileSize,
          if (mimeType != null) Headers.contentTypeHeader: mimeType,
        },
      ),
    );
  }

  /// 파일 유효성을 검사하는 private 헬퍼 메서드
  Future<String?> _validateFiles() async {
    final photos = state.photos;
    final videos = state.videos;

    // 1. 총 파일 개수
    if (photos.length + videos.length > PostFileUploadConstants.maxFileCount) {
      return '파일은 최대 ${PostFileUploadConstants.maxFileCount}개까지 첨부할 수 있습니다.';
    }
    // 2. 총 비디오 개수
    if (videos.length > PostFileUploadConstants.maxVideoCount) {
      return '동영상은 최대 ${PostFileUploadConstants.maxVideoCount}개까지 첨부할 수 있습니다.';
    }

    // 3. 개별 파일 용량 및 총 이미지 용량 계산
    int totalImageSize = 0;
    for (final photo in photos) {
      final size = await photo.length();
      if (size > PostFileUploadConstants.maxImageSizeBytes) {
        return '이미지 파일 크기는 각각 ${PostFileUploadConstants.maxImageSizeBytes / 1024 / 1024}MB를 초과할 수 없습니다.';
      }
      totalImageSize += size;
    }
    for (final video in videos) {
      final size = await video.length();
      if (size > PostFileUploadConstants.maxVideoSizeBytes) {
        return '동영상 파일 크기는 ${PostFileUploadConstants.maxVideoSizeBytes / 1024 / 1024}MB를 초과할 수 없습니다.';
      }
    }

    // 4. 총 이미지 용량
    if (totalImageSize > PostFileUploadConstants.maxTotalImageSizeBytes) {
      return '총 이미지 파일 용량은 ${PostFileUploadConstants.maxTotalImageSizeBytes / 1024 / 1024}MB를 초과할 수 없습니다.';
    }

    // 모든 검사를 통과하면 null 반환
    return null;
  }

  /// '게시' 버튼을 눌렀을 때 실행되는 메인 제출 로직입니다.
  Future<bool> submitPost({required String content}) async {
    // --- 1. 유효성 검사 (내용, 비속어, 파일) ---
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

    // ✅ [수정] 파일 유효성 검사 로직 호출
    final fileValidationError = await _validateFiles();
    if (fileValidationError != null) {
      state = state.copyWith(errorMessage: fileValidationError);
      return false;
    }

    // --- 2. 로딩 상태 시작 및 데이터 준비 ---
    // (이하 로직은 기존과 동일)
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final repository = _ref.read(issueGrainRepositoryProvider);
      final position = await Geolocator.getCurrentPosition();
      final allFiles = [...state.photos, ...state.videos];

      if (allFiles.isEmpty) {
        await repository.createPost(
          content: content,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } else {
        final List<UploadFileInfo> filesToRequest = await Future.wait(
          allFiles
              .map(
                (file) async => UploadFileInfo(
                  fileName: file.name,
                  fileSize: await file.length(),
                ),
              )
              .toList(),
        );
        final List<IssuedUrlInfo> issuedUrls = await repository
            .requestUploadUrls(files: filesToRequest);
        await Future.wait(
          List.generate(
            allFiles.length,
            (index) => _uploadFileToPresignedUrl(
              allFiles[index],
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

// -----------------------------------------------------------------------------
// 프로바이더 (Provider)
// -----------------------------------------------------------------------------

/// UI와 WriteGrainNotifier를 연결하는 Riverpod 프로바이더입니다.
/// autoDispose를 사용하여 화면을 벗어나면 상태가 자동으로 초기화됩니다.
final writeGrainProvider =
    StateNotifierProvider.autoDispose<WriteGrainNotifier, WriteGrainState>(
      (ref) => WriteGrainNotifier(ref),
    );

/// ProfanityFilterService를 제공하는 간단한 프로바이더 (예시)
final profanityFilterProvider = Provider((ref) => ProfanityFilterService());
