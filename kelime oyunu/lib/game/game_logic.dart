enum LetterResult { correct, present, absent }

const String turkishAlphabet = 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ';

String turkishUpper(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    switch (char) {
      case 'i':
        buffer.write('İ');
      case 'ı':
        buffer.write('I');
      case 'ğ':
        buffer.write('Ğ');
      case 'ü':
        buffer.write('Ü');
      case 'ş':
        buffer.write('Ş');
      case 'ö':
        buffer.write('Ö');
      case 'ç':
        buffer.write('Ç');
      default:
        buffer.write(char.toUpperCase());
    }
  }
  return buffer.toString();
}

List<LetterResult> evaluateGuess({
  required String guess,
  required String answer,
}) {
  final g = turkishUpper(guess);
  final a = turkishUpper(answer);
  final results = List<LetterResult>.filled(g.length, LetterResult.absent);
  final remaining = <String, int>{};

  for (var i = 0; i < a.length; i++) {
    if (g[i] == a[i]) {
      results[i] = LetterResult.correct;
    } else {
      remaining[a[i]] = (remaining[a[i]] ?? 0) + 1;
    }
  }

  for (var i = 0; i < g.length; i++) {
    if (results[i] == LetterResult.correct) continue;
    final count = remaining[g[i]] ?? 0;
    if (count > 0) {
      results[i] = LetterResult.present;
      remaining[g[i]] = count - 1;
    }
  }

  return results;
}
