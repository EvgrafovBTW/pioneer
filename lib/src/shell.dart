import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'route.dart';
import 'router.dart';

/// Configuration and optional lookup key for one shell branch.
final class PioneerShellBranch {
  const PioneerShellBranch({
    required this.configuration,
    this.key,
  });

  final PioneerConfiguration configuration;
  final LocalKey? key;
}

/// Owns independent navigation stacks used by a stateful shell.
final class PioneerShellController extends ChangeNotifier {
  factory PioneerShellController({
    required Iterable<PioneerShellBranch> branches,
    int initialIndex = 0,
  }) {
    final branchList = List<PioneerShellBranch>.unmodifiable(branches);
    return PioneerShellController._(branchList, initialIndex);
  }

  PioneerShellController._(
    this._branchDefinitions,
    this._currentIndex,
  ) : _routers = List.unmodifiable(
          _branchDefinitions.map(
            (branch) => PioneerRouter(
              configuration: branch.configuration,
              handlesSystemBack: false,
            ),
          ),
        ) {
    if (_routers.isEmpty) {
      throw ArgumentError.value(
        _branchDefinitions,
        'branches',
        'Must not be empty.',
      );
    }
    RangeError.checkValidIndex(_currentIndex, _routers, 'initialIndex');

    final keys = <LocalKey>{};

    for (final branch in _branchDefinitions) {
      final key = branch.key;

      if (key != null && !keys.add(key)) {
        throw ArgumentError.value(
            key, 'branches', 'Branch keys must be unique.');
      }
    }
  }

  final List<PioneerShellBranch> _branchDefinitions;
  final List<PioneerRouter> _routers;
  int _currentIndex;

  List<PioneerRouter> get branches => _routers;
  int get currentIndex => _currentIndex;
  PioneerRouter get currentBranch => _routers[_currentIndex];

  PioneerRouter branch(int index) => _routers[index];

  /// Replaces a resolved branch stack with [route] and activates that branch.
  ///
  /// Without [branchKey], the active keyed branch wins when it supports the
  /// route. Otherwise exactly one keyed branch must support it. With an
  /// explicit key, only that branch is inspected.
  void goTo(PioneerRoute route, {LocalKey? branchKey}) {
    final index = branchKey == null
        ? _resolveBranch(route)
        : _resolveExplicitBranch(route, branchKey);

    _routers[index].reset(route);
    goBranch(index);
  }

  void goBranch(int index) {
    RangeError.checkValidIndex(index, _routers, 'index');

    if (_currentIndex == index) {
      return;
    }

    _currentIndex = index;
    notifyListeners();
  }

  void resetBranch(int index) {
    RangeError.checkValidIndex(index, _routers, 'index');

    _routers[index].reset();
  }

  void resetBranches({int activeIndex = 0}) {
    RangeError.checkValidIndex(activeIndex, _routers, 'activeIndex');

    for (final router in _routers) {
      router.reset();
    }

    final changed = _currentIndex != activeIndex;

    _currentIndex = activeIndex;

    if (changed) {
      notifyListeners();
    }
  }

  int _resolveBranch(PioneerRoute route) {
    final active = _branchDefinitions[_currentIndex];
    if (active.key != null &&
        active.configuration.maybeMatchRoute(route) != null) {
      return _currentIndex;
    }

    final candidates = <int>[];

    for (var index = 0; index < _branchDefinitions.length; index++) {
      if (index == _currentIndex) {
        continue;
      }

      final branch = _branchDefinitions[index];

      if (branch.key != null &&
          branch.configuration.maybeMatchRoute(route) != null) {
        candidates.add(index);
      }
    }

    if (candidates.isEmpty) {
      throw PioneerShellRouteNotFound(route);
    }

    if (candidates.length > 1) {
      throw PioneerAmbiguousShellRoute(
        route,
        candidates.map((index) => _branchDefinitions[index].key!).toList(),
      );
    }

    return candidates.single;
  }

  int _resolveExplicitBranch(PioneerRoute route, LocalKey branchKey) {
    final index = _branchDefinitions.indexWhere(
      (branch) => branch.key == branchKey,
    );

    if (index < 0) {
      throw PioneerShellBranchNotFound(branchKey);
    }

    if (_branchDefinitions[index].configuration.maybeMatchRoute(route) ==
        null) {
      throw PioneerShellRouteNotFound(route, branchKey: branchKey);
    }

    return index;
  }

  @override
  void dispose() {
    for (final router in _routers) {
      router.dispose();
    }

    super.dispose();
  }
}

final class PioneerShellBranchNotFound implements Exception {
  const PioneerShellBranchNotFound(this.branchKey);

  final LocalKey branchKey;

  @override
  String toString() => 'No Pioneer shell branch has key $branchKey.';
}

final class PioneerShellRouteNotFound implements Exception {
  const PioneerShellRouteNotFound(this.route, {this.branchKey});

  final PioneerRoute route;
  final LocalKey? branchKey;

  @override
  String toString() => branchKey == null
      ? 'No keyed Pioneer shell branch supports ${route.runtimeType}.'
      : 'Pioneer shell branch $branchKey does not support ${route.runtimeType}.';
}

final class PioneerAmbiguousShellRoute implements Exception {
  const PioneerAmbiguousShellRoute(this.route, this.branchKeys);

  final PioneerRoute route;
  final List<LocalKey> branchKeys;

  @override
  String toString() => '${route.runtimeType} matches multiple Pioneer shell '
      'branches: ${branchKeys.join(', ')}. Pass branchKey explicitly.';
}

/// Keeps every branch mounted while displaying only the active branch.
final class PioneerStatefulShell extends StatefulWidget {
  const PioneerStatefulShell({
    super.key,
    required this.controller,
  });

  final PioneerShellController controller;

  @override
  State<PioneerStatefulShell> createState() => _PioneerStatefulShellState();
}

final class _PioneerStatefulShellState extends State<PioneerStatefulShell> {
  late List<Widget> _branches;

  @override
  void initState() {
    super.initState();
    _branches = _buildBranches();
    widget.controller.addListener(_handleShellChanged);
  }

  @override
  void didUpdateWidget(PioneerStatefulShell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == widget.controller) {
      return;
    }

    oldWidget.controller.removeListener(_handleShellChanged);
    widget.controller.addListener(_handleShellChanged);
    _branches = _buildBranches();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleShellChanged);
    super.dispose();
  }

  void _handleShellChanged() => setState(() {});

  List<Widget> _buildBranches() => [
        for (var index = 0; index < widget.controller.branches.length; index++)
          PioneerRouterScope(
            key: ValueKey<int>(index),
            router: widget.controller.branch(index),
            child: Router.withConfig(
              config: widget.controller.branch(index).routerConfig,
            ),
          ),
      ];

  @override
  Widget build(BuildContext context) {
    return PioneerShellScope(
      controller: widget.controller,
      child: IndexedStack(
        index: widget.controller.currentIndex,
        children: _branches,
      ),
    );
  }
}

/// Provides the surrounding stateful shell controller to branch pages.
final class PioneerShellScope
    extends InheritedNotifier<PioneerShellController> {
  const PioneerShellScope({
    super.key,
    required PioneerShellController controller,
    required super.child,
  }) : super(notifier: controller);

  static PioneerShellController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<PioneerShellScope>();
    if (scope == null) {
      throw FlutterError('No PioneerShellScope found in this context.');
    }

    return scope.notifier!;
  }
}
