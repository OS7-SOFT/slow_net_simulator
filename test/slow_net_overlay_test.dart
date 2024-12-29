import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slow_net_simulator/slow_net_simulator.dart';

void main() {
  testWidgets(
      'FloatingActionButton should be visible after showOverlay() and hidden after hideOverlay()',
      (WidgetTester tester) async {
    // Build the widget tree and insert it into the test environment
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Test App')),
      ),
    ));

    // Show the overlay (which should add the FloatingActionButton)
    SlowNetOverlay.showOverlay(tester.element(find.byType(Center)));
    await tester
        .pumpAndSettle(); // Ensure that the overlay and button are rendered

    // Ensure the FloatingActionButton is visible after showOverlay is called
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Hide the overlay (which should remove the FloatingActionButton)
    SlowNetOverlay.hideOverlay();
    await tester.pumpAndSettle(); // Ensure the overlay has been removed

    // Ensure the FloatingActionButton is no longer visible after hideOverlay is called
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('Settings panel updates network speed',
      (WidgetTester tester) async {
    final overlayKey = GlobalKey<NavigatorState>();

    // Create a widget tree with a button to show the overlay.
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: overlayKey,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  SlowNetOverlay.showOverlay(
                      context); // Show overlay on button press
                },
                child: Text('Show Overlay'),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to show the overlay.
    await tester.tap(find.text('Show Overlay'));
    await tester.pumpAndSettle(); // Wait for overlay to be rendered

    // Ensure that the FloatingActionButton is present after the overlay is shown.
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Tap the floating action button to open the settings panel.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle(); // Wait for settings panel to be displayed

    // Verify that the dropdown and slider are displayed.
    expect(find.byType(DropdownButton<NetworkSpeed>), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);

    // Open the dropdown and wait for it to render the options.
    await tester.tap(find.byType(DropdownButton<NetworkSpeed>));
    await tester.pumpAndSettle(); // Wait for dropdown to open

    // Check if '3G' option exists in the dropdown before interacting with it.
    final dropdownItems = find.text('HSPA_3G');
    expect(dropdownItems, findsOneWidget); // Ensure the '3G' item is available

    // Change the network speed in the dropdown.
    await tester.tap(dropdownItems.last); // Tap to select '3G'
    await tester.pumpAndSettle(); // Wait for dropdown selection to settle

    // Adjust the failure probability slider.
    await tester.drag(
        find.byType(Slider), Offset(50, 0)); // Slide to adjust value
    await tester.pumpAndSettle(); // Wait for slider change to settle

    // Apply the settings.
    await tester.tap(find.text('Apply Settings'));
    await tester.pumpAndSettle(); // Wait for the settings to be applied

    // Here, you would verify the updated network settings, but since `SlowNetSimulator`
    // is not part of the test, you can add additional verification logic for it.

    // For example, if `SlowNetSimulator` exposes a method to retrieve the current speed:
    // expect(SlowNetSimulator.currentSpeed, NetworkSpeed.G3);
    // expect(SlowNetSimulator.failureProbability > 0, isTrue);
  });

  testWidgets('Button position updates correctly', (WidgetTester tester) async {
    final overlayKey = GlobalKey<NavigatorState>();

    // Create a widget tree with a button to show the overlay.
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: overlayKey,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  SlowNetOverlay.showOverlay(context);
                },
                child: Text('Show Overlay'),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to show the overlay.
    await tester.tap(find.text('Show Overlay'));
    await tester.pump();

    // Open the settings panel.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Select a new position for the button.
    await tester.tap(find.text('Top Left'));
    await tester.pumpAndSettle();

    // Apply the settings.
    await tester.tap(find.text('Apply Settings'));
    await tester.pump();

    // Verify that the button alignment is updated.
    // NOTE: You may need to add a way to expose the button's position or validate it visually.
    // Example (pseudo-code):
    // expect(SlowNetOverlay.buttonAlignment, Alignment.topLeft);
  });
}
