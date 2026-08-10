import 'package:pioneer/pioneer.dart';

final class RootRoute implements PioneerRoute {
  const RootRoute();

  @override
  Uri get uri => Uri(path: '/');
}

final class AdminRoute implements PioneerRoute {
  const AdminRoute();

  @override
  Uri get uri => Uri(path: '/admin');
}
