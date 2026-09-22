import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_oyunu/game/game_logic.dart';
import 'package:kelime_oyunu/game/word_list.dart';

void main() {
  group('turkishUpper', () {
    test('noktalı ve noktasız i harflerini doğru çevirir', () {
      expect(turkishUpper('bilgi'), 'BİLGİ');
      expect(turkishUpper('ışık'), 'IŞIK');
      expect(turkishUpper('çğöşü'), 'ÇĞÖŞÜ');
    });
  });

  group('evaluateGuess', () {
    test('tam doğru tahmin', () {
      final result = evaluateGuess(guess: 'KADIN', answer: 'KADIN');
      expect(result, everyElement(LetterResult.correct));
    });

    test('doğru harf yanlış yer', () {
      final result = evaluateGuess(guess: 'KALEM', answer: 'KELAM');
      expect(result, [
        LetterResult.correct,
        LetterResult.present,
        LetterResult.correct,
        LetterResult.present,
        LetterResult.correct,
      ]);
    });

    test('tekrar eden harfler doğru puanlanır', () {
      final result = evaluateGuess(guess: 'ABABA', answer: 'ARABA');
      expect(result, [
        LetterResult.correct,
        LetterResult.absent,
        LetterResult.correct,
        LetterResult.correct,
        LetterResult.correct,
      ]);
    });

    test('hiç eşleşmeyen tahmin', () {
      final result = evaluateGuess(guess: 'ÇİLEK', answer: 'BURUN');
      expect(result, everyElement(LetterResult.absent));
    });
  });

  group('wordList', () {
    test('en az 1000 kelime içeriyor', () {
      expect(wordList.length, greaterThanOrEqualTo(1000));
    });

    test('tüm kelimeler 5 harfli ve Türkçe alfabeye uygun', () {
      for (final word in wordList) {
        expect(word.length, 5, reason: '$word beş harfli değil');
        final upper = turkishUpper(word);
        expect(
          upper.length,
          5,
          reason: '$word büyük harfe çevrilince bozuluyor',
        );
        for (final ch in upper.split('')) {
          expect(
            turkishAlphabet.contains(ch),
            isTrue,
            reason: '$word içinde geçersiz harf: $ch',
          );
        }
      }
    });

    test('tekrar eden kelime yok', () {
      expect(wordList.toSet().length, wordList.length);
    });
  });

  group('answerList', () {
    test('tüm hedef kelimeler sözlükte bulunuyor', () {
      final dictionary = wordList.toSet();
      for (final word in answerList) {
        expect(dictionary.contains(word), isTrue, reason: '$word sözlükte yok');
      }
    });

    test('tekrar eden hedef kelime yok', () {
      expect(answerList.toSet().length, answerList.length);
    });
  });
}
