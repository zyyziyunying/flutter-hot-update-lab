import 'package:flutter/material.dart';
import 'package:react_like_runtime_poc/src/render/element_node.dart';
import 'package:react_like_runtime_poc/src/render/flutter_widget_factory.dart';

class RenderView extends StatelessWidget {
  const RenderView({
    super.key,
    required this.root,
    required this.onButtonPress,
    this.factory = const FlutterWidgetFactory(),
  });

  final ElementNode root;
  final ButtonPressHandler onButtonPress;
  final FlutterWidgetFactory factory;

  @override
  Widget build(BuildContext context) {
    return factory.buildNode(root, onButtonPress: onButtonPress);
  }
}
