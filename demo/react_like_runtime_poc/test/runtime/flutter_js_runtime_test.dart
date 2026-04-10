import 'dart:io';

import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:react_like_runtime_poc/src/render/tree_patch.dart';
import 'package:react_like_runtime_poc/src/runtime/bundle_loader.dart';
import 'package:react_like_runtime_poc/src/runtime/flutter_js_runtime.dart';
import 'package:react_like_runtime_poc/src/runtime/runtime_facade.dart';

void main() {
  group('FlutterJsRuntimeSession', () {
    test('transports renderer patch commits across the real JS bridge', () async {
      final runtime = getJavascriptRuntime(xhr: false);
      final session = FlutterJsRuntimeSession(runtime: runtime);
      final host = RecordingHostBridge();
      final bundleSource = File(
        'assets/bundles/bundle_a.js',
      ).readAsStringSync();

      await session.attachHost(host);
      await session.evaluateBundle(bundleSource);
      final contract = await session.inspectContract();
      final metadata = BundleContractValidator.validate(contract);

      expect(metadata.bundleId, 'bundle-a');

      await session.bootstrap();

      expect(host.treeCommits, hasLength(1));
      final handlerId = readHandlerIdByLabel(
        host.treeCommits.single,
        'Add item',
      );
      expect(handlerId, isNotEmpty);

      await session.dispatchEvent(handlerId, const {});

      expect(host.patchCommits, hasLength(1));
      final operations = host.patchCommits.single['ops']! as List<Object?>;
      expect(operations, hasLength(1));
      final operation = operations.single as Map<Object?, Object?>;
      expect(operation['op'], 'insert');
      expect(operation['path'], [2, 2]);

      await session.dispose();
    });

    test(
      'keeps the previous active handler table after a rejected renderer patch',
      () async {
        final runtime = getJavascriptRuntime(xhr: false);
        final session = FlutterJsRuntimeSession(runtime: runtime);
        final host = RecordingHostBridge(
          patchResults: const [
            {'ok': false, 'reason': 'reject-first-patch'},
            {'ok': true},
          ],
        );
        final bundleSource = File(
          'assets/bundles/bundle_a.js',
        ).readAsStringSync();

        await session.attachHost(host);
        await session.evaluateBundle(bundleSource);
        await session.bootstrap();

        final handlerId = readHandlerIdByLabel(
          host.treeCommits.single,
          'Add item',
        );

        await session.dispatchEvent(handlerId, const {});
        await session.dispatchEvent(handlerId, const {});

        expect(host.patchCommits, hasLength(2));
        expect(host.logs, contains('error:commit rejected: reject-first-patch'));
        expect(readPatchedNodeText(host.patchCommits.first), 'Item 3');
        expect(
          readPatchedNodeText(host.patchCommits.last),
          'Item 3',
          reason: 'rejected patches should roll JS state back to the last committed snapshot',
        );

        await session.dispose();
      },
    );

    test('transports remove patches across the real JS bridge', () async {
      final runtime = getJavascriptRuntime(xhr: false);
      final session = FlutterJsRuntimeSession(runtime: runtime);
      final host = RecordingHostBridge();
      final bundleSource = File(
        'assets/bundles/bundle_a.js',
      ).readAsStringSync();

      await session.attachHost(host);
      await session.evaluateBundle(bundleSource);
      await session.bootstrap();

      final addHandlerId = readHandlerIdByLabel(host.treeCommits.single, 'Add item');
      final removeHandlerId = readHandlerIdByLabel(
        host.treeCommits.single,
        'Remove last',
      );

      await session.dispatchEvent(addHandlerId, const {});
      await session.dispatchEvent(removeHandlerId, const {});

      expect(host.patchCommits, hasLength(2));
      final removeOperation =
          (host.patchCommits.last['ops']! as List<Object?>).single
              as Map<Object?, Object?>;
      expect(removeOperation['op'], 'remove');
      expect(removeOperation['path'], [2, 2]);

      await session.dispose();
    });

    test('transports keyed move patches across the real JS bridge', () async {
      final runtime = getJavascriptRuntime(xhr: false);
      final session = FlutterJsRuntimeSession(runtime: runtime);
      final host = RecordingHostBridge();
      final bundleSource = File(
        'assets/bundles/bundle_a.js',
      ).readAsStringSync();

      await session.attachHost(host);
      await session.evaluateBundle(bundleSource);
      await session.bootstrap();

      final reverseHandlerId = readHandlerIdByLabel(
        host.treeCommits.single,
        'Reverse order',
      );

      await session.dispatchEvent(reverseHandlerId, const {});

      expect(host.patchCommits, hasLength(1));
      final moveOperations = host.patchCommits.single['ops']! as List<Object?>;
      expect(moveOperations, hasLength(1));
      final moveOperation = moveOperations.single as Map<Object?, Object?>;
      expect(moveOperation['op'], 'move');
      expect(moveOperation['from'], [2, 1]);
      expect(moveOperation['path'], [2, 0]);

      await session.dispose();
    });

    test(
      'replaces reordered keyed buttons so Flutter receives fresh handler ids',
      () async {
        final runtime = getJavascriptRuntime(xhr: false);
        final session = FlutterJsRuntimeSession(runtime: runtime);
        final host = RecordingHostBridge();
        final bundleSource = File(
          'assets/bundles/bundle_c.js',
        ).readAsStringSync();

        await session.attachHost(host);
        await session.evaluateBundle(bundleSource);
        final contract = await session.inspectContract();
        final metadata = BundleContractValidator.validate(contract);

        expect(metadata.bundleId, 'bundle-c');
        await session.bootstrap();

        final initialTree = host.treeCommits.single;
        final reverseHandlerId = readHandlerIdByLabel(initialTree, 'Reverse order');

        await session.dispatchEvent(reverseHandlerId, const {});

        expect(host.patchCommits, hasLength(1));

        final reorderPatch = host.patchCommits.single;
        final reorderOperations = reorderPatch['ops']! as List<Object?>;
        expect(
          reorderOperations.map((operation) => (operation! as Map)['op']),
          containsAll(['move', 'replace']),
        );

        final reorderedTree = applyRecordedPatch(initialTree, reorderPatch);
        final reorderedPickBHandlerId = readHandlerIdByLabel(
          reorderedTree,
          'Pick B',
        );

        await session.dispatchEvent(reorderedPickBHandlerId, const {});

        expect(host.patchCommits, hasLength(2));

        final selectionTree = applyRecordedPatch(reorderedTree, host.patchCommits.last);
        expect(readTextByPrefix(selectionTree, 'Selected: '), 'Selected: B');

        await session.dispose();
      },
    );

    test('transports a root-replace patch across the real JS bridge', () async {
      final runtime = getJavascriptRuntime(xhr: false);
      final session = FlutterJsRuntimeSession(runtime: runtime);
      final host = RecordingHostBridge();

      await session.attachHost(host);
      await session.evaluateBundle(rootReplaceBundleSource);
      final contract = await session.inspectContract();
      final metadata = BundleContractValidator.validate(contract);

      expect(metadata.bundleId, 'root-replace-bundle');

      await session.bootstrap();
      await session.dispatchEvent('h_root_replace', const {});

      expect(host.patchCommits, hasLength(1));

      final operations = host.patchCommits.single['ops']! as List<Object?>;
      final operation = operations.single as Map<Object?, Object?>;
      expect(operation['path'], isEmpty);
      expect(
        ((((operation['node']! as Map<Object?, Object?>)['children']! as List)
                    .single
                as Map<Object?, Object?>)['props']!
            as Map<Object?, Object?>)['text'],
        'Root replaced',
      );

      await session.dispose();
    });
  });
}

String readHandlerIdByLabel(Map<String, Object?> tree, String label) {
  final queue = <Map<Object?, Object?>>[Map<Object?, Object?>.from(tree)];

  while (queue.isNotEmpty) {
    final node = queue.removeAt(0);
    final props = node['props'];
    if (props is Map && props['label'] == label) {
      final events = node['events']! as Map<Object?, Object?>;
      return events['onPress']! as String;
    }

    final children = node['children'];
    if (children is List) {
      for (final child in children) {
        if (child is Map) {
          queue.add(Map<Object?, Object?>.from(child));
        }
      }
    }
  }

  throw StateError('Missing button label: $label');
}

String readPatchedNodeText(Map<String, Object?> patch) {
  final operations = patch['ops']! as List<Object?>;
  final operation = operations.single as Map<Object?, Object?>;
  final node = operation['node']! as Map<Object?, Object?>;
  final props = node['props']! as Map<Object?, Object?>;
  return props['text']! as String;
}

Map<String, Object?> applyRecordedPatch(
  Map<String, Object?> currentTree,
  Map<String, Object?> patch,
) {
  return TreePatchApplier.apply(
    currentTree: SerializedTreeDocument.requireNodeMap(currentTree),
    patch: TreePatch.parse(patch),
  );
}

String readTextByPrefix(Map<String, Object?> tree, String prefix) {
  final queue = <Map<Object?, Object?>>[Map<Object?, Object?>.from(tree)];

  while (queue.isNotEmpty) {
    final node = queue.removeAt(0);
    final props = node['props'];
    if (props is Map) {
      final text = props['text'];
      if (text is String && text.startsWith(prefix)) {
        return text;
      }
    }

    final children = node['children'];
    if (children is List) {
      for (final child in children) {
        if (child is Map) {
          queue.add(Map<Object?, Object?>.from(child));
        }
      }
    }
  }

  throw StateError('Missing text with prefix: $prefix');
}

class RecordingHostBridge implements RuntimeHostBridge {
  RecordingHostBridge({this.patchResults = const []});

  final List<Map<String, Object?>> treeCommits = [];
  final List<Map<String, Object?>> patchCommits = [];
  final List<String> logs = [];
  final List<Map<String, Object?>> patchResults;
  int _patchResultIndex = 0;

  @override
  Map<String, Object?> commitTree(Object? serializedTree) {
    final tree = Map<String, Object?>.from(serializedTree! as Map);
    treeCommits.add(tree);
    return const {'ok': true};
  }

  @override
  Map<String, Object?> commitPatch(Object? serializedPatch) {
    final patch = Map<String, Object?>.from(serializedPatch! as Map);
    patchCommits.add(patch);

    if (_patchResultIndex < patchResults.length) {
      final result = patchResults[_patchResultIndex];
      _patchResultIndex += 1;
      return result;
    }

    return const {'ok': true};
  }

  @override
  void log(String level, String message) {
    logs.add('$level:$message');
  }
}

const rootReplaceBundleSource = '''
globalThis.__poc_bundle_meta = {
  bundleId: 'root-replace-bundle',
  bundleVersion: '1.0.0',
  runtimeAbiVersion: 'poc-v1',
  treeSchemaVersion: 'poc-tree-v1'
};

let hostRef = null;

globalThis.__poc_bootstrap = function(host) {
  hostRef = host;
  host.commitTree({
    type: 'View',
    props: { padding: 24 },
    events: {},
    children: [
      {
        type: 'Button',
        props: { label: 'Replace root', padding: 12 },
        events: { onPress: 'h_root_replace' },
        children: []
      }
    ]
  });
};

globalThis.__poc_dispatch_event = function(handlerId, payload) {
  if (handlerId !== 'h_root_replace') {
    throw new Error('Unknown handler id: ' + handlerId);
  }

  hostRef.commitPatch({
    ops: [
      {
        op: 'replace',
        path: [],
        node: {
          type: 'View',
          props: { padding: 12 },
          events: {},
          children: [
            {
              type: 'Text',
              props: { text: 'Root replaced', fontSize: 18 },
              events: {},
              children: []
            }
          ]
        }
      }
    ]
  });
};
''';
