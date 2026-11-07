// Documents the one exception to "nothing loops": indeterminate spinners
// keep spinning while something loads, so tests of a loading screen or
// button use pump(), never pumpAndSettle().
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

/// Still animating after 30 s of frames: pumpAndSettle would time out.
Future<void> _expectStillSpinning(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(seconds: 10));
  }
  expect(tester.hasRunningAnimations, isTrue);
}

void main() {
  testWidgets('StateView.loading spins an indeterminate indicator', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const StateView.loading()));

    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.value, isNull);
    await _expectStillSpinning(tester);
  });

  testWidgets('AppButton.isLoading spins an indeterminate indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(AppButton(label: 'Entrar', isLoading: true, onPressed: () {})),
    );

    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.value, isNull);
    await _expectStillSpinning(tester);
  });

  testWidgets('without a spinner the same widgets settle', (tester) async {
    await tester.pumpWidget(
      wrap(
        Column(
          children: [
            const StateView.empty(message: 'Nada por aqui'),
            AppButton(label: 'Entrar', onPressed: () {}),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });
}
