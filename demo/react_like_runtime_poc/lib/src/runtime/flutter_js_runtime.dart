import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';
import 'package:react_like_runtime_poc/src/runtime/bundle_loader.dart';
import 'package:react_like_runtime_poc/src/runtime/runtime_facade.dart';

class FlutterJsRuntimeFacade implements RuntimeFacade {
  const FlutterJsRuntimeFacade();

  @override
  Future<RuntimeSession> createSession() async {
    return FlutterJsRuntimeSession(runtime: getJavascriptRuntime(xhr: false));
  }
}

class FlutterJsRuntimeSession implements RuntimeSession {
  FlutterJsRuntimeSession({required JavascriptRuntime runtime})
    : _runtime = runtime;

  final JavascriptRuntime _runtime;
  RuntimeHostBridge? _host;

  String get _engineId => _runtime.getEngineInstanceId();

  @override
  Future<void> attachHost(RuntimeHostBridge host) async {
    _host = host;

    final commitChannel = '__poc_commit_tree_$_engineId';
    final patchChannel = '__poc_commit_patch_$_engineId';
    final logChannel = '__poc_log_$_engineId';

    _runtime.onMessage(commitChannel, (dynamic args) {
      return host.commitTree(args);
    });

    _runtime.onMessage(patchChannel, (dynamic args) {
      return host.commitPatch(args);
    });

    _runtime.onMessage(logChannel, (dynamic args) {
      if (args is Map) {
        host.log(
          args['level']?.toString() ?? 'info',
          args['message']?.toString() ?? '',
        );
      }

      return true;
    });

    _evaluateOrThrow('''
      globalThis.__poc_host = {
        commitTree: function(tree) {
          return sendMessage(${jsonEncode(commitChannel)}, JSON.stringify(tree));
        },
        commitPatch: function(patch) {
          return sendMessage(${jsonEncode(patchChannel)}, JSON.stringify(patch));
        },
        log: function(level, message) {
          return sendMessage(
            ${jsonEncode(logChannel)},
            JSON.stringify({ level: String(level), message: String(message) })
          );
        }
      };
      ''', sourceUrl: 'host_bridge.js');
  }

  @override
  Future<void> bootstrap() async {
    _requireHost();
    _evaluateOrThrow(
      'globalThis.__poc_bootstrap(globalThis.__poc_host);',
      sourceUrl: 'bootstrap.js',
    );
  }

  @override
  Future<void> dispatchEvent(
    String handlerId,
    Map<String, Object?> payload,
  ) async {
    _evaluateOrThrow(
      'globalThis.__poc_dispatch_event(${jsonEncode(handlerId)}, ${jsonEncode(payload)});',
      sourceUrl: 'dispatch_event.js',
    );
  }

  @override
  Future<void> dispose() async {
    _runtime.dispose();
  }

  @override
  Future<void> evaluateBundle(String source) async {
    _evaluateOrThrow(source, sourceUrl: 'bundle.js');
  }

  @override
  Future<BundleContractSnapshot> inspectContract() async {
    final hasBootstrap =
        _evaluateOrThrow(
          "typeof globalThis.__poc_bootstrap === 'function';",
          sourceUrl: 'inspect_bootstrap.js',
        ).stringResult ==
        'true';

    final hasDispatchEvent =
        _evaluateOrThrow(
          "typeof globalThis.__poc_dispatch_event === 'function';",
          sourceUrl: 'inspect_dispatch.js',
        ).stringResult ==
        'true';

    final metadataJson = _evaluateOrThrow(
      'JSON.stringify(globalThis.__poc_bundle_meta ?? null);',
      sourceUrl: 'inspect_meta.js',
    ).stringResult;

    final metadata = metadataJson == 'null'
        ? null
        : Map<String, Object?>.from(
            jsonDecode(metadataJson) as Map<dynamic, dynamic>,
          );

    return BundleContractSnapshot(
      hasBootstrap: hasBootstrap,
      hasDispatchEvent: hasDispatchEvent,
      metadata: metadata,
    );
  }

  JsEvalResult _evaluateOrThrow(String code, {required String sourceUrl}) {
    final result = _runtime.evaluate(code, sourceUrl: sourceUrl);
    _runtime.executePendingJob();

    if (result.isError) {
      throw StateError(result.stringResult);
    }

    return result;
  }

  void _requireHost() {
    if (_host == null) {
      throw StateError('Host bridge is not attached.');
    }
  }
}
