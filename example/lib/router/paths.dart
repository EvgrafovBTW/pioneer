part of 'targets.dart';

sealed class Paths {
  static final root = Uri(pathSegments: _Root.initial);

  static Uri actions([int? id]) {
    if (id == null) {
      return Uri(pathSegments: _Root.actions);
    }

    return Uri(
      pathSegments: _Root.actions,
      queryParameters: Pioneer.parseToQueryParams(key: 'id', value: id),
    );
  }
}

sealed class _Root {
  static const initial = <String>[];
  static const actions = [Segments.actions];
}

sealed class Segments {
  static const actions = 'actions';
}
