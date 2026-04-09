import 'package:react_like_runtime_poc/src/runtime/bundle_loader.dart';

abstract class RuntimeHostBridge {
  Map<String, Object?> commitTree(Object? serializedTree);

  Map<String, Object?> commitPatch(Object? serializedPatch);

  void log(String level, String message);
}

abstract class RuntimeFacade {
  Future<RuntimeSession> createSession();
}

abstract class RuntimeSession {
  Future<void> attachHost(RuntimeHostBridge host);

  Future<void> evaluateBundle(String source);

  Future<BundleContractSnapshot> inspectContract();

  Future<void> bootstrap();

  Future<void> dispatchEvent(String handlerId, Map<String, Object?> payload);

  Future<void> dispose();
}
