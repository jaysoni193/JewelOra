import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jewel_ora/core/widgets/app_button.dart';
import 'package:jewel_ora/core/widgets/app_card.dart';
import 'package:jewel_ora/core/widgets/app_loader.dart';
import 'package:jewel_ora/core/widgets/empty_state.dart';

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

  testWidgets('AppLoader renders luxury custom painter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLoader(),
        ),
      ),
    );

    expect(find.byType(AppLoader), findsOneWidget);
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
}
