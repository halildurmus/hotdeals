// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:hotdeals/src/app.dart';
// import 'package:hotdeals/src/settings/settings_controller.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Initializes a new SharedPreferences instance.
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//
//     // Sets up the SettingsController, which will glue user settings to multiple
//     // Flutter Widgets.
//     final SettingsController settingsController =
//         FakeSettingsController(FakeSettingsService(prefs));
//
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(MyApp(
//       settingsController: settingsController,
//     ));
//
//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);
//
//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();
//
//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }
