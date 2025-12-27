// ignore_for_file: overridden_fields

import 'package:pioneer/pioneer.dart';

part 'paths.dart';

class RouterTargetRoot extends RouterTarget {
  RouterTargetRoot() : super(path: Paths.root, extra: null);
}

class RouterTargetCatalog extends RouterTarget {
  @override
  final Map? extra;

  RouterTargetCatalog({
    this.extra,
  }) : super(path: Paths.catalog, extra: extra);
}

class RouterTargetProduct extends RouterTarget {
  final int id;
  @override
  final Map? extra;

  RouterTargetProduct({
    required this.id,
    this.extra,
  }) : super(path: Paths.product(id), extra: extra);
}

class RouterTargetProfile extends RouterTarget {
  @override
  final Map? extra;

  RouterTargetProfile({
    this.extra,
  }) : super(path: Paths.profile, extra: extra);
}
