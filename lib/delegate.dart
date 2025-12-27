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

class PioneerRouterInformationParser extends RouteInformationParser<RouterTarget> {
  @override
  Future<RouterTarget> parseRouteInformation(RouteInformation routeInformation) async {
    log('parseRouteInformation');
    // TODO: implement parseRouteInformation
    return RouterTarget(path: Uri());
  }

  @override
  RouteInformation? restoreRouteInformation(RouterTarget configuration) {
    log('restoreRouteInformation');
    // TODO: implement restoreRouteInformation
    return super.restoreRouteInformation(configuration);
  }
}

class PioneerRouterDelegate extends RouterDelegate<RouterTarget>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouterTarget> {
  final RouterTarget root;

  PioneerRouterDelegate({
    required this.root,
  });

  RouterTarget? _target;

  @override
  Future<void> setRestoredRoutePath(RouterTarget configuration) async {
    log('setRestoredRoutePath');
  }

  @override
  Future<void> setInitialRoutePath(RouterTarget configuration) async {
    log('setInitialRoutePath');
    await setNewRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(RouterTarget configuration) async {
    log('setNewRoutePath');

    _target = configuration;
    notifyListeners();
  }

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
      /* PioneerPageWrapper.get(
        targetToWidgetTranslator(root),
        target: root,
      ), */
    ];

    if (currentConfiguration.path.path.isEmpty) {
      return pages;
    }

    pages.clear();

    /* pages.add(
      PioneerPageWrapper.get(
        targetToWidgetTranslator(currentConfiguration),
        target: currentConfiguration,
      ),
    ); */

    return pages;
  }

  @override
  RouterTarget get currentConfiguration => _target ?? root;

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> push(RouterTarget target) async {
    await setNewRoutePath(target);
  }

  Future<void> pop(BuildContext context) async {
    Navigator.of(context).pop();
  }
}
