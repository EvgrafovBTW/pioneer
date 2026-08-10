import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Auth page is opened above the bottom bar.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: context.pop,
              child: const Text('Close auth'),
            ),
            TextButton.icon(
              key: const Key('auth-reset-all'),
              onPressed: () => _resetNavigation(context),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Full navigation reset'),
            ),
          ],
        ),
      ),
    );
  }

  void _resetNavigation(BuildContext context) {
    context.resetBranches();
    context.popToRoot();
  }
}
