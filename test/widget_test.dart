// Basic Flutter widget test for AndroBlight

import 'package:flutter_test/flutter_test.dart';
import 'package:andro_blight/main.dart';

void main() {
  testWidgets('AndroBlight app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AndroBlight());

    // Verify the app title appears
    expect(find.text('AndroBlight'), findsWidgets);
  });
}
