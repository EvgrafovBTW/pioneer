part of 'targets.dart';

sealed class Paths {
  static final root = Uri(pathSegments: _Root.initial);

  static Uri catalog([int? id]) {
    if (id == null) {
      return Uri(pathSegments: _Root.catalog);
    }

    return Uri(
      pathSegments: _Root.catalog,
      queryParameters: Pioneer.parseToQueryParams(key: 'id', value: id),
    );
  }
}

sealed class _Root {
  static const initial = <String>[];
  static const catalog = [Segments.catalog];
}

sealed class Segments {
  static const catalog = 'catalog';
}
