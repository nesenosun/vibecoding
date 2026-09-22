import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_oyunu/main.dart';

void main() {
  testWidgets('oyun ekranı yüklenir', (tester) async {
    await tester.pumpWidget(const KelimeUstasiApp());
    expect(find.text('KELİME USTASI'), findsOneWidget);
    expect(find.text('Yeni oyun'), findsNothing);
  });
}
