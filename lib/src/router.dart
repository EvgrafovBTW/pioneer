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
    this.onPopFallback,
  })  : stack = PioneerStack(configuration),
        routeInformationParser = PioneerRouteInformationParser(configuration),
        routeInformationProvider = PioneerRouteInformationProvider(
          configuration.initialRoute.uri,
        ) {
    routerDelegate = PioneerRouterDelegate(
      stack,
      onPopFallback: onPopFallback,
    );
    routerConfig = RouterConfig<PioneerRoutePath>(
      routerDelegate: routerDelegate,
      routeInformationParser: routeInformationParser,
      routeInformationProvider: routeInformationProvider,
      backButtonDispatcher: handlesSystemBack ? RootBackButtonDispatcher() : null,
    );
  }

  final PioneerConfiguration configuration;
  final bool handlesSystemBack;
  final bool Function()? onPopFallback;
  final PioneerStack stack;
  final PioneerRouteInformationParser routeInformationParser;
  final PioneerRouteInformationProvider routeInformationProvider;
  late final PioneerRouterDelegate routerDelegate;
  late final RouterConfig<PioneerRoutePath> routerConfig;

  List<PioneerStackEntry> get entries => stack.entries;
  PioneerRoute get currentRoute => stack.currentRoute;
  bool get canPop => stack.canPop;

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
final class PioneerRouterScope extends InheritedWidget {
  const PioneerRouterScope({
    super.key,
    required this.router,
    required super.child,
  });

  final PioneerRouter router;

  static PioneerRouter of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PioneerRouterScope>();
    assert(scope != null, 'No PioneerRouterScope found in this context.');
    return scope!.router;
  }

  /// Returns the outermost Pioneer router in the current widget subtree.
  static PioneerRouter rootOf(BuildContext context) {
    PioneerRouterScope? outermost;
    context.visitAncestorElements((element) {
      final widget = element.widget;

      if (widget is PioneerRouterScope) {
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
  bool updateShouldNotify(PioneerRouterScope oldWidget) => router != oldWidget.router;
}
