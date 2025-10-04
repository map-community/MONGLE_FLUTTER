// lib/features/community/presentation/screens/write_grain_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongle_flutter/features/community/providers/issue_grain_providers.dart';
import 'package:mongle_flutter/features/community/providers/write_grain_providers.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';

// TextEditingController를 사용하므로 StatefulWidget + Consumer 조합인 ConsumerStatefulWidget을 사용합니다.
class WriteGrainScreen extends ConsumerStatefulWidget {
  // 일반적인 글쓰기(FAB 클릭) 시에는 이 값이 null이 됩니다.
  final NLatLng? location;

  const WriteGrainScreen({super.key, this.location});

  @override
  ConsumerState<WriteGrainScreen> createState() => _WriteGrainScreenState();
}

class _WriteGrainScreenState extends ConsumerState<WriteGrainScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch: State가 변경될 때마다 UI를 다시 그리게 함 (버튼 활성화/비활성화 등)
    final writeState = ref.watch(writeGrainProvider);
    // ref.read: Notifier의 메서드를 호출할 때 사용 (UI를 다시 그리지 않음)
    final notifier = ref.read(writeGrainProvider.notifier);

    // ✅ [핵심] 로그인/회원가입 화면과 동일한 에러 처리 패턴
    // ref.listen: UI를 다시 그리지 않고, SnackBar 표시, 화면 이동 등 특정 '동작'을 수행할 때 사용
    ref.listen(writeGrainProvider, (previous, next) {
      // errorMessage 상태에 새로운 메시지가 들어왔는지 확인
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        // SnackBar를 사용해 사용자에게 에러 메시지를 보여줍니다.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('알갱이 만들기'),
        actions: [
          TextButton(
            // isSubmitting 상태일 때 버튼을 비활성화하여 중복 제출 방지
            onPressed: writeState.isSubmitting
                ? null
                : () async {
                    // 키보드를 내리는 동작
                    FocusScope.of(context).unfocus();

                    // submitPost 호출 시 widget.location을 전달합니다.
                    // 개발자 기능으로 진입했다면 location에 좌표값이 들어있을 것이고,
                    // 일반 FAB로 진입했다면 null이 전달될 것입니다.
                    final success = await notifier.submitPost(
                      content: _textController.text,
                      designatedLocation: widget.location,
                    );

                    // context.mounted는 위젯이 화면에 아직 붙어있는지 확인 (안전장치)
                    if (success && context.mounted) {
                      // 이전 화면(지도, 목록)의 데이터를 갱신하도록 신호를 보냄
                      ref.invalidate(mapViewModelProvider);
                      ref.invalidate(issueGrainsInCloudProvider);
                      // 화면을 닫음
                      context.pop();
                    }
                  },
            child: const Text('등록'),
          ),
        ],
      ),
      // AbsorbPointer: isSubmitting 중일 때 화면 터치를 막아 오작동 방지
      body: AbsorbPointer(
        absorbing: writeState.isSubmitting,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: '지금 무슨 일이 일어나고 있나요?',
                        border: InputBorder.none,
                      ),
                      maxLines: null, // 여러 줄 입력 가능
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ),
                // 미디어(사진) 선택 및 썸네일 표시 바
                _buildMediaBar(writeState, notifier),
              ],
            ),
            // isSubmitting 상태일 때 로딩 인디케이터 표시
            if (writeState.isSubmitting)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  // 미디어 바 UI를 만드는 위젯
  Widget _buildMediaBar(
    WriteGrainState writeState,
    WriteGrainNotifier notifier,
  ) {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library_outlined, size: 32),
                onPressed: () {
                  notifier.pickMedia();
                },
              ),
              const VerticalDivider(),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: writeState.photos.length,
                  itemBuilder: (context, index) {
                    final photo = writeState.photos[index];
                    return _buildThumbnailItem(photo, notifier);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 썸네일 아이템 UI를 만드는 위젯
  Widget _buildThumbnailItem(XFile file, WriteGrainNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(file.path),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: () {
                notifier.removePhoto(file);
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
