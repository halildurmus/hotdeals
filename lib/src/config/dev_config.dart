import 'base_config.dart';

/// An implementation of the [BaseConfig] for `Development` environment that
/// many Widgets can interact with to read environment configuration.
class DevConfig implements BaseConfig {
  @override
  String get apiBaseUrl => 'http://10.0.2.2:8080';
}
