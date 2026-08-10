import 'package:example/router/app_routes.dart';
import 'package:example/router/catalog_routes.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Catalog branch'),
            FilledButton(
              key: const Key('catalog-product'),
              onPressed: () =>
                  PioneerRouterScope.of(context).push<void>(const ProductRoute(id: 42)),
              child: const Text('Open product inside branch'),
            ),
            TextButton(
              onPressed: () =>
                  PioneerRouterScope.rootOf(context).push<void>(const AdminRoute()),
              child: const Text('Open admin'),
            ),
          ],
        ),
      ),
    );
  }
}
