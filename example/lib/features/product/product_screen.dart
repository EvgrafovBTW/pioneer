import 'package:flutter/material.dart';
import 'package:pioneer/pioneer.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('product $id'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Pioneer.of(context).pop(context);
          },
          child: const Text('pop'),
        ),
      ),
    );
  }
}
