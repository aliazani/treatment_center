void main() {}
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:treatment_center/app.dart';
// import 'package:treatment_center/features/questionnaire_form/presentation/pages/landing_page.dart';

// void main() {
//   testWidgets('LandingPage renders all expected UI elements', (
//     WidgetTester tester,
//   ) async {
//     // Build the landing page widget
//     await tester.pumpWidget(
//       MaterialApp(theme: AppTheme.lightTheme, home: const LandingPage()),
//     );

//     // Verify app logo is present
//     expect(find.byType(Hero), findsOneWidget);
//     expect(find.byType(Image), findsOneWidget);

//     // Verify app name is present
//     expect(find.text('FV Treatment Center'), findsOneWidget);

//     // Verify tagline is present
//     expect(find.text('Assessment Tool'), findsOneWidget);

//     // Verify the two main buttons are present
//     expect(find.text('START NEW ASSESSMENT'), findsOneWidget);
//     expect(find.text('VIEW SAVED ASSESSMENTS'), findsOneWidget);

//     // Verify button icons are present
//     expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
//     expect(find.byIcon(Icons.folder_open), findsOneWidget);

//     // Verify version info is present
//     expect(find.text('v1.0.0'), findsOneWidget);
//   });

//   testWidgets('Buttons on LandingPage are tappable', (tester) async {
//     bool startNewTapped = false;
//     bool viewSavedTapped = false;

//     await tester.pumpWidget(
//       MaterialApp(
//         theme: AppTheme.lightTheme,
//         home: LandingPage(
//           onStartNewAssessment: () => startNewTapped = true,
//           onViewSavedAssessments: () => viewSavedTapped = true,
//         ),
//       ),
//     );

//     // Tap “START NEW ASSESSMENT”
//     await tester.tap(
//       find.widgetWithText(ElevatedButton, 'START NEW ASSESSMENT'),
//     );
//     await tester.pumpAndSettle();
//     expect(startNewTapped, isTrue);

//     // Tap “VIEW SAVED ASSESSMENTS”
//     await tester.tap(
//       find.widgetWithText(OutlinedButton, 'VIEW SAVED ASSESSMENTS'),
//     );
//     await tester.pumpAndSettle();
//     expect(viewSavedTapped, isTrue);
//   });

//   testWidgets('LandingPage UI layout and responsiveness', (
//     WidgetTester tester,
//   ) async {
//     // Test with a medium-sized screen
//     tester.binding.window.physicalSizeTestValue = const Size(1080, 1920);
//     tester.binding.window.devicePixelRatioTestValue = 1.0;

//     // Build the landing page widget
//     await tester.pumpWidget(
//       MaterialApp(theme: AppTheme.lightTheme, home: const LandingPage()),
//     );

//     // Verify that elements have proper constraints
//     // final logoFinder = find.byType(Hero);
//     // final Offset logoCenter = tester.getCenter(logoFinder);
//     // expect(logoCenter.dy < 400, true); // Logo should be in the upper part of the screen

//     // Verify button width spans the available width
//     final buttonFinder = find.widgetWithText(
//       ElevatedButton,
//       'START NEW ASSESSMENT',
//     );
//     final buttonSize = tester.getSize(buttonFinder);
//     expect(buttonSize.width > 300, true); // Button should be wide

//     // Reset the test values
//     addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
//   });

//   testWidgets('LandingPage Hero animation tag is set correctly', (
//     WidgetTester tester,
//   ) async {
//     // Build the landing page widget
//     await tester.pumpWidget(
//       MaterialApp(theme: AppTheme.lightTheme, home: const LandingPage()),
//     );

//     // Find the Hero widget
//     final heroWidget = tester.widget<Hero>(find.byType(Hero));

//     // Verify that the tag matches what we expect
//     expect(heroWidget.tag, 'app_logo');
//   });
// }
