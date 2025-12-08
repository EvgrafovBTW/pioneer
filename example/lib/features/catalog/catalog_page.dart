import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                count++;
              });
            },
            child: Text(count.toString()),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Pioneer.of(context).pop(context);
          },
          child: const Text('pop'),
        ),
      ],
    );
  }
}
