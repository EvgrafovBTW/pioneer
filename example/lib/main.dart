import 'package:example/router/targets.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

void main() {
  runApp(
    PioneerProvider(
      root: RouterTargetRoot(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: Pioneer.of(context),
      routeInformationParser: Pioneer.infoParserOf(context),

      ///TODO
      // routeInformationProvider: Pioneer.infoProviderOf(context),
    );
  }
}
