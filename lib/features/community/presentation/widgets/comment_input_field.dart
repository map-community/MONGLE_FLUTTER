import 'package:flutter/material.dart';

class CommentInputField extends StatelessWidget {
  const CommentInputField({super.key});

  @override
  Widget build(BuildContext context) {
    // SafeArea는 그대로 유지하여 시스템 네비게이션 바를 침범하지 않도록 합니다.
    return SafeArea(
      child: Container(
        // ✨ 1. Container의 decoration을 사용하여 디자인을 직접 제어합니다.
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor, // Scaffold 배경색과 동일하게 설정
          // ✨ 2. 위쪽으로만 그림자를 주기 위한 boxShadow 설정
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 그림자 색상
              // Offset의 y값을 음수로 주어 그림자를 위쪽으로 올립니다.
              offset: const Offset(0, -2),
              blurRadius: 5.0, // 그림자를 부드럽게 퍼지게 함
            ),
          ],
        ),
        padding: EdgeInsets.only(
          // 키보드가 올라올 때 시스템이 추가하는 패딩을 감지하여 적용합니다.
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          // ✨ 3. 텍스트 필드와 버튼의 좌우 여백을 조절합니다.
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '댓글을 입력하세요...',
                    // ✨ 4. 깔끔한 디자인을 위해 TextField의 기본 밑줄을 제거합니다.
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero, // 내부 패딩 제거
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  // TODO: 댓글 등록 로직 구현
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
