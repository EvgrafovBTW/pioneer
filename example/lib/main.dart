import 'package:example/features/core/root_screen.dart';
import 'package:example/features/product/product_screen.dart';
import 'package:example/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:pioneer_router/pioneer_router.dart' as pioneer;

void main() {
  final needAuth = _readNeedAuth();

  final pioneer.PioneerRoute initialRoute = needAuth ? const AuthRoute() : const RootRoute();

  final branchShell = pioneer.PioneerShellController.branches(
    branches: [
      pioneer.PioneerShellBranch(
        key: AppBranchKeys.home,
        configuration: homeConfiguration,
      ),
      pioneer.PioneerShellBranch(
        key: AppBranchKeys.catalog,
        configuration: catalogConfiguration,
      ),
      pioneer.PioneerShellBranch(
        key: AppBranchKeys.profile,
        configuration: profileConfiguration,
      ),
    ],
  );

  final authShell = pioneer.PioneerShellController.single(
    configuration: authConfiguration,
  );

  final rootRouter = pioneer.PioneerRouter(
    configuration: rootConfiguration(
      initialRoute: initialRoute,
      rootShell: branchShell,
      authShell: authShell,
      rootBuilder: (context, route) => pioneer.PioneerShellScope(
        controller: branchShell,
        child: const RootScreen(),
      ),
      authBuilder: (context, route) => pioneer.PioneerShellScope(
        controller: authShell,
      ),
      productBuilder: (context, route) => pioneer.PioneerShellScope(
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

  final pioneer.PioneerShellController branchShell;
  final pioneer.PioneerShellController authShell;
  final pioneer.PioneerRouter rootRouter;

  @override
  Widget build(BuildContext context) {
    return pioneer.PioneerRouterScope(
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
