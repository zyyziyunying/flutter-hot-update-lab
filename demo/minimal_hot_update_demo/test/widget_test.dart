import 'package:flutter_test/flutter_test.dart';

import 'package:minimal_hot_update_demo/main.dart';

void main() {
  testWidgets('switching payloads changes both UI and behavior', (
    WidgetTester tester,
  ) async {
    final repository = MemoryPayloadRepository(
      payloads: {
        'A': '''
{
  "version": 1,
  "screen": {
    "type": "column",
    "children": [
      { "type": "text", "text": "Counter Demo A" },
      {
        "type": "button",
        "text": "Add",
        "action": { "type": "increment_counter", "delta": 1 }
      }
    ]
  }
}
''',
        'B': '''
{
  "version": 1,
  "screen": {
    "type": "column",
    "children": [
      { "type": "text", "text": "Counter Demo B" },
      {
        "type": "button",
        "text": "Boost",
        "action": { "type": "increment_counter", "delta": 2 }
      }
    ]
  }
}
''',
      },
    );

    await tester.pumpWidget(HotUpdateDemoApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Counter Demo A'), findsOneWidget);
    expect(find.text('Active payload: A'), findsOneWidget);
    expect(find.text('Counter value: 0'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pump();
    expect(find.text('Counter value: 1'), findsOneWidget);

    await tester.tap(find.text('Use Payload B'));
    await tester.pumpAndSettle();

    expect(find.text('Counter Demo B'), findsOneWidget);
    expect(find.text('Active payload: B'), findsOneWidget);

    await tester.tap(find.text('Boost'));
    await tester.pump();
    expect(find.text('Counter value: 3'), findsOneWidget);
  });
}
