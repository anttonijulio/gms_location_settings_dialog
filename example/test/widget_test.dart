import 'package:flutter_test/flutter_test.dart';
import 'package:gms_location_settings_dialog_example/main.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('GPS Dialog Example'), findsOneWidget);
  });
}
