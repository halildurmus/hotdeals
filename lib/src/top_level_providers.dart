import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'services/auth_service.dart';
import 'services/auth_service_adapter.dart';

List<SingleChildStatelessWidget> buildTopLevelProviders() => [
      Provider<AuthService>(
        create: (_) => AuthServiceAdapter(),
        dispose: (_, authService) => authService.dispose(),
      ),
    ];
