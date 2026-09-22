import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/game_controller.dart';
import 'letter_tile.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.controller,
    required this.shakeAnimation,
  });

  final GameController controller;
  final Animation<double> shakeAnimation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 7.0;
        final tileSize = math.min(
          (constraints.maxWidth - spacing * 4) / 5,
          (constraints.maxHeight - spacing * 5) / 6,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var r = 0; r < GameController.maxAttempts; r++) ...[
              if (r > 0) const SizedBox(height: spacing),
              _buildRow(r, tileSize, spacing),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRow(int rowIndex, double tileSize, double spacing) {
    final guesses = controller.guesses;
    final evaluations = controller.evaluations;
    final isSubmitted = rowIndex < guesses.length;
    final isActive =
        rowIndex == guesses.length && controller.status == GameStatus.playing;
    final word = isSubmitted
        ? guesses[rowIndex]
        : (isActive ? controller.current : '');
    final evaluation = isSubmitted ? evaluations[rowIndex] : null;

    final tiles = <Widget>[];
    for (var i = 0; i < GameController.wordLength; i++) {
      tiles.add(
        LetterTile(
          letter: i < word.length ? word[i] : '',
          size: tileSize,
          result: evaluation?[i],
          revealDelay: Duration(milliseconds: 110 * i),
        ),
      );
      if (i < GameController.wordLength - 1) {
        tiles.add(SizedBox(width: spacing));
      }
    }

    final row = Row(mainAxisSize: MainAxisSize.min, children: tiles);
    if (!isActive) return row;

    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        final v = shakeAnimation.value;
        final dx = math.sin(v * math.pi * 6) * 9 * (1 - v);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: row,
    );
  }
}
