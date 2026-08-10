import 'package:example/features/core/root_screen.dart';
import 'package:example/features/product/product_screen.dart';
import 'package:example/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

void main() {
  final needAuth = _readNeedAuth();

  final PioneerRoute initialRoute = needAuth ? const AuthRoute() : const RootRoute();

  final branchShell = PioneerShellController.branches(
    branches: [
      PioneerShellBranch(
        key: AppBranchKeys.home,
        configuration: homeConfiguration,
      ),
      PioneerShellBranch(
        key: AppBranchKeys.catalog,
        configuration: catalogConfiguration,
      ),
      PioneerShellBranch(
        key: AppBranchKeys.profile,
        configuration: profileConfiguration,
      ),
    ],
  );

  final authShell = PioneerShellController.single(
    configuration: authConfiguration,
  );

  final rootRouter = PioneerRouter(
    configuration: rootConfiguration(
      initialRoute: initialRoute,
      rootShell: branchShell,
      authShell: authShell,
      rootBuilder: (context, route) => PioneerShellScope(
        controller: branchShell,
        child: const RootScreen(),
      ),
      authBuilder: (context, route) => PioneerShellScope(
        controller: authShell,
      ),
      productBuilder: (context, route) => PioneerShellScope(
        controller: branchShell,
        child: ProductScreen(id: route.id),
      ),
    ),
    deepLinkHandler: (uri) {
      branchShell.goToUri(uri);

      return const RootRoute();
    },
  );

  runApp(
    MainApp(
      branchShell: branchShell,
      authShell: authShell,
      rootRouter: rootRouter,
    ),
  );
}

bool _readNeedAuth() => true;

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.branchShell,
    required this.authShell,
    required this.rootRouter,
  });

  final PioneerShellController branchShell;
  final PioneerShellController authShell;
  final PioneerRouter rootRouter;

  @override
  Widget build(BuildContext context) {
    return PioneerRouterScope(
      router: rootRouter,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: rootRouter.routerConfig,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: Colors.green,
            surface: Colors.white,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
      ),
    );
  }
}
