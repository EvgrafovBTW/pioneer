// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'pioneer.dart';

class RouterTarget {
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
  final void Function(bool, dynamic)? onPopInvoked;

  final String? title;

  const RouterTarget({
    required this.path,
    this.extra,
    this.key,
    this.name,
    this.arguments,
    this.restorationId,
    this.onPopInvoked,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    this.canPop = true,
    this.title,
  });

  @override
  bool operator ==(covariant RouterTarget other) {
    if (identical(this, other)) return true;

    return other.path == path;
  }

  @override
  int get hashCode => path.hashCode ^ extra.hashCode;

  RouterTarget copyWith({
    Uri? path,
    Object? extra,
    bool? maintainState,
    bool? fullscreenDialog,
    bool? allowSnapshotting,
    bool? canPop,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
    void Function(bool, dynamic)? onPopInvoked,
    String? title,
  }) {
    return RouterTarget(
      path: path ?? this.path,
      extra: extra ?? this.extra,
      maintainState: maintainState ?? this.maintainState,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
      allowSnapshotting: allowSnapshotting ?? this.allowSnapshotting,
      canPop: canPop ?? this.canPop,
      key: key ?? this.key,
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      restorationId: restorationId ?? this.restorationId,
      onPopInvoked: onPopInvoked ?? this.onPopInvoked,
      title: title ?? this.title,
    );
  }
}

class PioneerPageWrapper {
  static Page get(
    Widget child, {
    required RouterTarget target,
  }) {
    if (Platform.isAndroid) {
      return material(child, target: target);
    }

    return cupertino(child, target: target);
  }

  static MaterialPage material(
    Widget child, {
    required RouterTarget target,
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
    required RouterTarget target,
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

extension RouterTargetExtension on RouterTarget {
  bool get hasQuery => path.queryParameters.isNotEmpty;
}
