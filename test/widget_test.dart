import 'package:flutter_test/flutter_test.dart';
import 'package:q_premium/app.dart';

void main() {
  testWidgets('Q-PREMIUM app renders login screen', (tester) async {
    await tester.pumpWidget(const QPremiumApp());

    // Login screen should show the app brand name
    expect(find.text('Q-PREMIUM'), findsOneWidget);

    // Should show the password field
    expect(find.text('Masuk'), findsOneWidget);
  });
}
