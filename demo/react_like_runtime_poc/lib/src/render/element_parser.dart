import 'package:react_like_runtime_poc/src/render/element_node.dart';

class ElementParser {
  static ElementNode parseTree(Object? rawTree) {
    if (rawTree is! Map) {
      throw const FormatException('tree-root-must-be-object');
    }

    return _parseNode(
      Map<String, Object?>.from(rawTree.cast<Object?, Object?>()),
    );
  }

  static ElementNode _parseNode(Map<String, Object?> rawNode) {
    final rawType = rawNode['type'];
    if (rawType is! String) {
      throw const FormatException('node-type-must-be-string');
    }

    final type = _parseNodeType(rawType);
    final key = rawNode['key'];
    if (key != null && key is! String) {
      throw const FormatException('node-key-must-be-string');
    }

    final props = _parseProps(rawNode['props']);
    final events = _parseEvents(rawNode['events'], type);
    final children = _parseChildren(rawNode['children'], type);

    return ElementNode(
      type: type,
      key: key as String?,
      props: props,
      events: events,
      children: children,
    );
  }

  static ElementNodeType _parseNodeType(String rawType) {
    switch (rawType) {
      case 'View':
        return ElementNodeType.view;
      case 'Text':
        return ElementNodeType.text;
      case 'Button':
        return ElementNodeType.button;
      default:
        throw FormatException('unknown-node-type:$rawType');
    }
  }

  static Map<String, Object?> _parseProps(Object? rawProps) {
    if (rawProps is! Map) {
      throw const FormatException('node-props-must-be-object');
    }

    return Map<String, Object?>.from(rawProps.cast<Object?, Object?>());
  }

  static Map<String, String> _parseEvents(
    Object? rawEvents,
    ElementNodeType type,
  ) {
    if (rawEvents is! Map) {
      throw const FormatException('node-events-must-be-object');
    }

    final events = <String, String>{};
    for (final entry in rawEvents.entries) {
      final key = entry.key;
      final value = entry.value;

      if (key is! String || value is! String) {
        throw const FormatException('node-events-must-be-string-map');
      }

      if (key != 'onPress') {
        throw FormatException('unsupported-event:$key');
      }

      if (type != ElementNodeType.button) {
        throw FormatException('event-not-supported-for-node:$key');
      }

      events[key] = value;
    }

    return events;
  }

  static List<ElementNode> _parseChildren(
    Object? rawChildren,
    ElementNodeType type,
  ) {
    if (rawChildren is! List) {
      throw const FormatException('node-children-must-be-list');
    }

    if (type == ElementNodeType.text || type == ElementNodeType.button) {
      if (rawChildren.isNotEmpty) {
        throw FormatException('leaf-node-cannot-have-children:$type');
      }
      return const [];
    }

    return rawChildren
        .map((child) {
          if (child is! Map) {
            throw const FormatException('child-node-must-be-object');
          }
          return _parseNode(
            Map<String, Object?>.from(child.cast<Object?, Object?>()),
          );
        })
        .toList(growable: false);
  }
}
