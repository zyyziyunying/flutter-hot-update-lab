import 'package:flutter/services.dart';

class BundleContractSnapshot {
  const BundleContractSnapshot({
    required this.hasBootstrap,
    required this.hasDispatchEvent,
    required this.metadata,
  });

  final bool hasBootstrap;
  final bool hasDispatchEvent;
  final Map<String, Object?>? metadata;
}

class BundleMetadata {
  const BundleMetadata({
    required this.bundleId,
    required this.bundleVersion,
    required this.runtimeAbiVersion,
    required this.treeSchemaVersion,
  });

  final String bundleId;
  final String bundleVersion;
  final String runtimeAbiVersion;
  final String treeSchemaVersion;
}

class BundleContractValidator {
  static const runtimeAbiVersion = 'poc-v1';
  static const treeSchemaVersion = 'poc-tree-v1';

  static BundleMetadata validate(BundleContractSnapshot snapshot) {
    if (!snapshot.hasBootstrap) {
      throw const FormatException('missing-bootstrap-global');
    }

    if (!snapshot.hasDispatchEvent) {
      throw const FormatException('missing-dispatch-event-global');
    }

    final metadata = snapshot.metadata;
    if (metadata == null) {
      throw const FormatException('missing-bundle-meta');
    }

    final bundleId = _requireString(metadata, 'bundleId');
    final bundleVersion = _requireString(metadata, 'bundleVersion');
    final runtimeVersion = _requireString(metadata, 'runtimeAbiVersion');
    final treeVersion = _requireString(metadata, 'treeSchemaVersion');

    if (runtimeVersion != runtimeAbiVersion) {
      throw FormatException('unsupported-runtime-abi:$runtimeVersion');
    }

    if (treeVersion != treeSchemaVersion) {
      throw FormatException('unsupported-tree-schema:$treeVersion');
    }

    return BundleMetadata(
      bundleId: bundleId,
      bundleVersion: bundleVersion,
      runtimeAbiVersion: runtimeVersion,
      treeSchemaVersion: treeVersion,
    );
  }

  static String _requireString(Map<String, Object?> metadata, String key) {
    final value = metadata[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('invalid-metadata-field:$key');
    }
    return value;
  }
}

class BundleLoader {
  const BundleLoader();

  Future<String> loadSource(AssetBundle assetBundle, String assetPath) {
    return assetBundle.loadString(assetPath);
  }
}
