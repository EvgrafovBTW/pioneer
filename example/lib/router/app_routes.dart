import 'package:pioneer/pioneer.dart';

final class ShellRoute implements PioneerRoute {
  const ShellRoute();

  @override
  Uri get uri => Uri(path: '/');
}

final class AppOverlayRoute implements PioneerRoute {
  const AppOverlayRoute();

  @override
  Uri get uri => Uri(path: '/overlay');
}
