import 'package:flutter_test/flutter_test.dart';
import 'package:app_ai_1/main.dart';

void main() {
  testWidgets('App shows pro title', (WidgetTester tester) async {
    await tester.pumpWidget(const AiPhotoEnhancerApp());
    expect(find.text('AI Photo Enhancer Pro'), findsOneWidget);
  });
}
