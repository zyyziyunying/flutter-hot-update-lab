import 'package:flutter_test/flutter_test.dart';
import 'package:react_like_runtime_poc/src/render/tree_patch.dart';

void main() {
  group('TreePatchApplier.apply', () {
    test('replaces a nested node at the given path', () {
      final currentTree = SerializedTreeDocument.requireNodeMap({
        'type': 'View',
        'props': {'padding': 24},
        'events': {},
        'children': [
          {
            'type': 'Text',
            'props': {'text': 'Counter Demo A', 'fontSize': 22},
            'events': {},
            'children': [],
          },
          {
            'type': 'Text',
            'props': {'text': 'Counter: 0', 'fontSize': 16},
            'events': {},
            'children': [],
          },
        ],
      });

      final patch = TreePatch.parse({
        'ops': [
          {
            'op': 'replace',
            'path': [1],
            'node': {
              'type': 'Text',
              'props': {'text': 'Counter: 1', 'fontSize': 16},
              'events': {},
              'children': [],
            },
          },
        ],
      });

      final nextTree = TreePatchApplier.apply(
        currentTree: currentTree,
        patch: patch,
      );

      expect(
        ((nextTree['children'] as List)[1] as Map<String, Object?>)['props'],
        {'text': 'Counter: 1', 'fontSize': 16},
      );
      expect(
        ((currentTree['children'] as List)[1] as Map<String, Object?>)['props'],
        {'text': 'Counter: 0', 'fontSize': 16},
      );
    });

    test('rejects an out-of-range path', () {
      final currentTree = SerializedTreeDocument.requireNodeMap({
        'type': 'View',
        'props': {},
        'events': {},
        'children': [],
      });

      final patch = TreePatch.parse({
        'ops': [
          {
            'op': 'replace',
            'path': [0],
            'node': {
              'type': 'Text',
              'props': {'text': 'bad'},
              'events': {},
              'children': [],
            },
          },
        ],
      });

      expect(
        () => TreePatchApplier.apply(currentTree: currentTree, patch: patch),
        throwsA(isA<FormatException>()),
      );
    });

    test('replaces the root node when the path is empty', () {
      final currentTree = SerializedTreeDocument.requireNodeMap({
        'type': 'View',
        'props': {'padding': 24},
        'events': {},
        'children': [
          {
            'type': 'Text',
            'props': {'text': 'Old'},
            'events': {},
            'children': [],
          },
        ],
      });

      final patch = TreePatch.parse({
        'ops': [
          {
            'op': 'replace',
            'path': const [],
            'node': {
              'type': 'View',
              'props': {'padding': 12},
              'events': {},
              'children': [
                {
                  'type': 'Text',
                  'props': {'text': 'New'},
                  'events': {},
                  'children': [],
                },
              ],
            },
          },
        ],
      });

      final nextTree = TreePatchApplier.apply(
        currentTree: currentTree,
        patch: patch,
      );

      expect(nextTree['props'], {'padding': 12});
      expect(
        (((nextTree['children'] as List).single as Map)['props'] as Map)['text'],
        'New',
      );
      expect(currentTree['props'], {'padding': 24});
    });

    test('inserts a child node at the given path', () {
      final currentTree = SerializedTreeDocument.requireNodeMap({
        'type': 'View',
        'props': {},
        'events': {},
        'children': [
          {
            'type': 'Text',
            'props': {'text': 'Milk'},
            'events': {},
            'children': [],
          },
        ],
      });

      final patch = TreePatch.parse({
        'ops': [
          {
            'op': 'insert',
            'path': [1],
            'node': {
              'type': 'Text',
              'props': {'text': 'Coffee'},
              'events': {},
              'children': [],
            },
          },
        ],
      });

      final nextTree = TreePatchApplier.apply(
        currentTree: currentTree,
        patch: patch,
      );

      expect((nextTree['children'] as List), hasLength(2));
      expect(
        ((((nextTree['children'] as List)[1] as Map)['props']) as Map)['text'],
        'Coffee',
      );
    });

    test('removes a child node at the given path', () {
      final currentTree = SerializedTreeDocument.requireNodeMap({
        'type': 'View',
        'props': {},
        'events': {},
        'children': [
          {
            'type': 'Text',
            'props': {'text': 'Milk'},
            'events': {},
            'children': [],
          },
          {
            'type': 'Text',
            'props': {'text': 'Coffee'},
            'events': {},
            'children': [],
          },
        ],
      });

      final patch = TreePatch.parse({
        'ops': [
          {
            'op': 'remove',
            'path': [1],
          },
        ],
      });

      final nextTree = TreePatchApplier.apply(
        currentTree: currentTree,
        patch: patch,
      );

      expect((nextTree['children'] as List), hasLength(1));
      expect(
        ((((nextTree['children'] as List).single as Map)['props']) as Map)['text'],
        'Milk',
      );
    });

    test('moves a child node within the same parent', () {
      final currentTree = SerializedTreeDocument.requireNodeMap({
        'type': 'View',
        'props': {},
        'events': {},
        'children': [
          {
            'type': 'Text',
            'key': 'milk',
            'props': {'text': 'Milk'},
            'events': {},
            'children': [],
          },
          {
            'type': 'Text',
            'key': 'coffee',
            'props': {'text': 'Coffee'},
            'events': {},
            'children': [],
          },
        ],
      });

      final patch = TreePatch.parse({
        'ops': [
          {
            'op': 'move',
            'from': [1],
            'path': [0],
          },
        ],
      });

      final nextTree = TreePatchApplier.apply(
        currentTree: currentTree,
        patch: patch,
      );

      expect(
        ((((nextTree['children'] as List).first as Map)['props']) as Map)['text'],
        'Coffee',
      );
      expect(
        ((((nextTree['children'] as List).last as Map)['props']) as Map)['text'],
        'Milk',
      );
    });
  });
}
