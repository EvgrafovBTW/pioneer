import 'package:example/router/branch_keys.dart';
import 'package:example/router/configurations.dart';
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
      configuration: rootConfiguration(shell),
      onPopFallback: () {
        if (!shell.currentBranch.canPop) {
          return false;
        }

        shell.currentBranch.pop();

        return true;
      },
    );
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
