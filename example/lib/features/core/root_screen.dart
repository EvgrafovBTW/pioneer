import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key, required this.shell});

  final PioneerShellController shell;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: shell,
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Pioneer shell example'),
          actions: [
            IconButton(
              key: const Key('reset-all'),
              tooltip: 'Reset all navigation',
              onPressed: () => _resetAll(context),
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
        body: PioneerStatefulShell(controller: shell),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: shell.currentIndex,
          onTap: shell.goBranch,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _resetAll(BuildContext context) {
    shell.resetBranches();
    PioneerRouterScope.rootOf(context).popToRoot();
  }
}
