import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/game_controller.dart';
import '../game/game_logic.dart';
import 'widgets/game_board.dart';
import 'widgets/game_keyboard.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final GameController _game = GameController();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  int _lastInvalidTick = 0;
  bool _resultDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _game.addListener(_onGameChanged);
  }

  @override
  void dispose() {
    _game.removeListener(_onGameChanged);
    _game.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _onGameChanged() {
    if (_game.invalidTick != _lastInvalidTick) {
      _lastInvalidTick = _game.invalidTick;
      _shake.forward(from: 0);
    }
    if (_game.status != GameStatus.playing && !_resultDialogOpen) {
      _resultDialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showResultDialog());
    }
    setState(() {});
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _game.submit();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _game.removeLetter();
      return KeyEventResult.handled;
    }
    final char = event.character;
    if (char != null && char.isNotEmpty) {
      final upper = turkishUpper(char);
      if (upper.length == 1 && turkishAlphabet.contains(upper)) {
        _game.addLetter(upper);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  Future<void> _showResultDialog() async {
    final won = _game.status == GameStatus.won;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(won ? 'Tebrikler!' : 'Bu sefer olmadı'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                won
                    ? '${_game.guesses.length} denemede buldun'
                    : 'Doğru cevap: ${_game.answer}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statColumn('Oynanan', '${_game.gamesPlayed}'),
                  _statColumn('Kazanma', '%${(_game.winRate * 100).round()}'),
                  _statColumn('Seri', '${_game.currentStreak}'),
                  _statColumn('En İyi', '${_game.bestStreak}'),
                ],
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Yeni Oyun'),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    _resultDialogOpen = false;
    _game.newGame();
  }

  void _showRules() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Nasıl Oynanır?'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Beş harfli gizli Türkçe kelimeyi altı denemede bul.'),
              SizedBox(height: 14),
              _RuleRow(color: Color(0xFF2E9E5B), text: 'Harf doğru ve yerinde'),
              SizedBox(height: 8),
              _RuleRow(
                color: Color(0xFFC9A227),
                text: 'Harf kelimede var, yeri yanlış',
              ),
              SizedBox(height: 8),
              _RuleRow(color: Color(0xFF3A3B4A), text: 'Harf kelimede yok'),
              SizedBox(height: 14),
              Text(
                'Ekrandaki klavyeyi ya da bilgisayar klavyeni kullanabilirsin.',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anladım'),
            ),
          ],
        );
      },
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
      ],
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1D2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2E3046)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white60),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: _handleKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KELİME USTASI',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Color(0xFFB39DFF),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Türkçe kelime tahmin oyunu • 6 hak',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statChip('Seri', '${_game.currentStreak}'),
                    const SizedBox(width: 6),
                    _statChip('En İyi', '${_game.bestStreak}'),
                    IconButton(
                      onPressed: _showRules,
                      tooltip: 'Nasıl oynanır?',
                      icon: const Icon(Icons.help_outline_rounded),
                    ),
                    IconButton(
                      onPressed: _game.newGame,
                      tooltip: 'Yeni oyun',
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 330,
                        maxHeight: 400,
                      ),
                      child: GameBoard(
                        controller: _game,
                        shakeAnimation: _shake,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: GameKeyboard(
                    letterResults: _game.letterResults,
                    onLetter: _game.addLetter,
                    onEnter: _game.submit,
                    onDelete: _game.removeLetter,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}
