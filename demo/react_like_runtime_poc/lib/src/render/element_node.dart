enum ElementNodeType { view, text, button }

class ElementNode {
  const ElementNode({
    required this.type,
    required this.props,
    required this.events,
    required this.children,
    this.key,
  });

  final ElementNodeType type;
  final Map<String, Object?> props;
  final Map<String, String> events;
  final List<ElementNode> children;
  final String? key;
}
