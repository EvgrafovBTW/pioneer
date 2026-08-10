import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.pioneerShell;

    return ListenableBuilder(
      listenable: shell,
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Pioneer shell example'),
          actions: [
            IconButton(
              key: const Key('reset-all'),
              tooltip: 'Reset all navigation',
              onPressed: () => _resetNavigation(context),
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

  void _resetNavigation(BuildContext context) {
    context.resetBranches();
    context.popToRoot();
  }
}
