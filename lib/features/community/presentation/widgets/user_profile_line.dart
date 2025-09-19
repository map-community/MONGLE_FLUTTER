import 'package:flutter/material.dart';

class UserProfileLine extends StatelessWidget {
  final String? profileImageUrl;
  final double profileRadius;

  const UserProfileLine({
    super.key,
    this.profileImageUrl,
    this.profileRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. 프로필 이미지
        CircleAvatar(
          radius: profileRadius,
          // 이미지가 없을 경우 기본 아이콘 표시
          backgroundImage: profileImageUrl != null
              ? NetworkImage(profileImageUrl!)
              : null,
          child: profileImageUrl == null
              ? Icon(Icons.person, size: profileRadius)
              : null,
        ),
        // 2. 프로필 이미지와 카드 하단을 잇는 수직선
        Expanded(
          child: Container(
            width: 2, // 선의 두께
            color: Colors.grey.shade300, // 선의 색상
          ),
        ),
      ],
    );
  }
}
