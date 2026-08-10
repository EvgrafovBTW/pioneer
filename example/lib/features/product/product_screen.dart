import 'package:example/router/app_routes.dart';
import 'package:example/router/home_routes.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Product $id'),
            FilledButton(
              onPressed: context.pop,
              child: const Text('Back to catalog'),
            ),
            TextButton(
              key: const Key('product-admin'),
              onPressed: () => context.pushRoot<void>(const AdminRoute()),
              child: const Text('Open admin'),
            ),
            TextButton(
              key: const Key('product-to-home-details'),
              onPressed: () => context.goTo(
                const HomeDetailsRoute(),
              ),
              child: const Text('Go to Home details'),
            ),
          ],
        ),
      ),
    );
  }
}
