import 'package:example/router/targets.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PioneerProvider(
      root: RouterTarget.root(),
      child: MaterialApp.router(
        routerDelegate: Pioneer.delegateOf(context),
        routeInformationParser: Pioneer.infoParserOf(context),
        routeInformationProvider: Pioneer.infoProviderOf(context),
      ),
    );
  }
}
