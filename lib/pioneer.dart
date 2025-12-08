library pioneer;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

part 'utils.dart';
part 'delegate.dart';

class PioneerProvider extends StatefulWidget {
  const PioneerProvider({super.key, required this.child});

  final Widget child;

  @override
  State<PioneerProvider> createState() => _PioneerProviderState();
}

class _PioneerProviderState extends State<PioneerProvider> {
  PioneerRouterDelegate delegate = PioneerRouterDelegate();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Pioneer(
      key: widget.key,
      delegate: delegate,
      child: widget.child,
    );
  }
}

class Pioneer extends InheritedWidget {
  final RouterDelegate delegate;

  const Pioneer({
    super.key,
    required this.delegate,
    required super.child,
  });

  static Pioneer? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Pioneer>();

  static RouterDelegate delegateOf(BuildContext context) => maybeOf(context)!.delegate;

  @override
  bool updateShouldNotify(Pioneer oldWidget) => delegate != oldWidget.delegate;
}
