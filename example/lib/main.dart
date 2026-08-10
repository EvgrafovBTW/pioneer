import 'package:example/features/core/root_screen.dart';
import 'package:example/router/app_router.dart';
import 'package:flutter/foundation.dart';
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
      rootBuilder: (context, route) => PioneerShellScope(
        controller: branchShell,
        child: const RootScreen(),
      ),
      authBuilder: (context, route) => PioneerShellScope(
        controller: authShell,
      ),
    ),
  );

  runApp(
    MainApp(
      branchShell: branchShell,
      authShell: authShell,
      rootRouter: rootRouter,
    ),
  );
}

bool _readNeedAuth() => false;

class MainApp extends StatefulWidget {
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
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _handleSystemBack() {
    final shell =
        widget.rootRouter.currentRoute is AuthRoute ? widget.authShell : widget.branchShell;
    final value = shell.handleSystemBack();

    ///? if app's flow doesnt allow exit on system back at all
    /// this method should always return true
    // return true;
    ///? Also, additional methods such as showing exit dialog may be called here

    if (kDebugMode) {
      return true;
    }

    return value;
  }

  @override
  void dispose() {
    widget.rootRouter.dispose();
    widget.branchShell.dispose();
    widget.authShell.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PioneerRouterScope(
      router: widget.rootRouter,
      handleSystemBack: _handleSystemBack,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: widget.rootRouter.routerConfig,
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
