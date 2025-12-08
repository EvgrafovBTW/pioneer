part of 'pioneer.dart';

class PioneerRouteInformationProvider<RouterTarget> extends RouteInformationProvider {
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

class PioneerRouterInformationParser extends RouteInformationParser<RouterTarget> {
  @override
  Future<RouterTarget> parseRouteInformation(RouteInformation routeInformation) async {
    // TODO: implement parseRouteInformation
    return RouterTarget(path: Uri());
  }

  @override
  RouteInformation? restoreRouteInformation(RouterTarget configuration) {
    // TODO: implement restoreRouteInformation
    return super.restoreRouteInformation(configuration);
  }
}

class PioneerRouterDelegate extends RouterDelegate<RouterTarget>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouterTarget> {
  final RouterTarget root;
  final Widget Function(RouterTarget target) targetToWidgetTranslator;

  PioneerRouterDelegate({required this.root, required this.targetToWidgetTranslator});

  RouterTarget? _target;

  @override
  Future<void> setRestoredRoutePath(RouterTarget configuration) async {}

  @override
  Future<void> setInitialRoutePath(RouterTarget configuration) async {}

  @override
  Future<void> setNewRoutePath(RouterTarget configuration) async {}

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _buildPages(),
      onDidRemovePage: (page) {},
    );
  }

  List<Page> _buildPages() {
    final List<Page> pages = [
      Platform.isAndroid
          ? PioneerPageWrapper.material(targetToWidgetTranslator(currentConfiguration),
              target: currentConfiguration)
          : PioneerPageWrapper.cupertino(targetToWidgetTranslator(currentConfiguration),
              target: currentConfiguration)
    ];

    return pages;
  }

  @override
  RouterTarget get currentConfiguration => _target ?? root;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> push(RouterTarget target) async {
    await setNewRoutePath(target);
  }
}
