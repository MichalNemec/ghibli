import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seznam_ghibli/core/failure.dart';
import 'package:seznam_ghibli/widgets/failure_widget.dart';

void main() {
  group('FailureWidget', () {
    const failure = NetworkFailure('Network error');

    testWidgets('renders message and icon in full mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FailureWidget(failure: failure)),
        ),
      );

      expect(find.text('Network error'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('renders retry button when onRetry is provided', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FailureWidget(
              failure: failure,
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      expect(retried, true);
    });

    testWidgets('does not show retry when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FailureWidget(failure: failure)),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('compact mode shows smaller layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FailureWidget(
              failure: failure,
              compact: true,
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      // In compact mode, a smaller layout is used
      // Verify the widget is rendered without errors
    });

    testWidgets('displays correct icon per failure type', (tester) async {
      final failures = <Failure>[
        const NetworkFailure('A'),
        const ServerFailure('B'),
        const NotFoundFailure('C'),
        const UnknownFailure('D'),
      ];

      for (final f in failures) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: FailureWidget(failure: f)),
          ),
        );

        expect(find.byIcon(f.icon), findsOneWidget);
      }
    });
  });
}
