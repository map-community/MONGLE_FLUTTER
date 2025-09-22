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
    return CircleAvatar(
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
    );
  }
}
