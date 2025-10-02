// lib/features/community/presentation/screens/write_grain_screen.dart

import 'dart:io'; // Image.file을 사용하기 위해 import 합니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mongle_flutter/features/community/providers/write_grain_providers.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';

class WriteGrainScreen extends ConsumerStatefulWidget {
  const WriteGrainScreen({super.key});

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
    final writeState = ref.watch(writeGrainProvider);
    final notifier = ref.read(writeGrainProvider.notifier);

    ref.listen(writeGrainProvider, (_, next) {
      if (next.errorMessage != null) {
        // 에러 메시지가 표시된 후, 다시 null로 초기화하여 중복 표시를 방지합니다.
        // 이 부분은 좀 더 정교한 상태 관리로 개선될 수 있습니다.
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
            onPressed: writeState.isSubmitting
                ? null
                : () async {
                    final success = await notifier.submitPost(
                      content: _textController.text,
                    );

                    if (success && context.mounted) {
                      ref.invalidate(mapViewModelProvider);
                      context.pop();
                    }
                  },
            child: const Text('등록'),
          ),
        ],
      ),
      bottomNavigationBar: _buildMediaBar(writeState, notifier),
      body: AbsorbPointer(
        absorbing: writeState.isSubmitting,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: '지금 무슨 일이 일어나고 있나요?',
                  border: InputBorder.none,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
              ),
            ),
            if (writeState.isSubmitting)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

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
        right: false,
        left: false,
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
                  itemCount:
                      writeState.photos.length + writeState.videos.length,
                  itemBuilder: (context, index) {
                    bool isPhoto = index < writeState.photos.length;
                    XFile file = isPhoto
                        ? writeState.photos[index]
                        : writeState.videos[index - writeState.photos.length];

                    return _buildThumbnailItem(file, isPhoto, notifier);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailItem(
    XFile file,
    bool isPhoto,
    WriteGrainNotifier notifier,
  ) {
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
          if (!isPhoto)
            const Positioned.fill(
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: () {
                if (isPhoto) {
                  notifier.removePhoto(file);
                } else {
                  notifier.removeVideo(file);
                }
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
