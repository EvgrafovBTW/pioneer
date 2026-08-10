import 'package:example/features/catalog/catalog_page.dart';
import 'package:example/features/home/home_page.dart';
import 'package:example/features/product/product_screen.dart';
import 'package:example/features/profile/profile_page.dart';
import 'package:example/router/app_routes.dart';
import 'package:example/router/catalog_routes.dart';
import 'package:example/router/home_routes.dart';
import 'package:example/router/profile_routes.dart';
import 'package:pioneer/pioneer.dart';

PioneerConfiguration rootConfiguration({
  required PioneerRouteBuilder<RootRoute> rootBuilder,
  required PioneerRouteBuilder<AdminRoute> adminBuilder,
}) =>
    PioneerConfiguration(
      initialRoute: const RootRoute(),
      routes: [
        PioneerRouteDefinition<RootRoute>(
          parse: (uri) => uri.path == '/' ? const RootRoute() : null,
          builder: rootBuilder,
        ),
        PioneerRouteDefinition<AdminRoute>(
          parse: (uri) => uri.path == '/admin' ? const AdminRoute() : null,
          builder: adminBuilder,
        ),
      ],
    );

final homeConfiguration = PioneerConfiguration(
  initialRoute: const HomeRoute(),
  routes: [
    PioneerRouteDefinition<HomeRoute>(
      parse: (uri) => uri.path == '/home' ? const HomeRoute() : null,
      builder: (context, route) => const HomePage(),
    ),
    PioneerRouteDefinition<HomeDetailsRoute>(
      parse: (uri) => uri.path == '/home/details' ? const HomeDetailsRoute() : null,
      builder: (context, route) => const HomeDetailsPage(),
    ),
  ],
);

final catalogConfiguration = PioneerConfiguration(
  initialRoute: const CatalogRoute(),
  routes: [
    PioneerRouteDefinition<CatalogRoute>(
      parse: (uri) => uri.path == '/catalog' ? const CatalogRoute() : null,
      builder: (context, route) => const CatalogPage(),
    ),
    PioneerRouteDefinition<ProductRoute>(
      parse: (uri) {
        final segments = uri.pathSegments;

        if (segments.length != 3 || segments[0] != 'catalog' || segments[1] != 'product') {
          return null;
        }

        final id = int.tryParse(segments[2]);

        return id == null ? null : ProductRoute(id: id);
      },
      builder: (context, route) => ProductScreen(id: route.id),
    ),
  ],
);

final profileConfiguration = PioneerConfiguration(
  initialRoute: const ProfileRoute(),
  routes: [
    PioneerRouteDefinition<ProfileRoute>(
      parse: (uri) => uri.path == '/profile' ? const ProfileRoute() : null,
      builder: (context, route) => const ProfilePage(),
    ),
    PioneerRouteDefinition<ProfileDetailsRoute>(
      parse: (uri) => uri.path == '/profile/details' ? const ProfileDetailsRoute() : null,
      builder: (context, route) => const ProfileDetailsPage(),
    ),
  ],
);
