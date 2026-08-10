import 'package:example/router/app_routes.dart';
import 'package:example/router/home_routes.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final router = context.pioneerRouter;
    final returnsToHome = identical(router, context.pioneerRootRouter) && router.isDeepLinkRoute;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Product $id'),
            FilledButton(
              onPressed: () => _handleBack(context, returnsToHome),
              child: Text(returnsToHome ? 'Back to home' : 'Back'),
            ),
            TextButton(
              key: const Key('product-auth'),
              onPressed: () => context.pushRoot<void>(const AuthRoute()),
              child: const Text('Open auth'),
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

  void _handleBack(BuildContext context, bool returnsToHome) {
    if (!returnsToHome) {
      context.pop();

      return;
    }

    context.resetBranches();
    context.resetRoot(const RootRoute());
  }
}
