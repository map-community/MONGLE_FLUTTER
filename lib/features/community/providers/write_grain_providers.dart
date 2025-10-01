import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongle_flutter/core/services/profanity_filter_service.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';

part 'write_grain_providers.freezed.dart';

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
        },
      ),
    );
  }

  /// '게시' 버튼을 눌렀을 때 실행되는 메인 제출 로직입니다.
  Future<bool> submitPost({required String content}) async {
    // --- 1. 유효성 검사 (내용, 비속어 등) ---
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

    // --- 2. 로딩 상태 시작 및 데이터 준비 ---
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final repository = _ref.read(issueGrainRepositoryProvider);
      final position = await Geolocator.getCurrentPosition();
      final allFiles = [...state.photos, ...state.videos];

      // --- 3. 파일 유무에 따른 로직 분기 ---
      if (allFiles.isEmpty) {
        // [분기 1] 파일이 없는 경우: 텍스트 데이터만 서버로 바로 전송
        await repository.createPost(
          content: content,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } else {
        // [분기 2] 파일이 있는 경우: Presigned URL 3단계 프로세스 실행

        // STEP 1: 서버에 Presigned URL 요청
        final List<UploadFileInfo> filesToRequest = await Future.wait(
          allFiles.map((file) async {
            return UploadFileInfo(
              fileName: file.name,
              fileSize: await file.length(),
            );
          }).toList(),
        );

        final List<IssuedUrlInfo> issuedUrls = await repository
            .requestUploadUrls(files: filesToRequest);

        // STEP 2: 발급받은 URL로 S3에 파일 직접 업로드
        await Future.wait(
          List.generate(allFiles.length, (index) {
            return _uploadFileToPresignedUrl(
              allFiles[index],
              issuedUrls[index].presignedUrl,
            );
          }),
        );

        // STEP 3: 서버에 최종 완료 보고 (🚨 수정된 부분)
        // issuedUrls에서 fileKey만 추출하여 하나의 통합된 리스트로 만듭니다.
        final fileKeyList = issuedUrls.map((info) => info.fileKey).toList();

        // 통합된 fileKeys 리스트를 서버에 전달합니다.
        await repository.completePostCreation(
          content: content,
          fileKeyList: fileKeyList, // 👈 photoKeys, videoKeys 대신 사용
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      // --- 4. 성공 처리 ---
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      // --- 5. 에러 처리 ---
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
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
