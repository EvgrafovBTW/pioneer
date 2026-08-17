import 'package:pioneer_router/pioneer_router.dart';

final class RootRoute implements PioneerRoute {
  const RootRoute();

  @override
  Uri get uri => Uri(path: '/');
}

final class AuthRoute implements PioneerRoute {
  const AuthRoute();

  @override
  Uri get uri => Uri(path: '/auth');
}
