import 'package:flutter_test/flutter_test.dart';
import 'package:react_like_runtime_poc/src/render/element_node.dart';
import 'package:react_like_runtime_poc/src/render/element_parser.dart';

void main() {
  group('ElementParser.parseTree', () {
    test('parses a valid tree with view text and button nodes', () {
      final root = ElementParser.parseTree({
        'type': 'View',
        'key': 'root-view',
        'props': {'padding': 16, 'backgroundColor': '#EAF4FF'},
        'events': {},
        'children': [
          {
            'type': 'Text',
            'key': 'title-text',
            'props': {
              'text': 'Bundle A',
              'textColor': '#111111',
              'fontSize': 20,
            },
            'events': {},
            'children': [],
          },
          {
            'type': 'Button',
            'props': {'label': 'Add', 'padding': 12},
            'events': {'onPress': 'h_1'},
            'children': [],
          },
        ],
      });

      expect(root.type, ElementNodeType.view);
      expect(root.key, 'root-view');
      expect(root.props['padding'], 16);
      expect(root.children, hasLength(2));
      expect(root.children.first.type, ElementNodeType.text);
      expect(root.children.first.key, 'title-text');
      expect(root.children.first.props['text'], 'Bundle A');
      expect(root.children.last.type, ElementNodeType.button);
      expect(root.children.last.events['onPress'], 'h_1');
    });

    test('rejects unknown node types', () {
      expect(
        () => ElementParser.parseTree({
          'type': 'Image',
          'props': {},
          'events': {},
          'children': [],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects children on text nodes', () {
      expect(
        () => ElementParser.parseTree({
          'type': 'Text',
          'props': {'text': 'bad'},
          'events': {},
          'children': [
            {
              'type': 'Text',
              'props': {'text': 'nested'},
              'events': {},
              'children': [],
            },
          ],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects unsupported events', () {
      expect(
        () => ElementParser.parseTree({
          'type': 'Button',
          'props': {'label': 'Tap'},
          'events': {'onHover': 'h_2'},
          'children': [],
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
