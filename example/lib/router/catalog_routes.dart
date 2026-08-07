import 'package:pioneer/pioneer.dart';

final class CatalogRoute implements PioneerRoute {
  const CatalogRoute();

  @override
  Uri get uri => Uri(path: '/catalog');
}

final class ProductRoute implements PioneerRoute {
  const ProductRoute({required this.id});

  final int id;

  @override
  Uri get uri => Uri(path: '/catalog/product/$id');
}
