import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:react_like_runtime_poc/src/render/element_node.dart';
import 'package:react_like_runtime_poc/src/render/element_parser.dart';
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

    if (program.dispatchLogError != null) {
      _host!.log('error', program.dispatchLogError!);
      return;
    }

    _counter += program.delta;
    if (program.rerenderPatch != null) {
      _host!.commitPatch(program.rerenderPatch);
      return;
    }

    _host!.commitTree(program.rerenderTree ?? program.buildTree(_counter));
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
      hasBootstrap: program.hasBootstrap,
      hasDispatchEvent: program.hasDispatchEvent,
      metadata: program.metadata,
    );
  }

  @override
  Future<void> bootstrap() async {
    if (failBootstrapForSource.contains(_source)) {
      throw StateError('bootstrap failed for $_source');
    }

    final program = _program!;
    _host!.commitTree(program.bootstrapTree ?? program.buildTree(_counter));
  }
}

class FakeBundleProgram {
  FakeBundleProgram({
    required this.bundleId,
    required this.bundleVersion,
    required this.title,
    required this.buttonLabel,
    required this.handlerId,
    required this.delta,
    this.initialCounter = 0,
    this.hasBootstrap = true,
    this.hasDispatchEvent = true,
    String runtimeAbiVersion = 'poc-v1',
    String treeSchemaVersion = 'poc-tree-v1',
    this.bootstrapTree,
    this.rerenderTree,
    this.rerenderPatch,
    this.dispatchLogError,
  }) : metadata = {
         'bundleId': bundleId,
         'bundleVersion': bundleVersion,
         'runtimeAbiVersion': runtimeAbiVersion,
         'treeSchemaVersion': treeSchemaVersion,
       };

  final String bundleId;
  final String bundleVersion;
  final String title;
  final String buttonLabel;
  final String handlerId;
  final int delta;
  final int initialCounter;
  final bool hasBootstrap;
  final bool hasDispatchEvent;
  final Map<String, Object?>? metadata;
  final Object? bootstrapTree;
  final Object? rerenderTree;
  final Object? rerenderPatch;
  final String? dispatchLogError;

  ElementNode parsedBootstrapTree() {
    return ElementParser.parseTree(bootstrapTree ?? buildTree(initialCounter));
  }

  Map<String, Object?> buildTree(int counter) {
    return {
      'type': 'View',
      'key': 'screen-root',
      'props': {'padding': 24},
      'events': {},
      'children': [
        {
          'type': 'Text',
          'key': 'title-node',
          'props': {'text': title, 'fontSize': 22, 'textColor': '#111111'},
          'events': {},
          'children': [],
        },
        {
          'type': 'Text',
          'key': 'count-node',
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
          'key': 'primary-button',
          'props': {'label': buttonLabel, 'padding': 12},
          'events': {'onPress': handlerId},
          'children': [],
        },
      ],
    };
  }
}
