import 'package:flutter/widgets.dart';

import 'route.dart';
import 'router.dart';
import 'shell.dart';

/// Navigation shortcuts for Pioneer controllers available in the widget tree.
extension PioneerBuildContextExtension on BuildContext {
  /// The nearest Pioneer router.
  PioneerRouter get pioneerRouter => PioneerRouterScope.of(this);

  /// The outermost Pioneer router.
  PioneerRouter get pioneerRootRouter => PioneerRouterScope.rootOf(this);

  /// The nearest stateful shell controller.
  PioneerShellController get pioneerShell => PioneerShellScope.of(this);

  bool canPop() => pioneerRouter.canPop;

  Future<T?> push<T>(PioneerRoute route) => pioneerRouter.push<T>(route);

  void pop<T>([T? result]) => pioneerRouter.pop<T>(result);

  void replace(PioneerRoute route) => pioneerRouter.replace(route);

  Future<T?> pushReplacement<T, TO>(
    PioneerRoute route, {
    TO? result,
  }) =>
      pioneerRouter.pushReplacement<T, TO>(route, result: result);

  Future<T?> pushAndRemoveUntil<T>(
    PioneerRoute route,
    bool Function(PioneerRoute route) predicate,
  ) =>
      pioneerRouter.pushAndRemoveUntil<T>(route, predicate);

  void reset([PioneerRoute? route]) => pioneerRouter.reset(route);

  void popToRoot() => pioneerRouter.popToRoot();

  Future<T?> pushRoot<T>(PioneerRoute route) => pioneerRootRouter.push<T>(route);

  void resetRoot([PioneerRoute? route]) => pioneerRootRouter.reset(route);

  void goTo(PioneerRoute route, {LocalKey? branchKey}) {
    pioneerShell.goTo(route, branchKey: branchKey);
  }

  void goToUri(Uri uri, {LocalKey? branchKey}) {
    pioneerShell.goToUri(uri, branchKey: branchKey);
  }

  void goBranch(int index) => pioneerShell.goBranch(index);

  void resetBranch(int index) => pioneerShell.resetBranch(index);

  void resetBranches({int? activeIndex}) {
    pioneerShell.resetBranches(activeIndex: activeIndex);
  }
}
