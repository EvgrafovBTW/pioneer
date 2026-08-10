import 'package:flutter/foundation.dart';

export 'app_routes.dart';
export 'auth_routes.dart';
export 'catalog_routes.dart';
export 'configurations.dart';
export 'home_routes.dart';
export 'profile_routes.dart';

abstract final class AppBranchKeys {
  static const home = ValueKey<String>('homeKey');
  static const catalog = ValueKey<String>('catalogKey');
  static const profile = ValueKey<String>('profileKey');
}
