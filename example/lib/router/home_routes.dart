import 'package:pioneer_router/pioneer_router.dart';

final class HomeRoute implements PioneerRoute {
  const HomeRoute();

  @override
  Uri get uri => Uri(path: '/home');
}

final class HomeDetailsRoute implements PioneerRoute {
  const HomeDetailsRoute();

  @override
  Uri get uri => Uri(path: '/home/details');
}
