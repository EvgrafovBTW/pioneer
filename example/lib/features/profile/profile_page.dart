import 'package:example/router/profile_routes.dart';
import 'package:flutter/material.dart';
import 'package:pioneer_router/pioneer_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Profile branch'),
            FilledButton(
              key: const Key('profile-details'),
              onPressed: () => context.push<void>(const ProfileDetailsRoute()),
              child: const Text('Open inside Profile branch'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailsPage extends StatelessWidget {
  const ProfileDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Profile details'),
            FilledButton(
              onPressed: context.pop,
              child: const Text('Back to profile'),
            ),
          ],
        ),
      ),
    );
  }
}
