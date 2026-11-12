import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foldflow/app.dart';
import 'package:foldflow/data/laundry_repository.dart';
import 'package:foldflow/screens/home_screen.dart';
import 'package:foldflow/screens/reservation_screen.dart';

void main() {
  // The test surface is a tall portrait window so long forms are fully on
  // screen, like they are on a phone.
  void usePortraitScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  testWidgets('home shows the FoldFlow copy, CTAs and sample order', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFoldFlowTheme(),
        scrollBehavior: const FoldFlowScrollBehavior(),
        home: HomeScreen(repository: DemoLaundryRepository()),
      ),
    );

    expect(find.text('FoldFlow'), findsOneWidget);
    expect(find.text('Laundry day,\nmade lighter.'), findsOneWidget);
    expect(
      find.text(
        'Schedule your drop-off and follow every load from our counter '
        'back to your closet.',
      ),
      findsOneWidget,
    );
    expect(find.text('Book a drop-off'), findsOneWidget);
    expect(find.text('Track my laundry'), findsOneWidget);

    // Sample order card, clearly marked as demo data.
    expect(find.text('SAMPLE ORDER · DEMO DATA'), findsOneWidget);
    expect(find.text('ORD-1042'), findsOneWidget);
  });

  testWidgets('home opens tracking and validates an empty Order ID', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFoldFlowTheme(),
        scrollBehavior: const FoldFlowScrollBehavior(),
        home: HomeScreen(repository: DemoLaundryRepository()),
      ),
    );

    expect(find.text('FoldFlow'), findsOneWidget);
    await tester.ensureVisible(find.text('Track my laundry'));
    await tester.tap(find.text('Track my laundry'));
    await tester.pumpAndSettle();

    expect(find.text('Where is your order?'), findsOneWidget);
    await tester.tap(find.text('Track Order'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your Order ID'), findsOneWidget);
  });

  testWidgets('reservation form validates required details and schedule', (
    tester,
  ) async {
    usePortraitScreen(tester);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildFoldFlowTheme(),
        scrollBehavior: const FoldFlowScrollBehavior(),
        home: ReservationScreen(repository: DemoLaundryRepository()),
      ),
    );

    await tester.ensureVisible(find.text('Submit Reservation'));
    await tester.tap(find.text('Submit Reservation'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your name'), findsOneWidget);
    expect(find.text('Enter a valid contact number'), findsOneWidget);
    expect(find.text('Choose a date to continue'), findsOneWidget);
    expect(find.text('Choose a time to continue'), findsOneWidget);
  });

  testWidgets('demo Order ID opens its ready-for-pickup ticket', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFoldFlowTheme(),
        scrollBehavior: const FoldFlowScrollBehavior(),
        home: HomeScreen(repository: DemoLaundryRepository()),
      ),
    );

    await tester.ensureVisible(find.text('Track my laundry'));
    await tester.tap(find.text('Track my laundry'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'ORD-1042');
    await tester.tap(find.text('Track Order'));
    await tester.pumpAndSettle();

    expect(find.text('Laundry progress'), findsOneWidget);
    expect(find.text('Ready for pickup'), findsOneWidget);
    expect(
      find.textContaining(
        'Payment and release of your laundry are handled at the shop',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('sample data for preview only'),
      findsOneWidget,
    );
  });

  testWidgets('an unknown Order ID shows the invalid state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildFoldFlowTheme(),
        scrollBehavior: const FoldFlowScrollBehavior(),
        home: HomeScreen(repository: DemoLaundryRepository()),
      ),
    );

    await tester.ensureVisible(find.text('Track my laundry'));
    await tester.tap(find.text('Track my laundry'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'ORD-9999');
    await tester.tap(find.text('Track Order'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('We could not find that Order ID'),
      findsOneWidget,
    );
  });
}
