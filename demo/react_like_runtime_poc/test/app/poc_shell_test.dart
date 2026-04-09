import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:react_like_runtime_poc/src/app/poc_shell.dart';

import '../support/fake_runtime_facade.dart';

void main() {
  FakeRuntimeFacade createRuntime({
    Set<String> failBootstrapForSource = const {},
  }) {
    return FakeRuntimeFacade(
      failBootstrapForSource: failBootstrapForSource,
      programsBySource: const {
        'bundle-a-source': FakeBundleProgram(
          bundleId: 'bundle-a',
          bundleVersion: '1.0.0',
          title: 'Counter Demo A',
          buttonLabel: 'Add',
          handlerId: 'h_a_add',
          delta: 1,
          initialCounter: 0,
        ),
        'bundle-b-source': FakeBundleProgram(
          bundleId: 'bundle-b',
          bundleVersion: '2.0.0',
          title: 'Counter Demo B',
          buttonLabel: 'Boost',
          handlerId: 'h_b_boost',
          delta: 2,
          initialCounter: 10,
        ),
      },
    );
  }

  StringAssetBundle createAssetBundle() {
    return StringAssetBundle({
      'assets/bundles/bundle_a.js': 'bundle-a-source',
      'assets/bundles/bundle_b.js': 'bundle-b-source',
    });
  }

  Future<void> pumpShell(
    WidgetTester tester, {
    required FakeRuntimeFacade runtime,
    StringAssetBundle? assetBundle,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PocShell(
          runtimeFacade: runtime,
          assetBundle: assetBundle ?? createAssetBundle(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders bundle A and rerenders after a button press', (
    tester,
  ) async {
    await pumpShell(tester, runtime: createRuntime());

    expect(find.text('Counter Demo A'), findsOneWidget);
    expect(find.text('Counter: 0'), findsOneWidget);
    expect(find.text('Active bundle: bundle-a'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Counter: 1'), findsOneWidget);
  });

  testWidgets('switching to bundle B changes both ui and behavior', (
    tester,
  ) async {
    await pumpShell(tester, runtime: createRuntime());

    await tester.tap(find.text('Use Bundle B'));
    await tester.pumpAndSettle();

    expect(find.text('Counter Demo B'), findsOneWidget);
    expect(find.text('Counter: 10'), findsOneWidget);
    expect(find.text('Active bundle: bundle-b'), findsOneWidget);

    await tester.tap(find.text('Boost'));
    await tester.pumpAndSettle();

    expect(find.text('Counter: 12'), findsOneWidget);
  });

  testWidgets('failed bundle B activation keeps bundle A visible', (
    tester,
  ) async {
    await pumpShell(
      tester,
      runtime: createRuntime(failBootstrapForSource: const {'bundle-b-source'}),
    );

    await tester.tap(find.text('Use Bundle B'));
    await tester.pumpAndSettle();

    expect(find.text('Counter Demo A'), findsOneWidget);
    expect(find.text('Active bundle: bundle-a'), findsOneWidget);
    expect(find.textContaining('bootstrap failed'), findsOneWidget);
  });
}
