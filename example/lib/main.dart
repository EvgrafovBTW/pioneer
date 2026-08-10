import 'package:example/features/core/admin_screen.dart';
import 'package:example/features/core/root_screen.dart';
import 'package:example/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

void main() => runApp(const MainApp());

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final PioneerShellController shell;
  late final PioneerRouter rootRouter;

  @override
  void initState() {
    super.initState();
    shell = PioneerShellController(
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
    rootRouter = PioneerRouter(
      configuration: rootConfiguration(
        rootBuilder: (context, route) => RootScreen(
          shell: shell,
          onResetNavigation: _resetNavigation,
        ),
        adminBuilder: (context, route) => AdminScreen(
          onResetNavigation: _resetNavigation,
        ),
      ),
      onPopFallback: _handleSystemBack,
    );
  }

  void _resetNavigation() {
    shell.resetBranches();
    rootRouter.popToRoot();
  }

  bool _handleSystemBack() {
    final value = shell.handleSystemBack();

    ///? if app's flow doesnt allow exit on system back at all
    /// this method should always return true
    // return true;
    ///? Also, additional methods such as showing exit dialog may be called here

    return value;
  }

  @override
  void dispose() {
    rootRouter.dispose();
    shell.dispose();
    super.dispose();
  }

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
