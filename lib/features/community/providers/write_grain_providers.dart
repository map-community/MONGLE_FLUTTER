import 'dart:io';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mime/mime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mongle_flutter/core/dio/dio_provider.dart';
import 'package:mongle_flutter/features/auth/data/data_sources/token_storage_service.dart';
import 'package:mongle_flutter/features/community/data/repositories/issue_grain_repository_impl.dart';
import 'package:mongle_flutter/features/community/domain/repositories/issue_grain_repository.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:mongle_flutter/core/services/profanity_filter_service.dart';
import 'package:permission_handler/permission_handler.dart';

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

enum LocationPermissionDenialType {
  temporary, // 일시적 거부 (다시 요청 가능)
  permanent, // 영구적 거부 (설정에서만 변경 가능)
  restricted, // 시스템 제한
}

/// 글쓰기 화면의 상태를 관리하는 클래스 (freezed 사용)
@freezed
abstract class WriteGrainState with _$WriteGrainState {
  const factory WriteGrainState({
    @Default(false) bool isSubmitting,
    String? errorMessage,
    @Default([]) List<AssetEntity> photos,
    @Default([]) List<AssetEntity> videos,
    LocationPermissionDenialType? permissionDenialType,
    LocationPermissionDenialType? photosPermissionDenialType,
    @Default(false) bool isRandomLocationEnabled,
  }) = _WriteGrainState;
}

/// 글쓰기 상태를 관리하는 StateNotifier
class WriteGrainNotifier extends StateNotifier<WriteGrainState> {
  final Ref _ref;

  WriteGrainNotifier(this._ref) : super(const WriteGrainState());

  void toggleIsRandomLocationEnabled() {
    state = state.copyWith(
      isRandomLocationEnabled: !state.isRandomLocationEnabled,
    );
  }

  Future<PermissionStatus> _checkPhotosPermission() async {
    print("🟢 [Permission 1] _checkPhotosPermission 시작");

    // 현재 권한 상태 확인
    final status = await Permission.photos.status;
    print("🟢 [Permission 2] 현재 status: $status");

    // 이미 허용(전체 또는 제한)되어 있으면 현재 상태를 그대로 반환
    if (status.isGranted || status.isLimited) {
      print("✅ [Permission 3] 이미 허용됨 (상태: $status)");
      return status;
    }

    // 권한 요청
    print("🟢 [Permission 4] 권한 요청 시작");
    final result = await Permission.photos.request();
    print("🟢 [Permission 5] 권한 요청 결과: $result");

    // 요청 결과를 그대로 반환
    return result;
  }

  // 제한된 액세스 경고 다이얼로그
  Future<bool> _showLimitedAccessWarning(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 24),
                SizedBox(width: 8),
                Expanded(
                  // 👈 추가!
                  child: Text('잠시만요!'),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '현재 일부 사진만 접근 가능합니다.\n전체 사진에 접근하려면 설정 변경이 필요합니다!',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // 👈 추가!
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        // 👈 이미 있지만 확인
                        child: Text(
                          '설정에서 앱이 모든 사진에 접근할 수 있도록 권한을 허용해주세요.',
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
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('이대로 진행'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, false);
                  openAppSettings();
                },
                icon: const Icon(Icons.settings),
                label: const Text('설정 열기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ) ??
        true;
  }

  // 위 함수에서 받은 PermissionStatus를 통해 분기 처리하도록 수정되었습니다.
  Future<void> pickMediaWithAssetsPicker(BuildContext context) async {
    print("🔵 [Step 1] pickMediaWithAssetsPicker 시작");

    print("🔵 [Step 2] _checkPhotosPermission 호출 전");
    final status = await _checkPhotosPermission();
    print("🔵 [Step 3] _checkPhotosPermission 결과: $status");

    // 권한이 허용된 경우 (전체 또는 일부)
    if (status.isGranted || status.isLimited) {
      // --- ⬇️ [핵심 수정] Android '부분 접근' 감지 로직 추가 ---
      if (Platform.isAndroid && status.isGranted) {
        // photo_manager를 통해 상세 권한 상태를 요청합니다.
        final ps = await PhotoManager.requestPermissionExtend();

        // hasAccess가 false이면 '일부 사진만 선택'한 상태입니다.
        if (!ps.hasAccess) {
          // 이 경우에만 사용자에게 안내 다이얼로그를 보여줍니다.
          await _showLimitedAccessWarning(context);
        }
      }
      // --- ⬆️ [핵심 수정] Android '부분 접근' 감지 로직 끝 ---
      // iOS에서 '제한된 접근'일 경우 (기존 로직 유지)
      else if (status.isLimited) {
        final shouldContinue = await _showLimitedAccessWarning(context);
        if (!shouldContinue) {
          return;
        }
      }

      // 사진 선택 로직 진행
      await _proceedToPickAssets(context);

      // 권한이 거부된 경우
    } else {
      print("❌ [Step 4] 권한 없음 - 에러 상태 설정 및 종료");
      if (status.isDenied) {
        state = state.copyWith(
          errorMessage: '사진 접근 권한이 필요합니다.',
          photosPermissionDenialType: LocationPermissionDenialType.temporary,
        );
      } else if (status.isPermanentlyDenied) {
        state = state.copyWith(
          errorMessage: '사진 권한이 거부되었습니다.\n설정에서 사진 권한을 허용해주세요.',
          photosPermissionDenialType: LocationPermissionDenialType.permanent,
        );
      } else if (status.isRestricted) {
        state = state.copyWith(
          errorMessage: '사진 권한이 시스템에 의해 제한되었습니다.\n기기 설정을 확인해주세요.',
          photosPermissionDenialType: LocationPermissionDenialType.restricted,
        );
      }

      // 에러 메시지가 잠시 표시되었다가 사라지도록 처리
      Future.microtask(() {
        if (mounted) {
          state = state.copyWith(
            errorMessage: null,
            photosPermissionDenialType: null,
          );
        }
      });
    }
  }

  /// [신규] 권한 확인 후 실제 사진/동영상 선택 로직을 처리하는 내부 함수
  Future<void> _proceedToPickAssets(BuildContext context) async {
    try {
      // 첨부 가능한 파일 개수를 계산합니다.
      final remainingSlots =
          PostFileUploadConstants.maxFileCount -
          (state.photos.length + state.videos.length);

      // 더 이상 첨부할 수 없으면 사용자에게 알립니다.
      if (remainingSlots <= 0) {
        state = state.copyWith(
          errorMessage:
              '파일은 최대 ${PostFileUploadConstants.maxFileCount}개까지 첨부할 수 있습니다.',
        );
        return;
      }

      // wechat_assets_picker를 사용하여 갤러리를 엽니다.
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          dragToSelect: false,
          maxAssets: remainingSlots,
          requestType: RequestType.image, // 사진 및 동영상 모두 선택 가능하도록 설정
          specialPickerType: SpecialPickerType.noPreview,
          textDelegate: const KoreanAssetPickerTextDelegate(),
          pickerTheme: Theme.of(context),
          limitedPermissionOverlayPredicate: (permissionState) => false,
        ),
      );

      // 사용자가 아무것도 선택하지 않고 갤러리를 닫으면 종료합니다.
      if (result == null || result.isEmpty) {
        return;
      }

      // 선택된 파일들을 사진과 동영상으로 분류합니다.
      final List<AssetEntity> newPhotos = [];
      final List<AssetEntity> newVideos = [];

      for (final asset in result) {
        if (asset.type == AssetType.video) {
          newVideos.add(asset);
        } else if (asset.type == AssetType.image) {
          newPhotos.add(asset);
        }
      }

      // 동영상 개수 제약 조건을 확인합니다.
      if ((state.videos.length + newVideos.length) >
          PostFileUploadConstants.maxVideoCount) {
        state = state.copyWith(
          errorMessage:
              '동영상은 최대 ${PostFileUploadConstants.maxVideoCount}개까지 첨부할 수 있습니다.',
        );
        return;
      }

      // 파일 크기 제약 조건을 확인합니다.
      for (final photo in newPhotos) {
        final file = await photo.file;
        if (file == null) continue;
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

      // 총 이미지 용량 제약 조건을 확인합니다.
      int totalImageSize = 0;
      for (final photo in [...state.photos, ...newPhotos]) {
        final file = await photo.file;
        if (file == null) continue;
        totalImageSize += await file.length();
      }

      if (totalImageSize > PostFileUploadConstants.maxTotalImageSizeBytes) {
        state = state.copyWith(errorMessage: '총 이미지 용량은 50MB를 초과할 수 없습니다.');
        return;
      }

      print("✅ [Step 11] 파일 검증 완료 - state 업데이트");
      // 모든 검증을 통과하면 상태를 업데이트하여 선택된 파일들을 UI에 반영합니다.
      state = state.copyWith(
        photos: [...state.photos, ...newPhotos],
        videos: [...state.videos, ...newVideos],
        errorMessage: null,
      );
    } catch (e) {
      print("❌ [Error] _proceedToPickAssets 에러: $e");
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

  // 👇 [신규] 위치 권한 요청 및 위치 가져오기 (거부 시 null 반환)
  Future<NLatLng?> _requestLocationAndGetPosition({
    NLatLng? designatedLocation,
  }) async {
    // 이미 지정된 위치가 있으면 권한 요청 없이 바로 반환
    if (designatedLocation != null) {
      return designatedLocation;
    }

    // 👇 현재 권한 상태 확인
    final currentStatus = await Permission.location.status;

    // 👇 이미 승인되어 있으면 바로 위치 가져오기
    if (currentStatus.isGranted) {
      return await _getCurrentPosition();
    }

    // 👇 권한 요청
    final status = await Permission.location.request();

    if (status.isGranted) {
      // ✅ 권한 승인됨
      return await _getCurrentPosition();
    } else if (status.isDenied) {
      // ❌ 일시적 거부 (다음에 다시 요청 가능)
      print("⚠️ 위치 권한이 거부되었습니다. (일시적)");
      state = state.copyWith(
        errorMessage: '지도 위에 글을 쓰려면 위치 권한이 필요합니다.',
        permissionDenialType: LocationPermissionDenialType.temporary,
      );
      return null;
    } else if (status.isPermanentlyDenied) {
      // 🚫 영구적 거부 (설정에서만 변경 가능)
      print("❌ 위치 권한이 영구적으로 거부되었습니다");
      state = state.copyWith(
        errorMessage: '위치 권한이 거부되었습니다.\n설정에서 위치 권한을 허용해주세요.',
        permissionDenialType: LocationPermissionDenialType.permanent,
      );
      return null;
    } else if (status.isRestricted) {
      // 🔒 시스템 제한
      print("🔒 위치 권한이 시스템에 의해 제한되었습니다.");
      state = state.copyWith(
        errorMessage: '위치 권한이 시스템에 의해 제한되었습니다.\n기기 설정을 확인해주세요.',
        permissionDenialType: LocationPermissionDenialType.restricted,
      );
      return null;
    } else {
      // 기타 상태
      print("⚠️ 알 수 없는 권한 상태: $status");
      state = state.copyWith(
        errorMessage: '위치 권한을 확인할 수 없습니다.',
        permissionDenialType: LocationPermissionDenialType.temporary,
      );
      return null;
    }
  }

  // 👇 현재 위치 가져오기 (별도 메서드로 분리)
  Future<NLatLng?> _getCurrentPosition() async {
    try {
      final gpsPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return NLatLng(gpsPosition.latitude, gpsPosition.longitude);
    } catch (e) {
      print("⚠️ 위치 정보를 가져오는 데 실패: $e");
      state = state.copyWith(
        errorMessage: '현재 위치를 가져올 수 없습니다.\n위치 서비스가 켜져 있는지 확인해주세요.',
      );
      return null;
    }
  }

  /// 게시글을 최종적으로 서버에 제출(등록)하는 함수입니다.
  Future<bool> submitPost({
    required String content,
    NLatLng? designatedLocation, // 지도에서 길게 눌러 지정한 위치 (선택 사항)
  }) async {
    // 1. **기본 유효성 검사**: 내용과 미디어가 모두 비어있는지 확인합니다.
    if (content.trim().isEmpty &&
        state.photos.isEmpty &&
        state.videos.isEmpty) {
      state = state.copyWith(errorMessage: '내용을 입력하거나 미디어를 추가해주세요.');
      return false;
    }

    // 2. **욕설/비속어 검사**: 내용에 금칙어가 포함되어 있는지 확인합니다.
    final filterService = _ref.read(profanityFilterProvider);
    final foundProfanity = filterService.findFirstProfanity(content);
    if (foundProfanity != null) {
      state = state.copyWith(
        errorMessage: "'$foundProfanity'은(는) 사용할 수 없는 단어입니다.",
      );
      return false;
    }

    // 3. **파일 유효성 검사**: 첨부된 파일의 개수, 용량 등을 확인합니다.
    final fileValidationError = await _validateFiles();
    if (fileValidationError != null) {
      state = state.copyWith(errorMessage: fileValidationError);
      return false;
    }

    // 4. **제출 시작**: 로딩 상태로 변경하고 이전 에러 메시지를 초기화합니다.
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      permissionDenialType: null,
    );

    try {
      // 5. **위치 정보 확보**: '무작위 위치' 여부와 관계없이 항상 실제 위치를 가져옵니다.
      // 서버가 이 위치를 기반으로 노이즈를 추가할지 결정합니다.
      final position = await _requestLocationAndGetPosition(
        designatedLocation: designatedLocation,
      );

      // 위치를 가져오지 못한 경우 (권한 거부 또는 위치 서비스 오류) 제출을 중단합니다.
      if (position == null) {
        state = state.copyWith(isSubmitting: false);
        return false;
      }

      final repository = _ref.read(issueGrainRepositoryProvider);
      final allAssets = [...state.photos, ...state.videos];

      // 6. **API 호출 분기**: 첨부 파일 유무에 따라 다른 API 함수를 호출합니다.
      if (allAssets.isEmpty) {
        // 6-1. **텍스트 전용 게시글 생성**: 파일이 없으면 바로 게시글 생성 API를 호출합니다.
        await repository.createPost(
          content: content,
          latitude: position.latitude,
          longitude: position.longitude,
          isRandomLocationEnabled: state.isRandomLocationEnabled,
        );
      } else {
        // 6-2. **파일 포함 게시글 생성**: 파일이 있는 경우 3단계에 걸쳐 생성합니다.
        // Step 1: 서버에 Presigned URL(파일 업로드용 임시 URL)을 요청합니다.
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

        // Step 2: 발급받은 Presigned URL로 실제 파일들을 S3 같은 저장소에 업로드합니다.
        await Future.wait(
          List.generate(
            files.length,
            (index) => _uploadFileToPresignedUrl(
              files[index],
              issuedUrls[index].presignedUrl,
            ),
          ),
        );

        // Step 3: 업로드가 완료되었음을 서버에 알리며 최종적으로 게시글 생성을 완료합니다.
        final fileKeyList = issuedUrls.map((info) => info.fileKey).toList();
        await repository.completePostCreation(
          content: content,
          fileKeyList: fileKeyList,
          latitude: position.latitude,
          longitude: position.longitude,
          isRandomLocationEnabled: state.isRandomLocationEnabled,
        );
      }

      // 7. **제출 완료**: 로딩 상태를 해제하고 성공(true)을 반환합니다.
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      // 8. **에러 처리**: 과정 중 오류 발생 시 로딩 상태를 해제하고 실패(false)를 반환합니다.
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
  String get unableToAccessAll => '모든 사진과 동영상에 접근할 수 없습니다';
  @override
  String get viewingLimitedAssetsTip => '일부 사진과 동영상만 표시됩니다';
  @override
  String get changeAccessibleLimitedAssets => '접근 가능한 사진 변경';
  @override
  String get accessAllTip =>
      '앱이 선택된 일부 사진과 동영상에만 접근할 수 있습니다. 시스템 설정으로 이동하여 앱이 기기의 모든 미디어에 접근하도록 허용하세요.';
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

final issueGrainRepositoryProvider = Provider<IssueGrainRepository>((ref) {
  // 1. 다른 Provider를 통해 Dio 인스턴스를 가져옵니다.
  final dio = ref.watch(dioProvider);

  // 2. TokenStorageServiceProvider를 통해 TokenStorageService 인스턴스를 가져옵니다.
  final tokenStorage = ref.watch(tokenStorageServiceProvider);

  // 3. 가져온 의존성들을 IssueGrainRepositoryImpl 생성자에 주입하여 인스턴스를 생성하고 반환합니다.
  return IssueGrainRepositoryImpl(dio, tokenStorage);
});
