import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(HotUpdateDemoApp());
}

class HotUpdateDemoApp extends StatelessWidget {
  HotUpdateDemoApp({super.key, PayloadRepository? repository})
    : repository = repository ?? LocalPayloadRepository();

  final PayloadRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Hot Update Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF145DA0)),
      ),
      home: HotUpdateDemoScreen(repository: repository),
    );
  }
}

class HotUpdateDemoScreen extends StatefulWidget {
  const HotUpdateDemoScreen({super.key, required this.repository});

  final PayloadRepository repository;

  @override
  State<HotUpdateDemoScreen> createState() => _HotUpdateDemoScreenState();
}

class _HotUpdateDemoScreenState extends State<HotUpdateDemoScreen> {
  PayloadLoadResult? _result;
  Object? _error;
  bool _loading = true;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadPayload();
  }

  Future<void> _loadPayload({String? activateVariant}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = activateVariant == null
          ? await widget.repository.ensureReady()
          : await widget.repository.activateVariant(activateVariant);

      if (!mounted) {
        return;
      }

      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _handleAction(PayloadAction action) {
    switch (action.type) {
      case PayloadActionType.incrementCounter:
        setState(() {
          _counter += action.delta;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Minimal Hot Update Demo')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _ErrorState(error: _error!, onRetry: _loadPayload)
            : _DemoBody(
                result: _result!,
                counter: _counter,
                onReload: _loadPayload,
                onActivateVariant: (variant) =>
                    _loadPayload(activateVariant: variant),
                onAction: _handleAction,
                theme: theme,
              ),
      ),
    );
  }
}

class _DemoBody extends StatelessWidget {
  const _DemoBody({
    required this.result,
    required this.counter,
    required this.onReload,
    required this.onActivateVariant,
    required this.onAction,
    required this.theme,
  });

  final PayloadLoadResult result;
  final int counter;
  final VoidCallback onReload;
  final ValueChanged<String> onActivateVariant;
  final ValueChanged<PayloadAction> onAction;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fixed host page', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Switch payload A/B or edit the local payload file directly, then reload.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: () => onActivateVariant('A'),
                child: const Text('Use Payload A'),
              ),
              FilledButton(
                onPressed: () => onActivateVariant('B'),
                child: const Text('Use Payload B'),
              ),
              OutlinedButton(
                onPressed: onReload,
                child: const Text('Reload Current Payload'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active payload: ${result.status.activeVariant}'),
                  const SizedBox(height: 8),
                  SelectableText(
                    'Local payload file: ${result.status.payloadFilePath}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Counter value: $counter',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MinimalPayloadRenderer(
                root: result.payload.screen,
                onAction: onAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Failed to load payload',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class MinimalPayloadRenderer extends StatelessWidget {
  const MinimalPayloadRenderer({
    super.key,
    required this.root,
    required this.onAction,
  });

  final PayloadNode root;
  final ValueChanged<PayloadAction> onAction;

  @override
  Widget build(BuildContext context) {
    return _buildNode(root);
  }

  Widget _buildNode(PayloadNode node) {
    final style = node.style;
    switch (node.type) {
      case PayloadNodeType.column:
        return _wrapStyle(
          node: node,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: node.children.map(_buildNode).toList(),
          ),
        );
      case PayloadNodeType.text:
        return _wrapStyle(
          node: node,
          child: Text(
            node.text ?? '',
            style: TextStyle(color: style.textColor, fontSize: style.fontSize),
          ),
        );
      case PayloadNodeType.button:
        return _wrapStyle(
          node: node,
          child: ElevatedButton(
            onPressed: node.action == null
                ? null
                : () => onAction(node.action!),
            child: Text(node.text ?? 'Button'),
          ),
        );
      case PayloadNodeType.container:
        final child = node.children.isEmpty
            ? const SizedBox.shrink()
            : node.children.length == 1
            ? _buildNode(node.children.first)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: node.children.map(_buildNode).toList(),
              );
        return _wrapStyle(node: node, child: child, forceContainer: true);
    }
  }

  Widget _wrapStyle({
    required PayloadNode node,
    required Widget child,
    bool forceContainer = false,
  }) {
    final style = node.style;
    if (!forceContainer &&
        style.padding == null &&
        style.backgroundColor == null) {
      return child;
    }

    return Container(
      padding: style.padding,
      color: style.backgroundColor,
      child: child,
    );
  }
}

enum PayloadNodeType { column, text, button, container }

enum PayloadActionType { incrementCounter }

class DemoPayload {
  const DemoPayload({required this.version, required this.screen});

  factory DemoPayload.fromJson(Map<String, dynamic> json) {
    return DemoPayload(
      version: json['version'] as int? ?? 1,
      screen: PayloadNode.fromJson(_asMap(json['screen'], 'screen')),
    );
  }

  final int version;
  final PayloadNode screen;
}

class PayloadNode {
  const PayloadNode({
    required this.type,
    required this.children,
    required this.style,
    this.text,
    this.action,
  });

  factory PayloadNode.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String?;
    if (rawType == null) {
      throw const FormatException('Payload node is missing "type".');
    }

    return PayloadNode(
      type: switch (rawType) {
        'column' => PayloadNodeType.column,
        'text' => PayloadNodeType.text,
        'button' => PayloadNodeType.button,
        'container' => PayloadNodeType.container,
        _ => throw FormatException('Unsupported node type: $rawType'),
      },
      text: json['text'] as String?,
      children: (json['children'] as List<dynamic>? ?? const [])
          .map((child) => PayloadNode.fromJson(_asMap(child, 'children item')))
          .toList(),
      style: PayloadStyle.fromJson(
        (json['style'] as Map<Object?, Object?>?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
      action: json['action'] == null
          ? null
          : PayloadAction.fromJson(_asMap(json['action'], 'action')),
    );
  }

  final PayloadNodeType type;
  final String? text;
  final List<PayloadNode> children;
  final PayloadStyle style;
  final PayloadAction? action;
}

class PayloadStyle {
  const PayloadStyle({
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  });

  factory PayloadStyle.fromJson(Map<String, dynamic> json) {
    return PayloadStyle(
      padding: _parsePadding(json['padding']),
      backgroundColor: _parseColor(json['backgroundColor'] as String?),
      textColor: _parseColor(json['textColor'] as String?),
      fontSize: (json['fontSize'] as num?)?.toDouble(),
    );
  }

  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
}

class PayloadAction {
  const PayloadAction({required this.type, required this.delta});

  factory PayloadAction.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String?;
    if (rawType == null) {
      throw const FormatException('Payload action is missing "type".');
    }

    return PayloadAction(
      type: switch (rawType) {
        'increment_counter' => PayloadActionType.incrementCounter,
        _ => throw FormatException('Unsupported action type: $rawType'),
      },
      delta: json['delta'] as int? ?? 1,
    );
  }

  final PayloadActionType type;
  final int delta;
}

class PayloadStatus {
  const PayloadStatus({
    required this.activeVariant,
    required this.payloadFilePath,
  });

  final String activeVariant;
  final String payloadFilePath;
}

class PayloadLoadResult {
  const PayloadLoadResult({required this.payload, required this.status});

  final DemoPayload payload;
  final PayloadStatus status;
}

abstract class PayloadRepository {
  const PayloadRepository();

  Future<PayloadLoadResult> ensureReady();

  Future<PayloadLoadResult> activateVariant(String variant);
}

class LocalPayloadRepository extends PayloadRepository {
  LocalPayloadRepository({AssetBundle? assetBundle})
    : assetBundle = assetBundle ?? rootBundle;

  final AssetBundle assetBundle;

  static const Map<String, String> _variantAssets = {
    'A': 'assets/payloads/payload_a.json',
    'B': 'assets/payloads/payload_b.json',
  };

  @override
  Future<PayloadLoadResult> ensureReady() async {
    final directory = await _ensureDirectory();
    final payloadFile = File('${directory.path}/current_payload.json');
    final variantFile = File('${directory.path}/current_variant.txt');

    if (!await payloadFile.exists()) {
      await _writeVariant(
        'A',
        payloadFile: payloadFile,
        variantFile: variantFile,
      );
    } else if (!await variantFile.exists()) {
      await variantFile.writeAsString('A');
    }

    return _readCurrent(payloadFile: payloadFile, variantFile: variantFile);
  }

  @override
  Future<PayloadLoadResult> activateVariant(String variant) async {
    final directory = await _ensureDirectory();
    final payloadFile = File('${directory.path}/current_payload.json');
    final variantFile = File('${directory.path}/current_variant.txt');
    await _writeVariant(
      variant,
      payloadFile: payloadFile,
      variantFile: variantFile,
    );
    return _readCurrent(payloadFile: payloadFile, variantFile: variantFile);
  }

  Future<Directory> _ensureDirectory() async {
    final directory = Directory(
      '${Directory.systemTemp.path}/minimal_hot_update_demo',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<void> _writeVariant(
    String variant, {
    required File payloadFile,
    required File variantFile,
  }) async {
    final assetPath = _variantAssets[variant];
    if (assetPath == null) {
      throw FormatException('Unknown payload variant: $variant');
    }

    final contents = await assetBundle.loadString(assetPath);
    await payloadFile.writeAsString(contents);
    await variantFile.writeAsString(variant);
  }

  Future<PayloadLoadResult> _readCurrent({
    required File payloadFile,
    required File variantFile,
  }) async {
    final payloadJson =
        jsonDecode(await payloadFile.readAsString()) as Map<String, dynamic>;
    final activeVariant = (await variantFile.readAsString()).trim();

    return PayloadLoadResult(
      payload: DemoPayload.fromJson(payloadJson),
      status: PayloadStatus(
        activeVariant: activeVariant,
        payloadFilePath: payloadFile.path,
      ),
    );
  }
}

class MemoryPayloadRepository extends PayloadRepository {
  MemoryPayloadRepository({
    required Map<String, String> payloads,
    String initialVariant = 'A',
  }) : _payloads = payloads,
       _activeVariant = initialVariant;

  final Map<String, String> _payloads;
  String _activeVariant;

  @override
  Future<PayloadLoadResult> ensureReady() async => _current();

  @override
  Future<PayloadLoadResult> activateVariant(String variant) async {
    if (!_payloads.containsKey(variant)) {
      throw FormatException('Unknown payload variant: $variant');
    }
    _activeVariant = variant;
    return _current();
  }

  Future<PayloadLoadResult> _current() async {
    final raw = _payloads[_activeVariant];
    if (raw == null) {
      throw FormatException('Missing payload for variant: $_activeVariant');
    }

    return PayloadLoadResult(
      payload: DemoPayload.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      status: PayloadStatus(
        activeVariant: _activeVariant,
        payloadFilePath: '/memory/current_payload.json',
      ),
    );
  }
}

Map<String, dynamic> _asMap(Object? value, String fieldName) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map<Object?, Object?>) {
    return value.cast<String, dynamic>();
  }
  throw FormatException('Expected "$fieldName" to be an object.');
}

EdgeInsets? _parsePadding(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return EdgeInsets.all(value.toDouble());
  }
  throw const FormatException('Only numeric padding is supported.');
}

Color? _parseColor(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  final normalized = value.replaceFirst('#', '');
  if (normalized.length != 6) {
    throw FormatException('Color must use #RRGGBB format: $value');
  }

  final colorValue = int.parse('FF$normalized', radix: 16);
  return Color(colorValue);
}
