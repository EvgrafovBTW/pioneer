import 'package:example/router/app_routes.dart';
import 'package:example/router/auth_routes.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Single-stack auth shell'),

            const SizedBox(height: 16),

            FilledButton(
              onPressed: () => context.resetRoot(const RootRoute()),
              child: const Text('Sign in'),
            ),

            TextButton.icon(
              key: const Key('open-registration'),
              onPressed: () => context.push<void>(const RegistrationRoute()),
              icon: const Icon(Icons.person_add),
              label: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration')),
      body: Center(
        child: FilledButton(
          onPressed: context.pop,
          child: const Text('Back to sign in'),
        ),
      ),
    );
  }
}
