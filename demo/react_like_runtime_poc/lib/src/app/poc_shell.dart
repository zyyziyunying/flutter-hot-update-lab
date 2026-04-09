import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:react_like_runtime_poc/src/render/element_node.dart';
import 'package:react_like_runtime_poc/src/render/element_parser.dart';
import 'package:react_like_runtime_poc/src/render/render_view.dart';
import 'package:react_like_runtime_poc/src/runtime/bundle_loader.dart';
import 'package:react_like_runtime_poc/src/runtime/runtime_bridge.dart';
import 'package:react_like_runtime_poc/src/runtime/runtime_facade.dart';

class PocShell extends StatefulWidget {
  PocShell({
    super.key,
    required this.runtimeFacade,
    AssetBundle? assetBundle,
    this.bundleLoader = const BundleLoader(),
    this.bundleAssets = const {
      'A': 'assets/bundles/bundle_a.js',
      'B': 'assets/bundles/bundle_b.js',
    },
  }) : assetBundle = assetBundle ?? rootBundle;

  final RuntimeFacade runtimeFacade;
  final AssetBundle assetBundle;
  final BundleLoader bundleLoader;
  final Map<String, String> bundleAssets;

  @override
  State<PocShell> createState() => _PocShellState();
}

class _PocShellState extends State<PocShell> {
  RuntimeSession? _activeSession;
  ElementNode? _activeTree;
  BundleMetadata? _activeBundle;
  String? _errorMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _activateBundle('A');
  }

  @override
  void dispose() {
    _activeSession?.dispose();
    super.dispose();
  }

  Future<void> _activateBundle(String bundleKey) async {
    final assetPath = widget.bundleAssets[bundleKey];
    if (assetPath == null) {
      setState(() {
        _errorMessage = 'Unknown bundle key: $bundleKey';
        _loading = false;
      });
      return;
    }

    final previousSession = _activeSession;
    final session = await widget.runtimeFacade.createSession();
    ElementNode? acceptedInitialTree;
    String? logError;

    final bridge = RuntimeBridge(
      onCommitTree: (serializedTree) {
        try {
          final parsedTree = ElementParser.parseTree(serializedTree);
          if (identical(session, _activeSession)) {
            if (!mounted) {
              return const {'ok': false, 'reason': 'widget-unmounted'};
            }

            setState(() {
              _activeTree = parsedTree;
              _errorMessage = null;
            });
          } else {
            acceptedInitialTree = parsedTree;
          }

          return const {'ok': true};
        } on FormatException {
          return const {'ok': false, 'reason': 'tree-validation-error'};
        }
      },
      onLog: (level, message) {
        if (level == 'error') {
          logError = message;
        }
      },
    );

    try {
      await session.attachHost(bridge);
      final source = await widget.bundleLoader.loadSource(
        widget.assetBundle,
        assetPath,
      );
      await session.evaluateBundle(source);
      final contract = await session.inspectContract();
      final bundleMetadata = BundleContractValidator.validate(contract);
      await session.bootstrap();

      final initialTree = acceptedInitialTree;
      if (initialTree == null) {
        throw StateError('bootstrap-did-not-commit-tree');
      }

      if (!mounted) {
        await session.dispose();
        return;
      }

      setState(() {
        _activeSession = session;
        _activeTree = initialTree;
        _activeBundle = bundleMetadata;
        _errorMessage = null;
        _loading = false;
      });

      if (!identical(previousSession, session)) {
        await previousSession?.dispose();
      }
    } catch (error) {
      await session.dispose();
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = logError ?? '$error';
        _loading = false;
      });
    }
  }

  Future<void> _dispatchEvent(String handlerId) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }

    try {
      await session.dispatchEvent(handlerId, const {});
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = '$error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('React-Like Runtime PoC')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fixed Flutter host', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: () => _activateBundle('A'),
                    child: const Text('Use Bundle A'),
                  ),
                  FilledButton(
                    onPressed: () => _activateBundle('B'),
                    child: const Text('Use Bundle B'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Active bundle: ${_activeBundle?.bundleId ?? 'none'}',
                style: theme.textTheme.titleMedium,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade700,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (_loading && _activeTree == null)
                const Center(child: CircularProgressIndicator())
              else if (_activeTree != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: RenderView(
                      root: _activeTree!,
                      onButtonPress: _dispatchEvent,
                    ),
                  ),
                )
              else
                const Text('No active tree'),
            ],
          ),
        ),
      ),
    );
  }
}
