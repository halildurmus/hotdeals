import 'base_config.dart';
import 'dev_config.dart';
import 'prod_config.dart';
import 'staging_config.dart';

/// A class for setting environment configuration dynamically.
class Environment {
  static const String dev = 'dev';
  static const String staging = 'staging';
  static const String prod = 'prod';

  /// Gives access to current environment configuration.
  late final BaseConfig config;

  /// Initializes the proper environment config for given environment value.
  void initialize(String environment) {
    config = _getConfig(environment);
  }

  BaseConfig _getConfig(String environment) {
    switch (environment) {
      case Environment.prod:
        return ProdConfig();
      case Environment.staging:
        return StagingConfig();
      default:
        return DevConfig();
    }
  }
}
