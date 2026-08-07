import 'dart:async';

import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'route.dart';

/// Read-only description of one stack item.
final class PioneerStackEntry {
  const PioneerStackEntry._(this.route, this.pageKey, this.build);

  final PioneerRoute route;
  final LocalKey pageKey;
  final WidgetBuilder build;
}

final class PioneerStack extends ChangeNotifier {
  PioneerStack(this.configuration) {
    _entries.add(_Entry<void>(
      configuration.matchRoute(configuration.initialRoute),
      _nextKey(),
    ));
  }

  final PioneerConfiguration configuration;
  final List<_Entry<Object?>> _entries = [];
  int _keySeed = 0;

  List<PioneerStackEntry> get entries => List.unmodifiable(
        _entries.map(
          (entry) => PioneerStackEntry._(
            entry.route,
            entry.key,
            entry.match.build,
          ),
        ),
      );

  PioneerRoute get currentRoute => _entries.last.route;
  PioneerMatch get currentMatch => _entries.last.match;
  bool get canPop => _entries.length > 1;

  Future<T?> push<T>(PioneerRoute route) {
    final entry = _Entry<T>(configuration.matchRoute(route), _nextKey());

    _entries.add(entry);
    notifyListeners();

    return entry.result;
  }

  void replace(PioneerRoute route) {
    final removed = _entries.removeLast();

    removed.complete(null);
    _entries.add(_Entry<void>(configuration.matchRoute(route), _nextKey()));
    notifyListeners();
  }

  Future<T?> pushReplacement<T, TO>(
    PioneerRoute route, {
    TO? result,
  }) {
    final removed = _entries.removeLast();

    removed.complete(result);

    final entry = _Entry<T>(configuration.matchRoute(route), _nextKey());

    _entries.add(entry);
    notifyListeners();

    return entry.result;
  }

  Future<T?> pushAndRemoveUntil<T>(
    PioneerRoute route,
    bool Function(PioneerRoute route) predicate,
  ) {
    while (_entries.isNotEmpty && !predicate(_entries.last.route)) {
      _entries.removeLast().complete(null);
    }

    final entry = _Entry<T>(configuration.matchRoute(route), _nextKey());

    _entries.add(entry);
    notifyListeners();

    return entry.result;
  }

  void pop<T>([T? result]) {
    if (!canPop) {
      throw const PioneerCannotPop();
    }

    _entries.removeLast().complete(result);
    notifyListeners();
  }

  void setPath(PioneerMatch match, {bool force = false}) {
    if (!force &&
        _entries.length == 1 &&
        _entries.single.route.runtimeType == match.route.runtimeType &&
        _entries.single.route.uri == match.route.uri) {
      return;
    }

    for (final entry in _entries) {
      entry.complete(null);
    }

    _entries
      ..clear()
      ..add(_Entry<void>(match, _nextKey()));

    notifyListeners();
  }

  void reset([PioneerRoute? route]) {
    setPath(
      configuration.matchRoute(route ?? configuration.initialRoute),
      force: true,
    );
  }

  void popToRoot() {
    if (_entries.length == 1) {
      return;
    }

    while (_entries.length > 1) {
      _entries.removeLast().complete(null);
    }

    notifyListeners();
  }

  void didPopPage(LocalKey key, Object? result) {
    final index = _entries.indexWhere((entry) => entry.key == key);

    if (index < 0) {
      return;
    }

    final entry = _entries.removeAt(index)..complete(result);

    assert(entry.key == key);
    notifyListeners();
  }

  LocalKey _nextKey() => ValueKey<int>(_keySeed++);
}

/// Thrown when a pop is requested for a stack containing only its root page.
final class PioneerCannotPop implements Exception {
  const PioneerCannotPop();

  @override
  String toString() =>
      'Cannot pop the last page from a Pioneer navigation stack.';
}

final class _Entry<T> {
  _Entry(this.match, this.key);

  final PioneerMatch match;
  final LocalKey key;
  final Completer<T?> _completer = Completer<T?>();

  PioneerRoute get route => match.route;
  Future<T?> get result => _completer.future;

  void complete(Object? value) {
    if (_completer.isCompleted) {
      return;
    }

    if (value is T || value == null) {
      _completer.complete(value as T?);

      return;
    }

    _completer.completeError(
      StateError('Expected a $T navigation result, got ${value.runtimeType}.'),
    );
  }
}
