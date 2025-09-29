import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SimpleInfoScreen extends StatelessWidget {
  final String title;
  final String body;

  const SimpleInfoScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        // ✅ [수정] padding을 SingleChildScrollView로 옮깁니다.
        padding: const EdgeInsets.all(16.0),
        // ✅ [수정] Markdown 위젯을 MarkdownBody 위젯으로 교체합니다.
        child: MarkdownBody(data: body),
      ),
    );
  }
}
