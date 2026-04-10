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
    this.fromPath,
    this.node,
  });

  final String op;
  final List<int> path;
  final List<int>? fromPath;
  final SerializedNodeMap? node;

  static TreePatchOperation parse(Object? rawOperation) {
    if (rawOperation is! Map) {
      throw const FormatException('patch-op-must-be-object');
    }

    final op = rawOperation['op'];
    if (op != 'replace' && op != 'insert' && op != 'remove' && op != 'move') {
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

    List<int>? parseIndexPath(Object? rawValue, String fieldName) {
      if (rawValue is! List) {
        throw FormatException('$fieldName-must-be-list');
      }

      return rawValue.map((segment) {
        if (segment is! int || segment < 0) {
          throw FormatException('$fieldName-must-contain-non-negative-int');
        }
        return segment;
      }).toList(growable: false);
    }

    final operationType = op as String;

    return TreePatchOperation(
      op: operationType,
      path: path,
      fromPath: operationType == 'move'
          ? parseIndexPath(rawOperation['from'], 'patch-from')
          : null,
      node: operationType == 'remove' || operationType == 'move'
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
        case 'move':
          nextTree = _applyMove(
            currentTree: nextTree,
            fromPath: operation.fromPath!,
            toPath: operation.path,
          );
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

  static SerializedNodeMap _applyMove({
    required SerializedNodeMap currentTree,
    required List<int> fromPath,
    required List<int> toPath,
  }) {
    if (fromPath.isEmpty || toPath.isEmpty) {
      throw const FormatException('move-operation-cannot-target-root');
    }

    final fromParentPath = fromPath.take(fromPath.length - 1).toList();
    final toParentPath = toPath.take(toPath.length - 1).toList();

    if (!_pathsEqual(fromParentPath, toParentPath)) {
      throw const FormatException('move-operation-must-stay-within-parent');
    }

    final parent = _findNodeAtPath(currentTree, fromParentPath);
    final rawChildren = parent['children'];
    if (rawChildren is! List) {
      throw const FormatException('patch-target-children-must-be-list');
    }

    final fromIndex = fromPath.last;
    var toIndex = toPath.last;
    if (fromIndex >= rawChildren.length || toIndex > rawChildren.length) {
      throw FormatException('patch-path-out-of-range:$fromPath->$toPath');
    }

    if (fromIndex == toIndex) {
      return currentTree;
    }

    final movedChild = rawChildren.removeAt(fromIndex);
    if (fromIndex < toIndex) {
      toIndex -= 1;
    }

    rawChildren.insert(toIndex, movedChild);
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

  static bool _pathsEqual(List<int> left, List<int> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) {
        return false;
      }
    }

    return true;
  }
}
