import 'package:flutter_test/flutter_test.dart';
import 'package:react_like_runtime_poc/src/runtime/bundle_loader.dart';

void main() {
  group('BundleContractValidator.validate', () {
    test('accepts the current poc contract', () {
      final result = BundleContractValidator.validate(
        const BundleContractSnapshot(
          hasBootstrap: true,
          hasDispatchEvent: true,
          metadata: {
            'bundleId': 'bundle-a',
            'bundleVersion': '1.0.0',
            'runtimeAbiVersion': 'poc-v1',
            'treeSchemaVersion': 'poc-tree-v1',
          },
        ),
      );

      expect(result.bundleId, 'bundle-a');
      expect(result.bundleVersion, '1.0.0');
      expect(result.runtimeAbiVersion, 'poc-v1');
      expect(result.treeSchemaVersion, 'poc-tree-v1');
    });

    test('rejects missing bootstrap global', () {
      expect(
        () => BundleContractValidator.validate(
          const BundleContractSnapshot(
            hasBootstrap: false,
            hasDispatchEvent: true,
            metadata: {
              'bundleId': 'bundle-a',
              'bundleVersion': '1.0.0',
              'runtimeAbiVersion': 'poc-v1',
              'treeSchemaVersion': 'poc-tree-v1',
            },
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing dispatch event global', () {
      expect(
        () => BundleContractValidator.validate(
          const BundleContractSnapshot(
            hasBootstrap: true,
            hasDispatchEvent: false,
            metadata: {
              'bundleId': 'bundle-a',
              'bundleVersion': '1.0.0',
              'runtimeAbiVersion': 'poc-v1',
              'treeSchemaVersion': 'poc-tree-v1',
            },
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing bundle metadata', () {
      expect(
        () => BundleContractValidator.validate(
          const BundleContractSnapshot(
            hasBootstrap: true,
            hasDispatchEvent: true,
            metadata: null,
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects incompatible runtime abi version', () {
      expect(
        () => BundleContractValidator.validate(
          const BundleContractSnapshot(
            hasBootstrap: true,
            hasDispatchEvent: true,
            metadata: {
              'bundleId': 'bundle-a',
              'bundleVersion': '1.0.0',
              'runtimeAbiVersion': 'poc-v2',
              'treeSchemaVersion': 'poc-tree-v1',
            },
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects incompatible tree schema version', () {
      expect(
        () => BundleContractValidator.validate(
          const BundleContractSnapshot(
            hasBootstrap: true,
            hasDispatchEvent: true,
            metadata: {
              'bundleId': 'bundle-a',
              'bundleVersion': '1.0.0',
              'runtimeAbiVersion': 'poc-v1',
              'treeSchemaVersion': 'poc-tree-v2',
            },
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects invalid metadata fields', () {
      expect(
        () => BundleContractValidator.validate(
          const BundleContractSnapshot(
            hasBootstrap: true,
            hasDispatchEvent: true,
            metadata: {
              'bundleId': '',
              'bundleVersion': '1.0.0',
              'runtimeAbiVersion': 'poc-v1',
              'treeSchemaVersion': 'poc-tree-v1',
            },
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
