import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../helpers/context_extensions.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage(this.error, {super.key});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Oops! Something went wrong.'),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.go('/'),
              child: Text(context.l.home),
            ),
          ],
        ),
      ),
    );
  }
}
