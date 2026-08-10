import 'package:pioneer/pioneer.dart';

final class SignInRoute implements PioneerRoute {
  const SignInRoute();

  @override
  Uri get uri => Uri(path: '/auth/sign-in');
}

final class RegistrationRoute implements PioneerRoute {
  const RegistrationRoute();

  @override
  Uri get uri => Uri(path: '/auth/registration');
}
