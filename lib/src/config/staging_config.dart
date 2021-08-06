import 'base_config.dart';

/// An implementation of the [BaseConfig] for `Staging` environment that
/// many Widgets can interact with to read environment configuration.
class StagingConfig implements BaseConfig {
  @override
  String get apiBaseUrl => 'https://example.com';
}
