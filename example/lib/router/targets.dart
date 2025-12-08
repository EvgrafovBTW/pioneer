// ignore_for_file: overridden_fields

import 'package:pioneer/pioneer.dart';

part 'paths.dart';

class RouterTargetRoot extends RouterTarget {
  RouterTargetRoot() : super(path: Paths.root, extra: null);
}

class RouterTargetCatalog extends RouterTarget {
  final int? id;
  @override
  final Map? extra;

  RouterTargetCatalog({
    this.id,
    this.extra,
  }) : super(path: Paths.catalog(id), extra: extra);
}
