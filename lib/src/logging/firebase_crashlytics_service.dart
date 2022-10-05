import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseCrashlyticsProvider = Provider<FirebaseCrashlytics>(
    (ref) => throw UnimplementedError(),
    name: 'FirebaseCrashlyticsProvider');
