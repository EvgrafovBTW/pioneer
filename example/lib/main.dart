import 'package:example/features/core/admin_screen.dart';
import 'package:example/features/core/root_screen.dart';
import 'package:example/router/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

void main() {
  final shell = PioneerShellController(
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
  final rootRouter = PioneerRouter(
    configuration: rootConfiguration(
      rootBuilder: (context, route) => PioneerShellScope(
        controller: shell,
        child: const RootScreen(),
      ),
      adminBuilder: (context, route) => PioneerShellScope(
        controller: shell,
        child: const AdminScreen(),
      ),
    ),
  );

  runApp(
    MainApp(
      shell: shell,
      rootRouter: rootRouter,
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
    required this.shell,
    required this.rootRouter,
  });

  final PioneerShellController shell;
  final PioneerRouter rootRouter;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _handleSystemBack() {
    final value = widget.shell.handleSystemBack();

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
    widget.shell.dispose();

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
