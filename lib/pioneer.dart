library pioneer;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

part 'utils.dart';
part 'delegate.dart';

class PioneerProvider extends StatefulWidget {
  const PioneerProvider({super.key, required this.child, required this.root});

  final Widget child;
  final PioneerRouterTarget root;

  @override
  State<PioneerProvider> createState() => _PioneerProviderState();
}

class _PioneerProviderState extends State<PioneerProvider> {
  late PioneerRouterDelegate delegate;
  late PioneerRouterInformationParser informationParser;
  late PioneerRouteInformationProvider informationProvider;

  @override
  void initState() {
    super.initState();

    delegate = PioneerRouterDelegate(root: widget.root);
    informationParser = PioneerRouterInformationParser();
    informationProvider = PioneerRouteInformationProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Pioneer(
      key: widget.key,
      delegate: delegate,
      informationParser: informationParser,
      informatioProvider: informationProvider,
      child: widget.child,
    );
  }
}

class Pioneer extends InheritedWidget {
  final PioneerRouterDelegate delegate;
  final PioneerRouterInformationParser informationParser;
  final PioneerRouteInformationProvider informatioProvider;

  const Pioneer({
    super.key,
    required this.delegate,
    required this.informationParser,
    required this.informatioProvider,
    required super.child,
  });

  static Pioneer? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Pioneer>();

  static PioneerRouterDelegate delegateOf(BuildContext context) => maybeOf(context)!.delegate;

  static PioneerRouterInformationParser infoParserOf(BuildContext context) =>
      maybeOf(context)!.informationParser;

  static PioneerRouteInformationProvider infoProviderOf(BuildContext context) =>
      maybeOf(context)!.informatioProvider;

  @override
  bool updateShouldNotify(Pioneer oldWidget) => delegate != oldWidget.delegate;

  static Map<String, List<String>> parseToQueryParams({
    required String key,
    required dynamic value,
  }) {
    if (value is List<String>) {
      return {key: value};
    }

    if (value is List) {
      return {key: value.map((e) => e.toString()).toList()};
    }

    return {
      key: [value.toString()]
    };
  }
}
