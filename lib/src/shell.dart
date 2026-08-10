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

/// Owns either one navigation stack or independent stacks for shell branches.
final class PioneerShellController extends ChangeNotifier implements PioneerShellNavigation {
  factory PioneerShellController.branches({
    required Iterable<PioneerShellBranch> branches,
    int initialIndex = 0,
  }) {
    final branchList = List<PioneerShellBranch>.unmodifiable(branches);

    return PioneerShellController._(
      branchList,
      initialIndex,
      isSingle: false,
    );
  }

  factory PioneerShellController.single({
    required PioneerConfiguration configuration,
  }) {
    return PioneerShellController._(
      [PioneerShellBranch(configuration: configuration)],
      0,
      isSingle: true,
    );
  }

  PioneerShellController._(
    this._branchDefinitions,
    int initialIndex, {
    required this.isSingle,
  })  : _initialIndex = initialIndex,
        _currentIndex = initialIndex,
        _routers = List.unmodifiable(
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
        throw ArgumentError.value(key, 'branches', 'Branch keys must be unique.');
      }
    }
  }

  final List<PioneerShellBranch> _branchDefinitions;
  final List<PioneerRouter> _routers;
  final int _initialIndex;
  final bool isSingle;
  int _currentIndex;

  bool get hasBranches => !isSingle;
  List<PioneerRouter> get branches {
    _requireBranches('branches');

    return _routers;
  }

  int get initialIndex {
    _requireBranches('initialIndex');

    return _initialIndex;
  }

  int get currentIndex {
    _requireBranches('currentIndex');

    return _currentIndex;
  }

  PioneerRouter get currentBranch {
    _requireBranches('currentBranch');

    return _routers[_currentIndex];
  }

  /// The only router owned by a single shell.
  ///
  /// Throws when this controller was created with [PioneerShellController.branches].
  PioneerRouter get router {
    if (!isSingle) {
      throw StateError('router is only available on a single Pioneer shell.');
    }

    return _routers.single;
  }

  PioneerRouter branch(int index) {
    _requireBranches('branch');

    return _routers[index];
  }

  /// Replaces a resolved branch stack with [route] and activates that branch.
  ///
  /// Without [branchKey], the active keyed branch wins when it supports the
  /// route. Otherwise exactly one keyed branch must support it. With an
  /// explicit key, only that branch is inspected.
  void goTo(PioneerRoute route, {LocalKey? branchKey}) {
    _requireBranches('goTo');

    final index =
        branchKey == null ? _resolveBranch(route) : _resolveExplicitBranch(route, branchKey);

    _routers[index].reset(route);
    goBranch(index);
  }

  /// Resolves an external URI in shell branches and activates its route.
  void goToUri(Uri uri, {LocalKey? branchKey}) {
    _requireBranches('goToUri');

    final resolved = branchKey == null ? _resolveUri(uri) : _resolveExplicitUri(uri, branchKey);

    _routers[resolved.index].reset(resolved.match.route);
    goBranch(resolved.index);
  }

  void goBranch(int index) {
    _requireBranches('goBranch');

    RangeError.checkValidIndex(index, _routers, 'index');

    if (_currentIndex == index) {
      return;
    }

    _currentIndex = index;
    notifyListeners();
  }

  void resetBranch(int index) {
    _requireBranches('resetBranch');

    RangeError.checkValidIndex(index, _routers, 'index');

    _routers[index].reset();
  }

  void resetBranches({int? activeIndex}) {
    _requireBranches('resetBranches');

    final targetIndex = activeIndex ?? _initialIndex;

    RangeError.checkValidIndex(targetIndex, _routers, 'activeIndex');

    for (final router in _routers) {
      router.reset();
    }

    final changed = _currentIndex != targetIndex;

    _currentIndex = targetIndex;

    if (changed) {
      notifyListeners();
    }
  }

  @override
  void reset() {
    if (isSingle) {
      router.reset();

      return;
    }

    resetBranches();
  }

  /// Handles system Back after the root router has exhausted its own stack.
  ///
  /// Pops the active branch first. At a non-initial branch root, switches to
  /// the initial branch. Returns false only at the initial branch root so the
  /// platform can close the application.
  @override
  bool handleSystemBack() {
    final currentRouter = _routers[_currentIndex];

    if (currentRouter.canPop) {
      currentRouter.pop();

      return true;
    }

    if (_currentIndex != _initialIndex) {
      goBranch(_initialIndex);

      return true;
    }

    return false;
  }

  void _requireBranches(String operation) {
    if (isSingle) {
      throw StateError('$operation is only available on a branched Pioneer shell.');
    }
  }

  int _resolveBranch(PioneerRoute route) {
    final active = _branchDefinitions[_currentIndex];
    if (active.key != null && active.configuration.maybeMatchRoute(route) != null) {
      return _currentIndex;
    }

    final candidates = <int>[];

    for (var index = 0; index < _branchDefinitions.length; index++) {
      if (index == _currentIndex) {
        continue;
      }

      final branch = _branchDefinitions[index];

      if (branch.key != null && branch.configuration.maybeMatchRoute(route) != null) {
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

    if (_branchDefinitions[index].configuration.maybeMatchRoute(route) == null) {
      throw PioneerShellRouteNotFound(route, branchKey: branchKey);
    }

    return index;
  }

  ({int index, PioneerMatch match}) _resolveUri(Uri uri) {
    final active = _branchDefinitions[_currentIndex];
    final activeMatch = active.key == null ? null : active.configuration.maybeMatchUri(uri);

    if (activeMatch != null) {
      return (index: _currentIndex, match: activeMatch);
    }

    final candidates = <({int index, PioneerMatch match})>[];

    for (var index = 0; index < _branchDefinitions.length; index++) {
      if (index == _currentIndex) {
        continue;
      }

      final branch = _branchDefinitions[index];
      final match = branch.key == null ? null : branch.configuration.maybeMatchUri(uri);

      if (match != null) {
        candidates.add((index: index, match: match));
      }
    }

    if (candidates.isEmpty) {
      throw PioneerShellDeepLinkNotFound(uri);
    }

    if (candidates.length > 1) {
      throw PioneerAmbiguousShellDeepLink(
        uri,
        candidates.map((candidate) => _branchDefinitions[candidate.index].key!).toList(),
      );
    }

    return candidates.single;
  }

  ({int index, PioneerMatch match}) _resolveExplicitUri(Uri uri, LocalKey branchKey) {
    final index = _branchDefinitions.indexWhere(
      (branch) => branch.key == branchKey,
    );

    if (index < 0) {
      throw PioneerShellBranchNotFound(branchKey);
    }

    final match = _branchDefinitions[index].configuration.maybeMatchUri(uri);

    if (match == null) {
      throw PioneerShellDeepLinkNotFound(uri, branchKey: branchKey);
    }

    return (index: index, match: match);
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

final class PioneerShellDeepLinkNotFound implements Exception {
  const PioneerShellDeepLinkNotFound(this.uri, {this.branchKey});

  final Uri uri;
  final LocalKey? branchKey;

  @override
  String toString() => branchKey == null
      ? 'No keyed Pioneer shell branch supports $uri.'
      : 'Pioneer shell branch $branchKey does not support $uri.';
}

final class PioneerAmbiguousShellDeepLink implements Exception {
  const PioneerAmbiguousShellDeepLink(this.uri, this.branchKeys);

  final Uri uri;
  final List<LocalKey> branchKeys;

  @override
  String toString() => '$uri matches multiple Pioneer shell branches: '
      '${branchKeys.join(', ')}. Pass branchKey explicitly.';
}

/// Displays a single shell router or keeps every branch mounted.
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
        if (widget.controller.isSingle)
          PioneerRouterScope(
            router: widget.controller.router,
            child: Router.withConfig(
              config: widget.controller.router.routerConfig,
            ),
          ),
        if (widget.controller.hasBranches)
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
    if (widget.controller.isSingle) {
      return _branches.single;
    }

    return IndexedStack(
      index: widget.controller.currentIndex,
      children: _branches,
    );
  }
}

/// Configures and provides a shell controller to its pages.
///
/// A branched controller requires [child], which normally contains a
/// [PioneerStatefulShell] and branch switcher. A single controller builds its
/// only router automatically and therefore does not accept [child].
final class PioneerShellScope extends InheritedNotifier<PioneerShellController> {
  factory PioneerShellScope({
    Key? key,
    required PioneerShellController controller,
    Widget? child,
  }) {
    if (controller.isSingle && child != null) {
      throw ArgumentError.value(
        child,
        'child',
        'A single Pioneer shell builds its router automatically.',
      );
    }

    if (controller.hasBranches && child == null) {
      throw ArgumentError.notNull('child');
    }

    return PioneerShellScope._(
      key: key,
      controller: controller,
      child: child ?? PioneerStatefulShell(controller: controller),
    );
  }

  const PioneerShellScope._({
    super.key,
    required PioneerShellController controller,
    required super.child,
  }) : super(notifier: controller);

  static PioneerShellController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PioneerShellScope>();
    if (scope == null) {
      throw FlutterError('No PioneerShellScope found in this context.');
    }

    return scope.notifier!;
  }
}
