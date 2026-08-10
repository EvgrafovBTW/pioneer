import 'route.dart';

/// Immutable route tree configuration.
final class PioneerConfiguration {
  PioneerConfiguration({
    required this.initialRoute,
    required Iterable<PioneerRouteDefinitionBase> routes,
  }) : routes = List.unmodifiable(routes) {
    if (this.routes.isEmpty) {
      throw ArgumentError.value(routes, 'routes', 'Must not be empty.');
    }
    matchRoute(initialRoute);
  }

  final PioneerRoute initialRoute;
  final List<PioneerRouteDefinitionBase> routes;

  PioneerMatch matchUri(Uri uri) {
    for (final definition in routes) {
      final match = definition.match(uri);

      if (match != null) {
        return match;
      }
    }

    if (initialRoute.uri == uri) {
      return matchRoute(initialRoute);
    }

    throw PioneerRouteNotFound(uri);
  }

  PioneerMatch matchRoute(PioneerRoute route) {
    final match = maybeMatchRoute(route);

    if (match != null) {
      return match;
    }

    throw ArgumentError.value(
      route,
      'route',
      'No definition is registered for ${route.runtimeType}.',
    );
  }

  /// Returns a type-compatible match without interpreting the route URI.
  PioneerMatch? maybeMatchRoute(PioneerRoute route) {
    PioneerMatch? result;

    for (final definition in routes) {
      final match = definition.matchRoute(route);

      if (match == null) {
        continue;
      }

      if (result != null) {
        throw StateError(
          'More than one definition matches ${route.runtimeType} in the same '
          'PioneerConfiguration.',
        );
      }

      result = match;
    }

    return result;
  }
}
