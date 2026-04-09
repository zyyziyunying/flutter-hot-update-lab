typedef SerializedNodeMap = Map<String, Object?>;

class TreePatch {
  TreePatch({required this.operations});

  final List<TreePatchOperation> operations;

  static TreePatch parse(Object? rawPatch) {
    if (rawPatch is! Map) {
      throw const FormatException('patch-must-be-object');
    }

    final rawOperations = rawPatch['ops'];
    if (rawOperations is! List) {
      throw const FormatException('patch-ops-must-be-list');
    }

    return TreePatch(
      operations: rawOperations
          .map((operation) => TreePatchOperation.parse(operation))
          .toList(growable: false),
    );
  }
}

class TreePatchOperation {
  TreePatchOperation({
    required this.op,
    required this.path,
    this.node,
  });

  final String op;
  final List<int> path;
  final SerializedNodeMap? node;

  static TreePatchOperation parse(Object? rawOperation) {
    if (rawOperation is! Map) {
      throw const FormatException('patch-op-must-be-object');
    }

    final op = rawOperation['op'];
    if (op != 'replace' && op != 'insert' && op != 'remove') {
      throw FormatException('unsupported-patch-op:$op');
    }

    final rawPath = rawOperation['path'];
    if (rawPath is! List) {
      throw const FormatException('patch-path-must-be-list');
    }

    final path = rawPath.map((segment) {
      if (segment is! int || segment < 0) {
        throw const FormatException('patch-path-must-contain-non-negative-int');
      }
      return segment;
    }).toList(growable: false);

    return TreePatchOperation(
      op: op as String,
      path: path,
      node: op == 'remove'
          ? null
          : SerializedTreeDocument.requireNodeMap(rawOperation['node']),
    );
  }
}

class SerializedTreeDocument {
  static SerializedNodeMap requireNodeMap(Object? rawNode) {
    if (rawNode is! Map) {
      throw const FormatException('tree-node-must-be-object');
    }

    return _copyMap(Map<Object?, Object?>.from(rawNode));
  }

  static SerializedNodeMap _copyMap(Map<Object?, Object?> source) {
    final copy = <String, Object?>{};

    for (final entry in source.entries) {
      final key = entry.key;
      if (key is! String) {
        throw const FormatException('tree-map-key-must-be-string');
      }

      copy[key] = _copyValue(entry.value);
    }

    return copy;
  }

  static Object? _copyValue(Object? value) {
    if (value is Map) {
      return _copyMap(Map<Object?, Object?>.from(value));
    }

    if (value is List) {
      return value.map(_copyValue).toList(growable: true);
    }

    return value;
  }
}

class TreePatchApplier {
  static SerializedNodeMap apply({
    required SerializedNodeMap currentTree,
    required TreePatch patch,
  }) {
    var nextTree = SerializedTreeDocument.requireNodeMap(currentTree);

    for (final operation in patch.operations) {
      switch (operation.op) {
        case 'replace':
          nextTree = _applyReplace(
            currentTree: nextTree,
            path: operation.path,
            replacement: operation.node!,
          );
        case 'insert':
          nextTree = _applyInsert(
            currentTree: nextTree,
            path: operation.path,
            insertedNode: operation.node!,
          );
        case 'remove':
          nextTree = _applyRemove(currentTree: nextTree, path: operation.path);
      }
    }

    return nextTree;
  }

  static SerializedNodeMap _applyReplace({
    required SerializedNodeMap currentTree,
    required List<int> path,
    required SerializedNodeMap replacement,
  }) {
    if (path.isEmpty) {
      return SerializedTreeDocument.requireNodeMap(replacement);
    }

    final parent = _findNodeAtPath(currentTree, path.take(path.length - 1));
    final rawChildren = parent['children'];
    if (rawChildren is! List) {
      throw const FormatException('patch-target-children-must-be-list');
    }

    final childIndex = path.last;
    if (childIndex >= rawChildren.length) {
      throw FormatException('patch-path-out-of-range:$path');
    }

    rawChildren[childIndex] = SerializedTreeDocument.requireNodeMap(replacement);
    return currentTree;
  }

  static SerializedNodeMap _applyInsert({
    required SerializedNodeMap currentTree,
    required List<int> path,
    required SerializedNodeMap insertedNode,
  }) {
    if (path.isEmpty) {
      throw const FormatException('insert-operation-requires-parent-path');
    }

    final parent = _findNodeAtPath(currentTree, path.take(path.length - 1));
    final rawChildren = parent['children'];
    if (rawChildren is! List) {
      throw const FormatException('patch-target-children-must-be-list');
    }

    final childIndex = path.last;
    if (childIndex > rawChildren.length) {
      throw FormatException('patch-path-out-of-range:$path');
    }

    rawChildren.insert(
      childIndex,
      SerializedTreeDocument.requireNodeMap(insertedNode),
    );
    return currentTree;
  }

  static SerializedNodeMap _applyRemove({
    required SerializedNodeMap currentTree,
    required List<int> path,
  }) {
    if (path.isEmpty) {
      throw const FormatException('remove-operation-cannot-target-root');
    }

    final parent = _findNodeAtPath(currentTree, path.take(path.length - 1));
    final rawChildren = parent['children'];
    if (rawChildren is! List) {
      throw const FormatException('patch-target-children-must-be-list');
    }

    final childIndex = path.last;
    if (childIndex >= rawChildren.length) {
      throw FormatException('patch-path-out-of-range:$path');
    }

    rawChildren.removeAt(childIndex);
    return currentTree;
  }

  static SerializedNodeMap _findNodeAtPath(
    SerializedNodeMap root,
    Iterable<int> pathSegments,
  ) {
    var current = root;

    for (final segment in pathSegments) {
      final rawChildren = current['children'];
      if (rawChildren is! List) {
        throw const FormatException('patch-target-children-must-be-list');
      }

      if (segment >= rawChildren.length) {
        throw FormatException('patch-path-out-of-range:$pathSegments');
      }

      final child = rawChildren[segment];
      if (child is! Map) {
        throw const FormatException('patch-target-node-must-be-object');
      }

      current = SerializedTreeDocument.requireNodeMap(child);
      rawChildren[segment] = current;
    }

    return current;
  }
}
