import 'package:example/router/app_routes.dart';
import 'package:example/router/home_routes.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Home branch'),
            Text('Local state: $counter', key: const Key('home-counter')),
            FilledButton(
              key: const Key('increment-home'),
              onPressed: () => setState(() => counter++),
              child: const Text('Increment local state'),
            ),
            OutlinedButton(
              key: const Key('home-details'),
              onPressed: () => context.push<void>(const HomeDetailsRoute()),
              child: const Text('Open inside Home branch'),
            ),
            TextButton(
              key: const Key('home-auth'),
              onPressed: () => context.pushRoot<void>(const AuthRoute()),
              child: const Text('Open auth'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeDetailsPage extends StatelessWidget {
  const HomeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Home details'),
            FilledButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Back inside branch'),
            ),
            TextButton(
              onPressed: () => context.pushRoot<void>(const AuthRoute()),
              child: const Text('Open auth'),
            ),
          ],
        ),
      ),
    );
  }
}
