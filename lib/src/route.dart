import 'package:flutter/widgets.dart';

/// A typed destination in a Pioneer application.
abstract interface class PioneerRoute {
  const PioneerRoute();

  Uri get uri;
}

typedef PioneerRouteParser<R extends PioneerRoute> = R? Function(Uri uri);
typedef PioneerRouteBuilder<R extends PioneerRoute> = Widget Function(
  BuildContext context,
  R route,
);

/// Describes how one concrete route type is parsed and rendered.
final class PioneerRouteDefinition<R extends PioneerRoute> implements PioneerRouteDefinitionBase {
  const PioneerRouteDefinition({
    required this.builder,
  }) : _parse = null;

  const PioneerRouteDefinition.deepLink({
    required PioneerRouteParser<R> parse,
    required this.builder,
  }) : _parse = parse;

  final PioneerRouteParser<R>? _parse;
  final PioneerRouteBuilder<R> builder;

  @override
  PioneerMatch? match(Uri uri) {
    final parse = _parse;

    if (parse == null) {
      return null;
    }

    final route = parse(uri);

    if (route == null) {
      return null;
    }

    if (route.uri != uri) {
      return null;
    }

    return PioneerMatch(
      route: route,
      build: (context) => builder(context, route),
    );
  }

  @override
  PioneerMatch? matchRoute(PioneerRoute route) {
    if (route is! R) {
      return null;
    }

    return PioneerMatch(
      route: route,
      build: (context) => builder(context, route),
    );
  }
}

abstract interface class PioneerRouteDefinitionBase {
  const PioneerRouteDefinitionBase();

  PioneerMatch? match(Uri uri);
  PioneerMatch? matchRoute(PioneerRoute route);
}

/// A successfully parsed URI and its already type-bound screen builder.
final class PioneerMatch {
  const PioneerMatch({required this.route, required this.build});

  final PioneerRoute route;
  final WidgetBuilder build;
}

final class PioneerRouteNotFound implements Exception {
  const PioneerRouteNotFound(this.uri);

  final Uri uri;

  @override
  String toString() => 'No Pioneer route matches $uri';
}
