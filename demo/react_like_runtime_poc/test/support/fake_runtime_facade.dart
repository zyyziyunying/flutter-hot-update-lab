import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:react_like_runtime_poc/src/runtime/bundle_loader.dart';
import 'package:react_like_runtime_poc/src/runtime/runtime_facade.dart';

class StringAssetBundle extends CachingAssetBundle {
  StringAssetBundle(this.values);

  final Map<String, String> values;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = values[key];
    if (value == null) {
      throw StateError('Missing test asset: $key');
    }
    return value;
  }

  @override
  Future<ByteData> load(String key) async {
    final value = await loadString(key);
    final bytes = utf8.encode(value);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}

class FakeRuntimeFacade implements RuntimeFacade {
  FakeRuntimeFacade({
    required this.programsBySource,
    this.failBootstrapForSource = const <String>{},
  });

  final Map<String, FakeBundleProgram> programsBySource;
  final Set<String> failBootstrapForSource;

  @override
  Future<RuntimeSession> createSession() async {
    return FakeRuntimeSession(
      programsBySource: programsBySource,
      failBootstrapForSource: failBootstrapForSource,
    );
  }
}

class FakeRuntimeSession implements RuntimeSession {
  FakeRuntimeSession({
    required this.programsBySource,
    required this.failBootstrapForSource,
  });

  final Map<String, FakeBundleProgram> programsBySource;
  final Set<String> failBootstrapForSource;

  RuntimeHostBridge? _host;
  FakeBundleProgram? _program;
  String? _source;
  int _counter = 0;

  @override
  Future<void> attachHost(RuntimeHostBridge host) async {
    _host = host;
  }

  @override
  Future<void> dispatchEvent(
    String handlerId,
    Map<String, Object?> payload,
  ) async {
    final program = _program!;
    if (handlerId != program.handlerId) {
      throw StateError('Unknown handler id: $handlerId');
    }

    _counter += program.delta;
    _host!.commitTree(program.buildTree(_counter));
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> evaluateBundle(String source) async {
    final program = programsBySource[source];
    if (program == null) {
      throw StateError('Unknown bundle source: $source');
    }

    _source = source;
    _program = program;
    _counter = program.initialCounter;
  }

  @override
  Future<BundleContractSnapshot> inspectContract() async {
    final program = _program!;
    return BundleContractSnapshot(
      hasBootstrap: true,
      hasDispatchEvent: true,
      metadata: {
        'bundleId': program.bundleId,
        'bundleVersion': program.bundleVersion,
        'runtimeAbiVersion': 'poc-v1',
        'treeSchemaVersion': 'poc-tree-v1',
      },
    );
  }

  @override
  Future<void> bootstrap() async {
    if (failBootstrapForSource.contains(_source)) {
      throw StateError('bootstrap failed for $_source');
    }

    _host!.commitTree(_program!.buildTree(_counter));
  }
}

class FakeBundleProgram {
  const FakeBundleProgram({
    required this.bundleId,
    required this.bundleVersion,
    required this.title,
    required this.buttonLabel,
    required this.handlerId,
    required this.delta,
    this.initialCounter = 0,
  });

  final String bundleId;
  final String bundleVersion;
  final String title;
  final String buttonLabel;
  final String handlerId;
  final int delta;
  final int initialCounter;

  Map<String, Object?> buildTree(int counter) {
    return {
      'type': 'View',
      'props': {'padding': 24},
      'events': {},
      'children': [
        {
          'type': 'Text',
          'props': {'text': title, 'fontSize': 22, 'textColor': '#111111'},
          'events': {},
          'children': [],
        },
        {
          'type': 'Text',
          'props': {
            'text': 'Counter: $counter',
            'fontSize': 16,
            'textColor': '#444444',
          },
          'events': {},
          'children': [],
        },
        {
          'type': 'Button',
          'props': {'label': buttonLabel, 'padding': 12},
          'events': {'onPress': handlerId},
          'children': [],
        },
      ],
    };
  }
}
