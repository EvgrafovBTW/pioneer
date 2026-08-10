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
context.pushRoot<void>(const AdminRoute());
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
final shell = PioneerShellController(
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

Scaffold(
  body: PioneerStatefulShell(controller: shell),
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: shell.currentIndex,
    onTap: shell.goBranch,
    items: const [/* three branches */],
  ),
);
```

Every branch owns an independent `PioneerRouter`. `goBranch` keeps its stack
and widget state mounted. Use `resetBranch(index)` for one branch or
`resetBranches()` for a complete shell reset. From inside a branch,
`PioneerRouterScope.rootOf(context)` returns the outer router and can present a
page above the entire bottom bar.

Connect Android system Back to the shell through the root router:

```dart
final rootRouter = PioneerRouter(
  configuration: rootConfiguration,
  onPopFallback: shell.handleSystemBack,
);
```

The handler pops the active branch, then returns a branch root to the shell's
initial branch. It returns `false` only at the initial branch root, allowing the
platform to close the application.

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
