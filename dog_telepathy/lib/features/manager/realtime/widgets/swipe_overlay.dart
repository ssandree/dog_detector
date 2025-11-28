import 'dart:async';

import 'package:flutter/material.dart';

class SwipeOverlay extends StatefulWidget {
  final bool enabled;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const SwipeOverlay({
    super.key,
    required this.enabled,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  State<SwipeOverlay> createState() => _SwipeOverlayState();
}

class _SwipeOverlayState extends State<SwipeOverlay>
    with SingleTickerProviderStateMixin {
  double _dragDistance = 0;
  Timer? _hintTimer;
  bool _showLeftHint = false;
  bool _showRightHint = false;

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  void _showHint(bool isLeft) {
    setState(() {
      _showLeftHint = !isLeft;
      _showRightHint = isLeft;
    });
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _showLeftHint = false;
        _showRightHint = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        if (!widget.enabled) return;
        setState(() => _dragDistance += details.delta.dx);
      },
      onHorizontalDragEnd: (details) {
        if (!widget.enabled) return;
        if (_dragDistance.abs() > 48) {
          if (_dragDistance > 0) {
            widget.onSwipeRight();
            _showHint(false);
          } else {
            widget.onSwipeLeft();
            _showHint(true);
          }
        }
        setState(() => _dragDistance = 0);
      },
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: _showLeftHint ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.white.withOpacity(0.8),
                  size: 32,
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _showRightHint ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.8),
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
