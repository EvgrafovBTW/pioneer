import 'package:example/features/core/auth_screen.dart';
import 'package:example/features/catalog/catalog_page.dart';
import 'package:example/features/home/home_page.dart';
import 'package:example/features/product/product_screen.dart';
import 'package:example/features/profile/profile_page.dart';
import 'package:example/router/app_routes.dart';
import 'package:example/router/auth_routes.dart';
import 'package:example/router/catalog_routes.dart';
import 'package:example/router/home_routes.dart';
import 'package:example/router/profile_routes.dart';
import 'package:pioneer/pioneer.dart';

PioneerConfiguration rootConfiguration({
  required PioneerRoute initialRoute,
  required PioneerShellNavigation rootShell,
  required PioneerShellNavigation authShell,
  required PioneerRouteBuilder<RootRoute> rootBuilder,
  required PioneerRouteBuilder<AuthRoute> authBuilder,
  required PioneerRouteBuilder<ProductRoute> productBuilder,
}) =>
    PioneerConfiguration(
      initialRoute: initialRoute,
      routes: [
        PioneerRouteDefinition<RootRoute>(
          builder: rootBuilder,
          shell: rootShell,
        ),
        PioneerRouteDefinition<AuthRoute>(
          builder: authBuilder,
          shell: authShell,
        ),
        PioneerRouteDefinition<ProductRoute>.deepLink(
          parse: parseProductRoute,
          builder: productBuilder,
          shell: rootShell,
        ),
      ],
    );

final authConfiguration = PioneerConfiguration(
  initialRoute: const SignInRoute(),
  routes: [
    PioneerRouteDefinition<SignInRoute>(
      builder: (context, route) => const AuthScreen(),
    ),
    PioneerRouteDefinition<RegistrationRoute>(
      builder: (context, route) => const RegistrationScreen(),
    ),
  ],
);

final homeConfiguration = PioneerConfiguration(
  initialRoute: const HomeRoute(),
  routes: [
    PioneerRouteDefinition<HomeRoute>(
      builder: (context, route) => const HomePage(),
    ),
    PioneerRouteDefinition<HomeDetailsRoute>(
      builder: (context, route) => const HomeDetailsPage(),
    ),
  ],
);

final catalogConfiguration = PioneerConfiguration(
  initialRoute: const CatalogRoute(),
  routes: [
    PioneerRouteDefinition<CatalogRoute>(
      builder: (context, route) => const CatalogPage(),
    ),
    PioneerRouteDefinition<ProductRoute>.deepLink(
      parse: parseProductRoute,
      builder: (context, route) {
        return ProductScreen(id: route.id);
      },
    ),
  ],
);

ProductRoute? parseProductRoute(Uri uri) {
  final segments = uri.pathSegments;

  if (segments.length != 3 || segments[0] != 'catalog' || segments[1] != 'product') {
    return null;
  }

  final id = int.tryParse(segments[2]);

  return id == null ? null : ProductRoute(id: id);
}

final profileConfiguration = PioneerConfiguration(
  initialRoute: const ProfileRoute(),
  routes: [
    PioneerRouteDefinition<ProfileRoute>(
      builder: (context, route) => const ProfilePage(),
    ),
    PioneerRouteDefinition<ProfileDetailsRoute>(
      builder: (context, route) => const ProfileDetailsPage(),
    ),
  ],
);
