import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/game_logic.dart';

class LetterTile extends StatefulWidget {
  const LetterTile({
    super.key,
    required this.letter,
    required this.size,
    this.result,
    this.revealDelay = Duration.zero,
  });

  final String letter;
  final double size;
  final LetterResult? result;
  final Duration revealDelay;

  @override
  State<LetterTile> createState() => _LetterTileState();
}

class _LetterTileState extends State<LetterTile>
    with SingleTickerProviderStateMixin {
  static const Color _empty = Color(0xFF171826);
  static const Color _filled = Color(0xFF23243A);
  static const Color _border = Color(0xFF3C3E57);

  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    if (widget.result != null) _startReveal();
  }

  @override
  void didUpdateWidget(covariant LetterTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.result != null && oldWidget.result == null) {
      _flip.value = 0;
      _startReveal();
    } else if (widget.result == null && oldWidget.result != null) {
      _flip.value = 0;
    }
  }

  void _startReveal() {
    Future<void>.delayed(widget.revealDelay, () {
      if (mounted) _flip.forward();
    });
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  Color? _resultColor(LetterResult? result) => switch (result) {
    LetterResult.correct => const Color(0xFF2E9E5B),
    LetterResult.present => const Color(0xFFC9A227),
    LetterResult.absent => const Color(0xFF3A3B4A),
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    final resultColor = _resultColor(widget.result);
    final baseColor = widget.letter.isEmpty ? _empty : _filled;
    final hasResult = widget.result != null;

    return AnimatedBuilder(
      animation: _flip,
      builder: (context, child) {
        final t = _flip.value;
        final showResult = hasResult && t >= 0.5;
        final color = showResult ? resultColor! : baseColor;
        final angle = hasResult ? math.pi * t : 0.0;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateX(angle),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.letter.isEmpty && !showResult
                    ? _border.withValues(alpha: 0.6)
                    : _border,
                width: 1.4,
              ),
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  widget.letter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
