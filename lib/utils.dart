part of 'pioneer.dart';

class PioneerRouterTarget {
  final Uri path;
  final Object? extra;

  final bool maintainState;
  final bool fullscreenDialog;
  final bool allowSnapshotting;
  final bool canPop;
  final LocalKey? key;
  final String? name;
  final Object? arguments;
  final String? restorationId;
  void Function(bool, dynamic)? onPopInvoked;

  final String? title;

  PioneerRouterTarget({
    required this.path,
    this.extra,
    this.key,
    this.name,
    this.arguments,
    this.restorationId,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    this.canPop = true,
    this.title,
  });

  @override
  bool operator ==(covariant PioneerRouterTarget other) {
    if (identical(this, other)) return true;

    return other.path == path;
  }

  @override
  int get hashCode => path.hashCode ^ extra.hashCode;
}

class PioneerPageWrapper {
  static MaterialPage material(
    Widget child, {
    required PioneerRouterTarget target,
  }) {
    if (target.onPopInvoked == null) {
      return MaterialPage(
        child: child,
        maintainState: target.maintainState,
        fullscreenDialog: target.fullscreenDialog,
        allowSnapshotting: target.allowSnapshotting,
        key: target.key,
        canPop: target.canPop,
        name: target.name,
        arguments: target.arguments,
        restorationId: target.restorationId,
      );
    }

    return MaterialPage(
      child: child,
      maintainState: target.maintainState,
      fullscreenDialog: target.fullscreenDialog,
      allowSnapshotting: target.allowSnapshotting,
      key: target.key,
      canPop: target.canPop,
      onPopInvoked: target.onPopInvoked!,
      name: target.name,
      arguments: target.arguments,
      restorationId: target.restorationId,
    );
  }

  static CupertinoPage cupertino(
    Widget child, {
    required PioneerRouterTarget target,
  }) {
    if (target.onPopInvoked == null) {
      return CupertinoPage(
        child: child,
        maintainState: target.maintainState,
        fullscreenDialog: target.fullscreenDialog,
        allowSnapshotting: target.allowSnapshotting,
        key: target.key,
        canPop: target.canPop,
        name: target.name,
        arguments: target.arguments,
        restorationId: target.restorationId,
        title: target.title,
      );
    }

    return CupertinoPage(
      child: child,
      maintainState: target.maintainState,
      fullscreenDialog: target.fullscreenDialog,
      allowSnapshotting: target.allowSnapshotting,
      key: target.key,
      canPop: target.canPop,
      onPopInvoked: target.onPopInvoked!,
      name: target.name,
      arguments: target.arguments,
      restorationId: target.restorationId,
      title: target.title,
    );
  }
}
