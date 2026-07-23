import 'package:flutter_test/flutter_test.dart';
import 'package:q_premium/app.dart';

void main() {
  testWidgets('Q-PREMIUM app renders operators dashboard', (tester) async {
    await tester.pumpWidget(const QPremiumApp());
    expect(find.text('Q-PREMIUM Operator'), findsOneWidget);
  });
}
