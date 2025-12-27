import 'package:example/router/targets.dart';
import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (value) {
          Pioneer.of(context).push(switch (value) {
            1 => RouterTargetCatalog(),
            2 => RouterTargetProfile(),
            _ => RouterTargetRoot(),
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'catalog'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
        ],
      ),
    );
  }
}
