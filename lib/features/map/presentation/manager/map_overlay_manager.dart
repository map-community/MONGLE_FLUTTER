import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mongle_flutter/features/community/domain/entities/issue_grain.dart';
import 'package:mongle_flutter/features/map/presentation/providers/map_interaction_providers.dart';
import 'package:mongle_flutter/features/map/presentation/widgets/marker_factory.dart';

class MapOverlayManager {
  final NaverMapController _controller;
  final WidgetRef _ref;
  final MarkerFactory _markerFactory;
  final BuildContext _context;

  MapOverlayManager({
    required NaverMapController controller,
    required WidgetRef ref,
    required MarkerFactory markerFactory,
    required BuildContext context,
  }) : _controller = controller,
       _ref = ref,
       _markerFactory = markerFactory,
       _context = context;

  Future<void> updateMarkers(List<IssueGrain> grains) async {
    final markers = <NMarker>{};
    for (final grain in grains) {
      final icon = await _markerFactory.createProfileMarkerIcon(
        context: _context,
        imageUrl: grain.author.profileImageUrl,
      );

      final marker = NMarker(
        id: grain.postId,
        position: NLatLng(grain.latitude, grain.longitude),
        icon: icon,
        anchor: NPoint(0.5, 1),
      );

      marker.setOnTapListener((_) {
        _ref
            .read(mapSheetStrategyProvider.notifier)
            .showGrainPreview(grain.postId);
      });
      markers.add(marker);
    }
    _controller.clearOverlays();
    _controller.addOverlayAll(markers);
  }
}
