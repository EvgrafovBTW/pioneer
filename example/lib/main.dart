import 'package:example/features/catalog/catalog_screen.dart';
import 'package:example/features/product/product_screen.dart';
import 'package:example/router/targets.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

void main() {
  runApp(
    PioneerProvider(
      root: RouterTargetRoot(),
      targetToWidgetTranslator: _translator,
      child: const MainApp(),
    ),
  );
}

Widget _translator(target) {
  return switch (target) {
    RouterTargetRoot() => Scaffold(),
    RouterTargetCatalog() =>
      target.hasQuery ? ProductScreen(id: target.id!) : const CatalogScreen(),
    _ => Container(),
  };
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: Pioneer.delegateOf(context),
      routeInformationParser: Pioneer.infoParserOf(context),

      ///TODO
      // routeInformationProvider: Pioneer.infoProviderOf(context),
    );
  }
}
