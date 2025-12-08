import 'package:pioneer/pioneer.dart';

part 'paths.dart';

class RouterTarget extends PioneerRouterTarget {
  const RouterTarget({
    required super.path,
    super.extra,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
    super.maintainState = true,
    super.fullscreenDialog = false,
    super.allowSnapshotting = true,
    super.canPop = true,
    super.title,
  });

  RouterTarget.root() : super(path: Paths.root, extra: null);
}
