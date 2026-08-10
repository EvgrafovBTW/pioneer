import 'package:flutter/material.dart';

import 'configuration.dart';
import 'route.dart';
import 'stack.dart';

typedef PioneerSystemBackHandler = bool Function();
typedef PioneerSystemBackCallback = void Function();
typedef PioneerDeepLinkHandler = PioneerRoute? Function(Uri uri);

final class PioneerRoutePath {
  const PioneerRoutePath(this.match);

  final PioneerMatch match;
  Uri get uri => match.route.uri;
}

final class PioneerRouteInformationParser extends RouteInformationParser<PioneerRoutePath> {
  const PioneerRouteInformationParser(
    this.configuration, {
    this.deepLinkHandler,
  });

  final PioneerConfiguration configuration;
  final PioneerDeepLinkHandler? deepLinkHandler;

  @override
  Future<PioneerRoutePath> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final state = routeInformation.state;

    if (state is PioneerMatch) {
      return PioneerRoutePath(state);
    }

    final uri = _normalizeUri(routeInformation.uri);
    final match = configuration.maybeMatchUri(uri);

    if (match != null) {
      return PioneerRoutePath(match);
    }

    final route = deepLinkHandler?.call(uri);

    if (route == null) {
      throw PioneerRouteNotFound(uri);
    }

    return PioneerRoutePath(configuration.matchRoute(route));
  }

  Uri _normalizeUri(Uri uri) {
    if (uri.path.isEmpty) {
      return configuration.initialRoute.uri;
    }

    if (!uri.hasScheme && !uri.hasAuthority) {
      return uri;
    }

    return Uri(
      path: uri.path,
      query: uri.hasQuery ? uri.query : null,
      fragment: uri.hasFragment ? uri.fragment : null,
    );
  }

  @override
  RouteInformation restoreRouteInformation(PioneerRoutePath configuration) =>
      RouteInformation(uri: configuration.uri);
}

final class PioneerRouteInformationProvider extends RouteInformationProvider
    with WidgetsBindingObserver, ChangeNotifier {
  PioneerRouteInformationProvider(
    Uri initialUri, {
    required this.handlesPlatformRoutes,
  }) : _value = RouteInformation(uri: initialUri);

  RouteInformation _value;
  final bool handlesPlatformRoutes;
  bool _readInitialPlatformRoute = false;

  @override
  RouteInformation get value => _value;

  @override
  void addListener(VoidCallback listener) {
    if (!hasListeners && handlesPlatformRoutes) {
      if (!_readInitialPlatformRoute) {
        _readInitialPlatformRoute = true;

        final defaultRouteName = WidgetsBinding.instance.platformDispatcher.defaultRouteName;

        if (defaultRouteName != Navigator.defaultRouteName) {
          _value = RouteInformation(uri: Uri.parse(defaultRouteName));
        }
      }

      WidgetsBinding.instance.addObserver(this);
    }

    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);

    if (!hasListeners && handlesPlatformRoutes) {
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    setRouteInformation(routeInformation);

    return true;
  }

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

  /// Keeps a route selected before its Router widget is mounted.
  void setInternalMatch(PioneerMatch match) {
    _value = RouteInformation(
      uri: match.route.uri,
      state: match,
    );
  }

  @override
  void dispose() {
    if (hasListeners && handlesPlatformRoutes) {
      WidgetsBinding.instance.removeObserver(this);
    }

    super.dispose();
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
