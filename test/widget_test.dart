/// Default widget smoke test — updated to reference [LogicLabApp].
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:logic_lab/main.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(const LogicLabApp());
    expect(find.text('LogicLab'), findsOneWidget);
  });
}
