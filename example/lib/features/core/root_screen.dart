import 'package:example/features/catalog/catalog_page.dart';
import 'package:example/router/targets.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class RootScreenCatalog extends RootScreen {
  const RootScreenCatalog({super.key, super.tab = RootTab.catalog});
}

class RootScreen extends StatelessWidget {
  const RootScreen({
    super.key,
    this.tab = RootTab.home,
  });

  final RootTab tab;

  @override
  Widget build(BuildContext context) {
    final index = RootTab.values.indexOf(tab);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [
          Container(),
          const CatalogPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) {
          final tab = RootTab.values[value];
          Pioneer.of(context).push(switch (tab) {
            RootTab.catalog => RouterTargetCatalog(),
            _ => RouterTargetRoot(),
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'catalog'),
        ],
      ),
    );
  }
}

enum RootTab {
  home,
  catalog;
}
