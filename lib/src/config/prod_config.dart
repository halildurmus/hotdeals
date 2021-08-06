import 'base_config.dart';

/// An implementation of the [BaseConfig] for `Production` environment that
/// many Widgets can interact with to read environment configuration.
class ProdConfig implements BaseConfig {
  @override
  String get apiBaseUrl => 'https://example.com';
}
