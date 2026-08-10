# Pioneer

Pioneer is a typed navigation package built on Flutter's Navigator 2.0. Routes
are immutable objects, public navigation methods do not accept string paths,
and untrusted deep links are converted to typed routes at the system boundary.

## Define routes

```dart
final class ProductRoute implements PioneerRoute {
  const ProductRoute({required this.productId});

  final int productId;

  @override
  Uri get uri => Uri(path: '/products/$productId');
}

final configuration = PioneerConfiguration(
  initialRoute: const HomeRoute(),
  routes: [
    PioneerRouteDefinition<HomeRoute>(
      builder: (context, route) => const HomeScreen(),
    ),
    PioneerRouteDefinition<ProductRoute>.deepLink(
      parse: (uri) {
        if (uri.pathSegments case ['products', final rawId]) {
          final id = int.tryParse(rawId);

          return id == null ? null : ProductRoute(productId: id);
        }

        return null;
      },
      builder: (context, route) => ProductScreen(id: route.productId),
    ),
  ],
);
```

Every route type used as `initialRoute` must have a corresponding definition.
Malformed or unknown incoming addresses throw `PioneerRouteNotFound`.

## Install the router

```dart
final router = PioneerRouter(configuration: configuration);

MaterialApp.router(routerConfig: router.routerConfig);
```

## BuildContext shortcuts

When the corresponding scopes are available, navigation can be invoked directly
from `BuildContext`:

```dart
context.push<void>(const ProductRoute(productId: 42));
context.pop();
context.pushRoot<void>(const AuthRoute());
context.goTo(const HomeDetailsRoute());
context.resetBranches();
context.popToRoot();
```

The controllers remain available for explicit access:

```dart
context.pioneerRouter;
context.pioneerRootRouter;
context.pioneerShell;
```

Each `PioneerRouter` owns an independent stack, so it can also back a nested
`Router` inside a dialog, sheet, tab, or another local widget subtree.

## Navigate

```dart
final Product? selected = await router.push<Product>(
  const ProductPickerRoute(),
);

router.pop(selectedProduct);
router.replace(const ProfileRoute());
router.pushReplacement<void, Product>(const HomeRoute(), result: selected);
router.pushAndRemoveUntil<void>(const HomeRoute(), (route) => false);
router.reset();
router.reset(const LoginRoute());
```

`pop` returns `void` and throws `PioneerCannotPop` when `canPop` is false.
Check `router.canPop` first when reaching the root page is an expected case.

`reset` does not require a `BuildContext`; it completes pending route results,
discards the existing stack and creates a fresh page, including fresh widget
state.

## Stateful shell

```dart
final shell = PioneerShellController.branches(
  branches: [
    PioneerShellBranch(
      key: const ValueKey('homeKey'),
      configuration: homeConfiguration,
    ),
    PioneerShellBranch(
      key: const ValueKey('catalogKey'),
      configuration: catalogConfiguration,
    ),
    PioneerShellBranch(
      key: const ValueKey('profileKey'),
      configuration: profileConfiguration,
    ),
  ],
);

PioneerShellScope(
  controller: shell,
  child: Scaffold(
    body: PioneerStatefulShell(controller: shell),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: shell.currentIndex,
      onTap: shell.goBranch,
      items: const [/* three branches */],
    ),
  ),
);
```

Every branch owns an independent `PioneerRouter`. `goBranch` keeps its stack
and widget state mounted. Use `resetBranch(index)` for one branch or
`resetBranches()` for a complete shell reset. From inside a branch,
`PioneerRouterScope.rootOf(context)` returns the outer router and can present a
page above the entire bottom bar.

For a linear flow without tabs, create a single-stack shell:

```dart
final authShell = PioneerShellController.single(
  configuration: authConfiguration,
);

PioneerShellScope(controller: authShell);
```

It owns exactly one router, available as `authShell.router`. Pages such as sign
in and registration use the regular `push`, `pop`, and `reset` operations. A
single shell has no branch switching; `handleSystemBack` pops its router and
returns `false` at its initial page.

This keeps root route builders uniform:

```dart
const needAuth = true;
final PioneerRoute initialRoute = needAuth ? const AuthRoute() : const RootRoute();

final rootRouter = PioneerRouter(
  configuration: rootConfiguration(
    initialRoute: initialRoute,
    rootBuilder: (context, route) => PioneerShellScope(
      controller: branchShell,
      child: const RootScreen(),
    ),
    authBuilder: (context, route) => PioneerShellScope(
      controller: authShell,
    ),
  ),
);
```

The startup decision is made before `runApp`. In a real application,
`needAuth` can be obtained from persisted user or session data before creating
the root router.

The two shell builders themselves remain uniform:

```dart
rootBuilder: (context, route) => PioneerShellScope(
  controller: branchShell,
  child: const RootScreen(),
),
authBuilder: (context, route) => PioneerShellScope(
  controller: authShell,
),
```

Connect Android system Back to the shell where the root router enters the widget tree:

```dart
PioneerRouterScope(
  router: rootRouter,
  handleSystemBack: shell.handleSystemBack,
  child: MaterialApp.router(routerConfig: rootRouter.routerConfig),
);
```

The handler pops the active branch, then returns a branch root to the shell's
initial branch. It returns `false` only at the initial branch root, allowing the
platform to close the application. The parameter is nullable; without it, an
unhandled Back action is passed to the platform.

From a branch page, `goTo` resolves and activates a keyed branch. It prefers
the active branch, then requires exactly one matching branch. An ambiguous
match throws `PioneerAmbiguousShellRoute`:

```dart
PioneerShellScope.of(context).goTo(const ProductRoute(id: 42));

PioneerShellScope.of(context).goTo(
  const ProductRoute(id: 42),
  branchKey: const ValueKey('catalogKey'),
);
```
