part of 'targets.dart';

sealed class Paths {
  static final root = Uri(pathSegments: _Root.initial);

  static Uri product(int id) {
    return Uri(
      pathSegments: _Root.catalog,
      queryParameters: Pioneer.parseToQueryParams(key: 'id', value: id),
    );
  }

  static final catalog = Uri(pathSegments: _Root.catalog);
  static final profile = Uri(pathSegments: _Root.profile);
}

sealed class _Root {
  static const initial = <String>[];
  static const catalog = [Segments.catalog];
  static const profile = [Segments.profile];
}

sealed class Segments {
  static const catalog = 'catalog';
  static const profile = 'profile';
}
