import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mongle_flutter/features/map/presentation/viewmodels/map_viewmodel.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/map_view.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. ref.watch를 사용하여 mapViewModelProvider의 상태 변화를 감지합니다.
    //    상태가 바뀔 때마다 이 build 메소드는 자동으로 다시 실행됩니다.
    final mapState = ref.watch(mapViewModelProvider);

    // 3. freezad 덕분에 when 메소드를 사용하여 모든 상태를 안전하게 처리할 수 있습니다.
    return mapState.when(
      // 로딩 중일 때 보여줄 UI
      loading: () => const Center(child: CircularProgressIndicator()),
      // 에러 발생 시 보여줄 UI
      error: (message) => Center(child: Text(message)),
      // 데이터 로딩 성공 시 보여줄 UI
      data: (initialPosition) => MapView(initialPosition: initialPosition),
    );
  }
}
