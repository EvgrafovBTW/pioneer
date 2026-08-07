import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class OverlayScreen extends StatelessWidget {
  const OverlayScreen({super.key, required this.shell});

  final PioneerShellController shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Above bottom bar')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This page covers the complete shell.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => PioneerRouterScope.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton.icon(
              key: const Key('overlay-reset-all'),
              onPressed: () {
                shell.resetBranches();
                PioneerRouterScope.rootOf(context).popToRoot();
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Full navigation reset'),
            ),
          ],
        ),
      ),
    );
  }
}
