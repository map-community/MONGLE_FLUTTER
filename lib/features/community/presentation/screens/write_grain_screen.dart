import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mongle_flutter/features/community/providers/write_grain_providers.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';

// TextEditingController를 사용하므로 ConsumerStatefulWidget으로 생성합니다.
class WriteGrainScreen extends ConsumerStatefulWidget {
  const WriteGrainScreen({super.key});

  @override
  ConsumerState<WriteGrainScreen> createState() => _WriteGrainScreenState();
}

class _WriteGrainScreenState extends ConsumerState<WriteGrainScreen> {
  // TextField의 내용을 제어하기 위한 컨트롤러
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // [watch] writeGrainProvider의 '상태'를 구독합니다.
    // isSubmitting 등의 상태가 바뀌면 이 위젯은 자동으로 다시 빌드됩니다.
    final writeState = ref.watch(writeGrainProvider);

    // [listen] 상태 변화에 따라 UI 동작(화면 이동, 스낵바 등)을 처리합니다.
    ref.listen(writeGrainProvider, (_, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('알갱이 만들기'),
        actions: [
          // 제출 중일 때는 버튼을 비활성화합니다.
          TextButton(
            onPressed: writeState.isSubmitting
                ? null
                : () async {
                    // [read] provider의 '함수'를 호출하기 위해 notifier를 읽어옵니다.
                    final notifier = ref.read(writeGrainProvider.notifier);
                    final success = await notifier.submitPost(
                      content: _textController.text,
                      photoUrls: [], // TODO: 사진 첨부 기능 추가
                    );

                    // 글쓰기 성공 시, 현재 화면을 닫고 이전 화면으로 돌아갑니다.
                    if (success && context.mounted) {
                      // [2] 지도 화면의 ViewModel을 무효화하여 새로고침을 유발합니다.
                      ref.invalidate(mapViewModelProvider);
                      context.pop();
                    }
                  },
            child: const Text('등록'),
          ),
        ],
      ),
      // AbsorbPointer: isSubmitting이 true일 때 화면 터치를 막아 중복 등록을 방지합니다.
      body: AbsorbPointer(
        absorbing: writeState.isSubmitting,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
            // 로딩 중일 때 화면 중앙에 인디케이터를 표시합니다.
            if (writeState.isSubmitting)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
