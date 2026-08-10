import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'delegate.dart';
import 'route.dart';
import 'stack.dart';

/// Owns an independent navigation stack and its Navigator 2.0 adapters.
final class PioneerRouter {
  PioneerRouter({
    required this.configuration,
    this.handlesSystemBack = true,
  })  : stack = PioneerStack(configuration),
        routeInformationParser = PioneerRouteInformationParser(configuration),
        routeInformationProvider = PioneerRouteInformationProvider(
          configuration.initialRoute.uri,
        ) {
    routerDelegate = PioneerRouterDelegate(stack);
    routerConfig = RouterConfig<PioneerRoutePath>(
      routerDelegate: routerDelegate,
      routeInformationParser: routeInformationParser,
      routeInformationProvider: routeInformationProvider,
      backButtonDispatcher: handlesSystemBack ? RootBackButtonDispatcher() : null,
    );
  }

  final PioneerConfiguration configuration;
  final bool handlesSystemBack;
  final PioneerStack stack;
  final PioneerRouteInformationParser routeInformationParser;
  final PioneerRouteInformationProvider routeInformationProvider;
  late final PioneerRouterDelegate routerDelegate;
  late final RouterConfig<PioneerRoutePath> routerConfig;

  List<PioneerStackEntry> get entries => stack.entries;
  PioneerRoute get currentRoute => stack.currentRoute;
  bool get canPop => stack.canPop;
  PioneerSystemBackHandler? get handleSystemBack => routerDelegate.handleSystemBack;

  set handleSystemBack(PioneerSystemBackHandler? value) {
    routerDelegate.handleSystemBack = value;
  }

  Future<T?> push<T>(PioneerRoute route) => stack.push<T>(route);

  void replace(PioneerRoute route) => stack.replace(route);

  Future<T?> pushReplacement<T, TO>(
    PioneerRoute route, {
    TO? result,
  }) =>
      stack.pushReplacement<T, TO>(route, result: result);

  Future<T?> pushAndRemoveUntil<T>(
    PioneerRoute route,
    bool Function(PioneerRoute route) predicate,
  ) =>
      stack.pushAndRemoveUntil<T>(route, predicate);

  void pop<T>([T? result]) => stack.pop<T>(result);

  void reset([PioneerRoute? route]) => stack.reset(route);

  /// Removes every page above the first one without recreating its state.
  void popToRoot() => stack.popToRoot();

  void dispose() {
    routerDelegate.dispose();
    routeInformationProvider.dispose();
    stack.dispose();
  }
}

/// Makes an independent router available to widgets below it.
final class PioneerRouterScope extends StatefulWidget {
  const PioneerRouterScope({
    super.key,
    required this.router,
    this.handleSystemBack,
    required this.child,
  });

  final PioneerRouter router;
  final PioneerSystemBackHandler? handleSystemBack;
  final Widget child;

  static PioneerRouter of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_PioneerRouterInheritedScope>();
    assert(scope != null, 'No PioneerRouterScope found in this context.');

    return scope!.router;
  }

  /// Returns the outermost Pioneer router in the current widget subtree.
  static PioneerRouter rootOf(BuildContext context) {
    _PioneerRouterInheritedScope? outermost;
    context.visitAncestorElements((element) {
      final widget = element.widget;

      if (widget is _PioneerRouterInheritedScope) {
        outermost = widget;
      }

      return true;
    });

    if (outermost == null) {
      throw FlutterError('No PioneerRouterScope found in this context.');
    }

    return outermost!.router;
  }

  @override
  State<PioneerRouterScope> createState() => _PioneerRouterScopeState();
}

final class _PioneerRouterScopeState extends State<PioneerRouterScope> {
  PioneerSystemBackHandler? _previousHandleSystemBack;

  @override
  void initState() {
    super.initState();

    _attachRouter();
  }

  @override
  void didUpdateWidget(PioneerRouterScope oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.router != widget.router) {
      _detachRouter(oldWidget.router);
      _attachRouter();

      return;
    }

    if (oldWidget.handleSystemBack != widget.handleSystemBack) {
      widget.router.handleSystemBack = widget.handleSystemBack;
    }
  }

  void _attachRouter() {
    _previousHandleSystemBack = widget.router.handleSystemBack;
    widget.router.handleSystemBack = widget.handleSystemBack;
  }

  void _detachRouter(PioneerRouter router) {
    router.handleSystemBack = _previousHandleSystemBack;
  }

  @override
  void dispose() {
    _detachRouter(widget.router);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PioneerRouterInheritedScope(
      router: widget.router,
      child: widget.child,
    );
  }
}

final class _PioneerRouterInheritedScope extends InheritedWidget {
  const _PioneerRouterInheritedScope({
    required this.router,
    required super.child,
  });

  final PioneerRouter router;

  @override
  bool updateShouldNotify(_PioneerRouterInheritedScope oldWidget) => router != oldWidget.router;
}
