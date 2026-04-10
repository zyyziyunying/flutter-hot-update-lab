import 'package:flutter/material.dart';
import 'package:react_like_runtime_poc/src/render/element_node.dart';

typedef ButtonPressHandler = Future<void> Function(String handlerId);

class FlutterWidgetFactory {
  const FlutterWidgetFactory();

  Widget buildNode(
    ElementNode node, {
    required ButtonPressHandler onButtonPress,
  }) {
    late final Widget widget;

    switch (node.type) {
      case ElementNodeType.view:
        widget = Container(
          width: double.infinity,
          color: _parseColor(node.props['backgroundColor'] as String?),
          padding: EdgeInsets.all(_readDouble(node.props['padding']) ?? 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: node.children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: buildNode(child, onButtonPress: onButtonPress),
                  ),
                )
                .toList(growable: false),
          ),
        );
      case ElementNodeType.text:
        widget = Text(
          node.props['text'] as String? ?? '',
          style: TextStyle(
            color: _parseColor(node.props['textColor'] as String?),
            fontSize: _readDouble(node.props['fontSize']),
          ),
        );
      case ElementNodeType.button:
        final handlerId = node.events['onPress'];
        widget = FilledButton(
          onPressed: handlerId == null
              ? null
              : () {
                  onButtonPress(handlerId);
                },
          style: FilledButton.styleFrom(
            padding: EdgeInsets.all(_readDouble(node.props['padding']) ?? 12),
          ),
          child: Text(node.props['label'] as String? ?? ''),
        );
    }

    final key = node.key;
    if (key == null) {
      return widget;
    }

    return KeyedSubtree(key: ValueKey(key), child: widget);
  }

  double? _readDouble(Object? value) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    return null;
  }

  Color? _parseColor(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final normalized = value.replaceFirst('#', '');
    if (normalized.length != 6) {
      return null;
    }

    final colorValue = int.tryParse('FF$normalized', radix: 16);
    if (colorValue == null) {
      return null;
    }

    return Color(colorValue);
  }
}
