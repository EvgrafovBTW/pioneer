part of 'pioneer.dart';

class PioneerRouterDelegate extends RouterDelegate<PioneerRouterTarget>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PioneerRouterTarget> {
  PioneerRouterTarget? _target;

  @override
  Future<void> setNewRoutePath(PioneerRouterTarget configuration) async {}

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _buildPages(),
    );
  }

  List<Page> _buildPages() {
    final List<Page> pages = [];

    return pages;
  }

  @override
  PioneerRouterTarget? get currentConfiguration => _target;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> push(PioneerRouterTarget target) async {
    await setNewRoutePath(target);
  }
}
