import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';
import 'package:jewel_ora/screens/user/widgets/jewellery_care_dialog.dart';
import 'package:jewel_ora/screens/user/widgets/ring_size_guide_dialog.dart';

void main() {
  testWidgets('AppButton renders and triggers onPressed callback', (tester) async {
    var wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppButton(
            title: 'Test Button',
            onPressed: () => wasTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
    await tester.tap(find.text('Test Button'));
    await tester.pump();
    expect(wasTapped, isTrue);
  });

  testWidgets('AppLoader renders luxury custom painter with message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLoader(
            size: 64,
            message: 'Loading your jewellery...',
          ),
        ),
      ),
    );

    expect(find.byType(AppLoader), findsOneWidget);
    expect(find.text('Loading your jewellery...'), findsOneWidget);
  });

  testWidgets('EmptyState displays title and message correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'No Items',
            message: 'Nothing here yet',
          ),
        ),
      ),
    );

    expect(find.text('No Items'), findsOneWidget);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  testWidgets('AppCard renders child with decoration', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppCard(
            child: Text('Card Content'),
          ),
        ),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);
    expect(find.byType(AppCard), findsOneWidget);
  });

  testWidgets('RingSizeGuideSheet renders all tabs including Visual Sizer Slider without Material errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RingSizeGuideSheet(),
        ),
      ),
    );

    // Initial tab: Ring Chart
    expect(find.text('Ring Chart'), findsOneWidget);
    expect(find.text('US Size'), findsOneWidget);

    // Switch to Visual Sizer tab (contains the Slider)
    await tester.tap(find.text('Visual Sizer'));
    await tester.pumpAndSettle();

    expect(find.byType(Slider), findsOneWidget);

    // Switch to Bangles tab
    await tester.tap(find.text('Bangles'));
    await tester.pumpAndSettle();

    expect(find.text('Medium / Standard'), findsOneWidget);
  });

  testWidgets('JewelleryCareSheet renders tips correctly', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JewelleryCareSheet(),
        ),
      ),
    );

    expect(find.text('Gold & Platinum Care'), findsOneWidget);
    expect(find.text('925 Sterling Silver'), findsOneWidget);
  });
}
