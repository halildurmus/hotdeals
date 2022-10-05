import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggy/loggy.dart';

class ProviderLogger extends ProviderObserver {
  final _loggy = Loggy('ProviderLogger');

  @override
  void didAddProvider(
    ProviderBase<dynamic> provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (provider.name != null) {
      _loggy
        ..info(_msg('added', provider))
        ..info('         ${value.runtimeType}');
    }
  }

  @override
  void didUpdateProvider(
    ProviderBase<dynamic> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (provider.name != null) {
      _loggy.info(_msg('updated', provider));
    }

    if (newValue is AsyncData) {
      _loggy.info('         ${newValue.value}');
    } else {
      _loggy.info('         ${newValue.runtimeType}');
    }

    if (newValue is AsyncError) {
      _loggy.warning('async error', newValue.error, newValue.stackTrace);
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase<dynamic> provider,
    ProviderContainer container,
  ) {
    if (provider.name != null) {
      _loggy.info(_msg('disposed', provider));
    }
  }

  String _msg(String type, ProviderBase<dynamic> provider) {
    final buffer = StringBuffer(type.padRight(9))
      ..write('"${provider.name}" ')
      ..write('${provider.runtimeType}');

    return buffer.toString();
  }
}
