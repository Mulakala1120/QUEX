import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quex/app.dart';

void main() {
  testWidgets('QueX app launches splash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: QueXApp()),
    );

    expect(find.text('QueX'), findsOneWidget);
  });
}
