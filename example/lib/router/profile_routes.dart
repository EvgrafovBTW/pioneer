import 'package:pioneer/pioneer.dart';

final class ProfileRoute implements PioneerRoute {
  const ProfileRoute();

  @override
  Uri get uri => Uri(path: '/profile');
}

final class ProfileDetailsRoute implements PioneerRoute {
  const ProfileDetailsRoute();

  @override
  Uri get uri => Uri(path: '/profile/details');
}
