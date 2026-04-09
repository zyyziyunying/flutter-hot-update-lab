import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:react_like_runtime_poc/src/app/poc_shell.dart';

import '../support/fake_runtime_facade.dart';

void main() {
  FakeRuntimeFacade createRuntime({
    Set<String> failBootstrapForSource = const {},
    Map<String, FakeBundleProgram> programsBySource = const {},
  }) {
    return FakeRuntimeFacade(
      failBootstrapForSource: failBootstrapForSource,
      programsBySource: {
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
        ...programsBySource,
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

  testWidgets('patch rerender updates visible text without replacing the tree', (
    tester,
  ) async {
    await pumpShell(
      tester,
      runtime: createRuntime(
        programsBySource: {
          'bundle-a-source': FakeBundleProgram(
            bundleId: 'bundle-a',
            bundleVersion: '1.0.0',
            title: 'Counter Demo A',
            buttonLabel: 'Add',
            handlerId: 'h_a_add',
            delta: 1,
            initialCounter: 0,
            rerenderPatch: {
              'ops': [
                {
                  'op': 'replace',
                  'path': [1],
                  'node': {
                    'type': 'Text',
                    'props': {
                      'text': 'Counter: 1',
                      'fontSize': 16,
                      'textColor': '#444444',
                    },
                    'events': const {},
                    'children': const [],
                  },
                },
              ],
            },
          ),
        },
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Counter Demo A'), findsOneWidget);
    expect(find.text('Counter: 1'), findsOneWidget);
    expect(find.text('Active bundle: bundle-a'), findsOneWidget);
  });

  testWidgets('insert patch renders a new list item in the shell', (tester) async {
    await pumpShell(
      tester,
      runtime: createRuntime(
        programsBySource: {
          'bundle-a-source': FakeBundleProgram(
            bundleId: 'bundle-a',
            bundleVersion: '1.0.0',
            title: 'List Demo A',
            buttonLabel: 'Add item',
            handlerId: 'h_a_add_item',
            delta: 1,
            bootstrapTree: {
              'type': 'View',
              'props': {'padding': 24},
              'events': const {},
              'children': [
                {
                  'type': 'Text',
                  'props': {'text': 'List Demo A', 'fontSize': 22},
                  'events': const {},
                  'children': const [],
                },
                {
                  'type': 'View',
                  'props': {'padding': 12},
                  'events': const {},
                  'children': [
                    {
                      'type': 'Text',
                      'props': {'text': 'Milk', 'fontSize': 16},
                      'events': const {},
                      'children': const [],
                    },
                    {
                      'type': 'Text',
                      'props': {'text': 'Coffee', 'fontSize': 16},
                      'events': const {},
                      'children': const [],
                    },
                  ],
                },
                {
                  'type': 'Button',
                  'props': {'label': 'Add item', 'padding': 12},
                  'events': {'onPress': 'h_a_add_item'},
                  'children': const [],
                },
              ],
            },
            rerenderPatch: {
              'ops': [
                {
                  'op': 'insert',
                  'path': [1, 2],
                  'node': {
                    'type': 'Text',
                    'props': {'text': 'Item 3', 'fontSize': 16},
                    'events': const {},
                    'children': const [],
                  },
                },
              ],
            },
          ),
        },
      ),
    );

    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Item 3'), findsNothing);

    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();

    expect(find.text('Item 3'), findsOneWidget);
  });

  testWidgets('remove patch removes a list item from the shell', (tester) async {
    await pumpShell(
      tester,
      runtime: createRuntime(
        programsBySource: {
          'bundle-a-source': FakeBundleProgram(
            bundleId: 'bundle-a',
            bundleVersion: '1.0.0',
            title: 'List Demo A',
            buttonLabel: 'Remove last',
            handlerId: 'h_a_remove_last',
            delta: 1,
            bootstrapTree: {
              'type': 'View',
              'props': {'padding': 24},
              'events': const {},
              'children': [
                {
                  'type': 'Text',
                  'props': {'text': 'List Demo A', 'fontSize': 22},
                  'events': const {},
                  'children': const [],
                },
                {
                  'type': 'View',
                  'props': {'padding': 12},
                  'events': const {},
                  'children': [
                    {
                      'type': 'Text',
                      'props': {'text': 'Milk', 'fontSize': 16},
                      'events': const {},
                      'children': const [],
                    },
                    {
                      'type': 'Text',
                      'props': {'text': 'Coffee', 'fontSize': 16},
                      'events': const {},
                      'children': const [],
                    },
                    {
                      'type': 'Text',
                      'props': {'text': 'Item 3', 'fontSize': 16},
                      'events': const {},
                      'children': const [],
                    },
                  ],
                },
                {
                  'type': 'Button',
                  'props': {'label': 'Remove last', 'padding': 12},
                  'events': {'onPress': 'h_a_remove_last'},
                  'children': const [],
                },
              ],
            },
            rerenderPatch: {
              'ops': [
                {
                  'op': 'remove',
                  'path': [1, 2],
                },
              ],
            },
          ),
        },
      ),
    );

    expect(find.text('Item 3'), findsOneWidget);

    await tester.tap(find.text('Remove last'));
    await tester.pumpAndSettle();

    expect(find.text('Item 3'), findsNothing);
    expect(find.text('Milk'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
  });

  testWidgets('root replace patch swaps the rendered shell subtree', (
    tester,
  ) async {
    await pumpShell(
      tester,
      runtime: createRuntime(
        programsBySource: {
          'bundle-a-source': FakeBundleProgram(
            bundleId: 'bundle-a',
            bundleVersion: '1.0.0',
            title: 'Counter Demo A',
            buttonLabel: 'Add',
            handlerId: 'h_a_add',
            delta: 1,
            initialCounter: 0,
            rerenderPatch: {
              'ops': [
                {
                  'op': 'replace',
                  'path': const [],
                  'node': {
                    'type': 'View',
                    'props': {'padding': 20, 'backgroundColor': '#FFF7E8'},
                    'events': const {},
                    'children': [
                      {
                        'type': 'Text',
                        'props': {
                          'text': 'Patched root',
                          'fontSize': 22,
                          'textColor': '#111111',
                        },
                        'events': const {},
                        'children': const [],
                      },
                      {
                        'type': 'Button',
                        'props': {'label': 'Root button', 'padding': 12},
                        'events': {'onPress': 'h_a_add'},
                        'children': const [],
                      },
                    ],
                  },
                },
              ],
            },
          ),
        },
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Counter Demo A'), findsNothing);
    expect(find.text('Counter: 0'), findsNothing);
    expect(find.text('Patched root'), findsOneWidget);
    expect(find.text('Root button'), findsOneWidget);
    expect(find.text('Active bundle: bundle-a'), findsOneWidget);
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

  testWidgets('invalid bundle contract keeps bundle A visible', (tester) async {
    await pumpShell(
      tester,
      runtime: createRuntime(
        programsBySource: {
          'bundle-b-source': FakeBundleProgram(
            bundleId: 'bundle-b',
            bundleVersion: '2.0.0',
            title: 'Counter Demo B',
            buttonLabel: 'Boost',
            handlerId: 'h_b_boost',
            delta: 2,
            initialCounter: 10,
            hasDispatchEvent: false,
          ),
        },
      ),
    );

    await tester.tap(find.text('Use Bundle B'));
    await tester.pumpAndSettle();

    expect(find.text('Counter Demo A'), findsOneWidget);
    expect(find.text('Counter: 0'), findsOneWidget);
    expect(find.text('Active bundle: bundle-a'), findsOneWidget);
    expect(find.textContaining('missing-dispatch-event-global'), findsOneWidget);
  });

  testWidgets(
    'invalid bootstrap tree keeps the previous bundle visible and shows an error',
    (tester) async {
      await pumpShell(
        tester,
        runtime: createRuntime(
          programsBySource: {
            'bundle-b-source': FakeBundleProgram(
              bundleId: 'bundle-b',
              bundleVersion: '2.0.0',
              title: 'Counter Demo B',
              buttonLabel: 'Boost',
              handlerId: 'h_b_boost',
              delta: 2,
              initialCounter: 10,
              bootstrapTree: {
                'type': 'Image',
                'props': const {},
                'events': const {},
                'children': const [],
              },
            ),
          },
        ),
      );

      await tester.tap(find.text('Use Bundle B'));
      await tester.pumpAndSettle();

      expect(find.text('Counter Demo A'), findsOneWidget);
      expect(find.text('Counter: 0'), findsOneWidget);
      expect(find.text('Active bundle: bundle-a'), findsOneWidget);
      expect(find.textContaining('Rejected committed tree'), findsOneWidget);
    },
  );

  testWidgets('invalid rerender tree keeps previous ui and shows error', (
    tester,
  ) async {
    await pumpShell(
      tester,
      runtime: createRuntime(
        programsBySource: {
          'bundle-a-source': FakeBundleProgram(
            bundleId: 'bundle-a',
            bundleVersion: '1.0.0',
            title: 'Counter Demo A',
            buttonLabel: 'Add',
            handlerId: 'h_a_add',
            delta: 1,
            initialCounter: 0,
            rerenderTree: {
              'type': 'Image',
              'props': const {},
              'events': const {},
              'children': const [],
            },
          ),
        },
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Counter Demo A'), findsOneWidget);
    expect(find.text('Counter: 0'), findsOneWidget);
    expect(find.textContaining('Rejected committed tree'), findsOneWidget);
  });

  testWidgets('invalid rerender patch keeps previous ui and shows error', (
    tester,
  ) async {
    await pumpShell(
      tester,
      runtime: createRuntime(
        programsBySource: {
          'bundle-a-source': FakeBundleProgram(
            bundleId: 'bundle-a',
            bundleVersion: '1.0.0',
            title: 'Counter Demo A',
            buttonLabel: 'Add',
            handlerId: 'h_a_add',
            delta: 1,
            initialCounter: 0,
            rerenderPatch: {
              'ops': [
                {
                  'op': 'replace',
                  'path': [9],
                  'node': {
                    'type': 'Text',
                    'props': {'text': 'Counter: 1'},
                    'events': const {},
                    'children': const [],
                  },
                },
              ],
            },
          ),
        },
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Counter Demo A'), findsOneWidget);
    expect(find.text('Counter: 0'), findsOneWidget);
    expect(find.textContaining('Rejected committed patch'), findsOneWidget);
  });

  testWidgets('active runtime error logs are surfaced to the user', (tester) async {
    await pumpShell(
      tester,
      runtime: createRuntime(
        programsBySource: {
          'bundle-a-source': FakeBundleProgram(
            bundleId: 'bundle-a',
            bundleVersion: '1.0.0',
            title: 'Counter Demo A',
            buttonLabel: 'Add',
            handlerId: 'h_a_add',
            delta: 1,
            initialCounter: 0,
            dispatchLogError: 'simulated runtime handler failure',
          ),
        },
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Counter Demo A'), findsOneWidget);
    expect(find.text('Counter: 0'), findsOneWidget);
    expect(find.text('Active bundle: bundle-a'), findsOneWidget);
    expect(
      find.textContaining('simulated runtime handler failure'),
      findsOneWidget,
    );
  });
}
