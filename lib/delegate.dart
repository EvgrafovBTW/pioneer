part of 'pioneer.dart';

class PioneerRouteInformationProvider extends RouteInformationProvider {
  @override
  void addListener(VoidCallback listener) {
    // TODO: implement addListener
  }

  @override
  void removeListener(VoidCallback listener) {
    // TODO: implement removeListener
  }

  @override
  // TODO: implement value
  RouteInformation get value => throw UnimplementedError();
}

class PioneerRouterInformationParser extends RouteInformationParser<PioneerRouterTarget> {
  @override
  Future<PioneerRouterTarget> parseRouteInformation(RouteInformation routeInformation) {
    // TODO: implement parseRouteInformation
    return super.parseRouteInformation(routeInformation);
  }

  @override
  RouteInformation? restoreRouteInformation(PioneerRouterTarget configuration) {
    // TODO: implement restoreRouteInformation
    return super.restoreRouteInformation(configuration);
  }
}

class PioneerRouterDelegate extends RouterDelegate<PioneerRouterTarget>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PioneerRouterTarget> {
  final PioneerRouterTarget root;
  PioneerRouterDelegate({required this.root});

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
