import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_book/main.dart';

void main() {
  testWidgets('MyApp can be created', (WidgetTester tester) async {
    const app = MyApp();

    expect(app, isNotNull);
  });
}
