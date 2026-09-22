import 'dart:math';

import 'package:flutter/foundation.dart';

import 'game_logic.dart';
import 'word_list.dart';

enum GameStatus { playing, won, lost }

class GameController extends ChangeNotifier {
  GameController({Random? random}) : _random = random ?? Random() {
    _answer = _pickWord();
  }

  static const int maxAttempts = 6;
  static const int wordLength = 5;

  final Random _random;
  final Set<String> _validWords = wordList.map(turkishUpper).toSet();

  late String _answer;
  final List<String> _guesses = [];
  final List<List<LetterResult>> _evaluations = [];
  String _current = '';
  GameStatus _status = GameStatus.playing;
  int _invalidTick = 0;
  int _gamesPlayed = 0;
  int _gamesWon = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;

  String get answer => _answer;
  List<String> get guesses => List.unmodifiable(_guesses);
  List<List<LetterResult>> get evaluations => List.unmodifiable(_evaluations);
  String get current => _current;
  GameStatus get status => _status;
  int get invalidTick => _invalidTick;
  int get gamesPlayed => _gamesPlayed;
  int get gamesWon => _gamesWon;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  double get winRate => _gamesPlayed == 0 ? 0 : _gamesWon / _gamesPlayed;

  Map<String, LetterResult> get letterResults {
    final map = <String, LetterResult>{};
    for (var r = 0; r < _evaluations.length; r++) {
      final evaluation = _evaluations[r];
      final guess = _guesses[r];
      for (var i = 0; i < evaluation.length; i++) {
        final letter = guess[i];
        final result = evaluation[i];
        final existing = map[letter];
        if (existing == null ||
            existing == LetterResult.absent ||
            (existing == LetterResult.present &&
                result == LetterResult.correct)) {
          map[letter] = result;
        }
      }
    }
    return map;
  }

  void addLetter(String letter) {
    if (_status != GameStatus.playing || _current.length >= wordLength) return;
    _current += turkishUpper(letter);
    notifyListeners();
  }

  void removeLetter() {
    if (_status != GameStatus.playing || _current.isEmpty) return;
    _current = _current.substring(0, _current.length - 1);
    notifyListeners();
  }

  void submit() {
    if (_status != GameStatus.playing) return;
    if (_current.length != wordLength || !_validWords.contains(_current)) {
      _invalidTick++;
      notifyListeners();
      return;
    }

    _guesses.add(_current);
    final evaluation = evaluateGuess(guess: _current, answer: _answer);
    _evaluations.add(evaluation);
    final guessed = _current;
    _current = '';

    if (guessed == _answer) {
      _status = GameStatus.won;
      _gamesPlayed++;
      _gamesWon++;
      _currentStreak++;
      if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;
    } else if (_guesses.length >= maxAttempts) {
      _status = GameStatus.lost;
      _gamesPlayed++;
      _currentStreak = 0;
    }

    notifyListeners();
  }

  void newGame() {
    _answer = _pickWord(avoid: _answer);
    _guesses.clear();
    _evaluations.clear();
    _current = '';
    _status = GameStatus.playing;
    notifyListeners();
  }

  String _pickWord({String? avoid}) {
    for (var i = 0; i < 20; i++) {
      final candidate = turkishUpper(
        answerList[_random.nextInt(answerList.length)],
      );
      if (candidate != avoid) return candidate;
    }
    return turkishUpper(answerList[_random.nextInt(answerList.length)]);
  }
}
