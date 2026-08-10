import 'package:flutter/material.dart';

import 'configuration.dart';
import 'route.dart';
import 'stack.dart';

typedef PioneerSystemBackHandler = bool Function();

final class PioneerRoutePath {
  const PioneerRoutePath(this.match);

  final PioneerMatch match;
  Uri get uri => match.route.uri;
}

final class PioneerRouteInformationParser extends RouteInformationParser<PioneerRoutePath> {
  const PioneerRouteInformationParser(this.configuration);

  final PioneerConfiguration configuration;

  @override
  Future<PioneerRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri =
        routeInformation.uri.path.isEmpty ? configuration.initialRoute.uri : routeInformation.uri;

    return PioneerRoutePath(configuration.matchUri(uri));
  }

  @override
  RouteInformation restoreRouteInformation(PioneerRoutePath configuration) =>
      RouteInformation(uri: configuration.uri);
}

final class PioneerRouteInformationProvider extends RouteInformationProvider with ChangeNotifier {
  PioneerRouteInformationProvider(Uri initialUri) : _value = RouteInformation(uri: initialUri);

  RouteInformation _value;

  @override
  RouteInformation get value => _value;

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    if (_value.uri == routeInformation.uri && _value.state == routeInformation.state) {
      return;
    }

    _value = routeInformation;
  }

  /// Supplies route information received from the host (for example a local
  /// nested router integration). Router-originated reports do not use this
  /// method, preventing a navigation feedback loop.
  void setRouteInformation(RouteInformation routeInformation) {
    if (_value.uri == routeInformation.uri && _value.state == routeInformation.state) {
      return;
    }

    _value = routeInformation;
    notifyListeners();
  }
}

final class PioneerRouterDelegate extends RouterDelegate<PioneerRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PioneerRoutePath> {
  PioneerRouterDelegate(
    this.stack, {
    this.handleSystemBack,
  }) {
    stack.addListener(notifyListeners);
  }

  final PioneerStack stack;
  PioneerSystemBackHandler? handleSystemBack;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  PioneerRoutePath get currentConfiguration => PioneerRoutePath(stack.currentMatch);

  @override
  Future<void> setNewRoutePath(PioneerRoutePath configuration) async {
    stack.setPath(configuration.match);
  }

  @override
  Future<bool> popRoute() async {
    if (stack.canPop) {
      stack.pop<Object?>();

      return true;
    }

    return handleSystemBack?.call() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        for (final entry in stack.entries) _buildPage(entry),
      ],
      onDidRemovePage: (page) {
        // Pop results are handled by MaterialPage.onPopInvoked. This callback
        // covers declarative removals and custom Navigator integrations.
        stack.didPopPage(page.key!, null);
      },
    );
  }

  MaterialPage<Object?> _buildPage(PioneerStackEntry entry) {
    return MaterialPage<Object?>(
      key: entry.pageKey,
      name: entry.route.uri.toString(),
      child: Builder(builder: entry.build),
      onPopInvoked: (didPop, result) {
        if (didPop) {
          stack.didPopPage(entry.pageKey, result);
        }
      },
    );
  }

  @override
  void dispose() {
    stack.removeListener(notifyListeners);

    super.dispose();
  }
}
