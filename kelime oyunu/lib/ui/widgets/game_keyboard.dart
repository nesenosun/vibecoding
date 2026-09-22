import 'package:flutter/material.dart';

import '../../game/game_logic.dart';

class GameKeyboard extends StatelessWidget {
  const GameKeyboard({
    super.key,
    required this.onLetter,
    required this.onEnter,
    required this.onDelete,
    required this.letterResults,
  });

  final ValueChanged<String> onLetter;
  final VoidCallback onEnter;
  final VoidCallback onDelete;
  final Map<String, LetterResult> letterResults;

  static const List<List<String>> _rows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', 'Ğ', 'Ü'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ş', 'İ'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', 'Ö', 'Ç'],
  ];

  Color _keyColor(String letter) {
    return switch (letterResults[letter]) {
      LetterResult.correct => const Color(0xFF2E9E5B),
      LetterResult.present => const Color(0xFFC9A227),
      LetterResult.absent => const Color(0xFF14151F),
      null => const Color(0xFF2A2B3D),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(_rows[0]),
        const SizedBox(height: 5),
        _buildRow(_rows[1]),
        const SizedBox(height: 5),
        Row(
          children: [
            _actionKey(flex: 5, icon: Icons.check_rounded, onTap: onEnter),
            ..._rows[2].map(_letterKey),
            _actionKey(
              flex: 5,
              icon: Icons.backspace_outlined,
              onTap: onDelete,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> letters) {
    return Row(children: letters.map(_letterKey).toList());
  }

  Widget _letterKey(String letter) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: _KeyButton(
          color: _keyColor(letter),
          onTap: () => onLetter(letter),
          child: Text(
            letter,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionKey({
    required int flex,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: _KeyButton(
          color: const Color(0xFF3C3E57),
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.color,
    required this.onTap,
    required this.child,
  });

  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(height: 46, child: Center(child: child)),
      ),
    );
  }
}
