import 'package:react_like_runtime_poc/src/runtime/runtime_facade.dart';

class RuntimeBridge implements RuntimeHostBridge {
  RuntimeBridge({
    required this.onCommitTree,
    required this.onCommitPatch,
    required this.onLog,
  });

  final Map<String, Object?> Function(Object? serializedTree) onCommitTree;
  final Map<String, Object?> Function(Object? serializedPatch) onCommitPatch;
  final void Function(String level, String message) onLog;

  @override
  Map<String, Object?> commitTree(Object? serializedTree) {
    return onCommitTree(serializedTree);
  }

  @override
  Map<String, Object?> commitPatch(Object? serializedPatch) {
    return onCommitPatch(serializedPatch);
  }

  @override
  void log(String level, String message) {
    onLog(level, message);
  }
}
