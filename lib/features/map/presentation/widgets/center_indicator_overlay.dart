import 'package:flutter/material.dart';

/// 중앙 인디케이터의 상태
enum CenterIndicatorState {
  /// 기능 비활성화 (줌 레벨 낮음) - 숨김
  disabled,

  /// 마커 없음 (회색)
  idle,

  /// 마커 근처 (파란색, 약간 커짐)
  nearby,

  /// 마커 정중앙 (연한 초록색, 부드러운 펄스)
  centered,
}

class CenterIndicatorOverlay extends StatefulWidget {
  final CenterIndicatorState state;

  const CenterIndicatorOverlay({super.key, required this.state});

  @override
  State<CenterIndicatorOverlay> createState() => _CenterIndicatorOverlayState();
}

class _CenterIndicatorOverlayState extends State<CenterIndicatorOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(CenterIndicatorOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    if (widget.state == CenterIndicatorState.centered) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return _buildIndicator();
          },
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    final config = _getConfigForState(widget.state);
    final scale = widget.state == CenterIndicatorState.centered
        ? _pulseAnimation.value
        : 1.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: config.size * scale,
      height: config.size * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: config.fillColor,
        border: Border.all(
          color: config.borderColor,
          width: config.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: config.shadowColor,
            blurRadius: config.shadowBlur,
            spreadRadius: config.shadowSpread,
          ),
        ],
      ),
    );
  }

  _IndicatorConfig _getConfigForState(CenterIndicatorState state) {
    switch (state) {
      case CenterIndicatorState.disabled:
        return _IndicatorConfig(
          size: 32,
          fillColor: Colors.transparent, // 👈 내부 색 없음
          borderColor: Colors.grey.shade300.withOpacity(0.7), // 👈 매우 옅은 테두리
          borderWidth: 1.5, // 👈 얇게
          shadowColor: Colors.transparent, // 👈 그림자 없음
          shadowBlur: 0,
          shadowSpread: 0,
        );

      case CenterIndicatorState.idle:
        return _IndicatorConfig(
          size: 32,
          fillColor: Colors.white.withOpacity(0.3),
          borderColor: Colors.grey.shade400,
          borderWidth: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shadowBlur: 4,
          shadowSpread: 0,
        );

      case CenterIndicatorState.nearby:
        return _IndicatorConfig(
          size: 38,
          fillColor: Colors.blue.withOpacity(0.15),
          borderColor: Colors.blue.shade400,
          borderWidth: 2.5,
          shadowColor: Colors.blue.withOpacity(0.2),
          shadowBlur: 6,
          shadowSpread: 1,
        );

      case CenterIndicatorState.centered:
        return _IndicatorConfig(
          size: 42,
          fillColor: Colors.green.withOpacity(0.2),
          borderColor: Colors.green.shade400,
          borderWidth: 2.5,
          shadowColor: Colors.green.withOpacity(0.25),
          shadowBlur: 8,
          shadowSpread: 2,
        );
    }
  }
}

class _IndicatorConfig {
  final double size;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final Color shadowColor;
  final double shadowBlur;
  final double shadowSpread;

  const _IndicatorConfig({
    required this.size,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
    required this.shadowColor,
    required this.shadowBlur,
    required this.shadowSpread,
  });
}
