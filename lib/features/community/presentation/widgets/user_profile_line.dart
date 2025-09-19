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
          radius: profileRadius, // 전체 반지름
          backgroundColor: Colors.grey.shade300, // 얇은 회색 테두리 색상
          // 2. 안쪽 원 (실제 프로필 이미지)
          child: CircleAvatar(
            radius: profileRadius - 1.5, // 테두리 두께(1.5px)를 뺀 반지름
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                ? NetworkImage(profileImageUrl!)
                : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
          ),
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
