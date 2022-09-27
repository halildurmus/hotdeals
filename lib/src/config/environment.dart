import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_config.dart';
import 'dev_config.dart';
import 'prod_config.dart';
import 'staging_config.dart';

final environmentConfigProvider = Provider<BaseConfig>((ref) {
  const environmentKey =
      String.fromEnvironment('ENV', defaultValue: Environment.dev);
  return Environment(environmentKey).config;
});

/// A class for setting environment configuration dynamically.
class Environment {
  Environment(String environment) : config = getConfig(environment);

  /// Gives access to current environment configuration.
  final BaseConfig config;

  static const String dev = 'dev';
  static const String staging = 'staging';
  static const String prod = 'prod';

  /// Initializes the proper environment config for given environment value.
  static BaseConfig getConfig(String environment) {
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
