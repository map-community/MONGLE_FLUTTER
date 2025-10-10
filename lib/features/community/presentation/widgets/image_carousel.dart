import 'package:flutter/material.dart';
import 'package:mongle_flutter/features/community/presentation/widgets/full_screen_photo_view.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    // 여러 장일 때만 사용할 높이 변수
    const double carouselHeight = 150.0;

    if (imageUrls.length == 1) {
      // --- 사진이 한 장일 경우: ---
      final imageUrl = imageUrls.first;
      // ✅ 1. 고정 높이를 가진 SizedBox를 제거하여 높이가 가변적이 되도록 합니다.
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  FullScreenPhotoView(imageUrls: imageUrls, initialIndex: 0),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            // ✅ 2. fit 속성을 제거하면, 너비가 제약될 때(현재는 화면 전체 너비)
            //    원본 비율에 맞춰 높이가 자동으로 계산됩니다.
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              // ✅ 3. 로딩 중에는 고정된 비율의 회색 박스를 보여주어 '화면 울렁거림'을 방지합니다.
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.error_outline),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // --- 사진이 여러 장일 경우 (기존 로직 유지): ---
      return SizedBox(
        height: carouselHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            final imageUrl = imageUrls[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullScreenPhotoView(
                        imageUrls: imageUrls,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.fitHeight,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 100,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error_outline),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
