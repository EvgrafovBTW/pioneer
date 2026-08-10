import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pioneer/pioneer.dart';

void main() {
  group('PioneerConfiguration', () {
    test('parses a URI into a concrete typed route', () {
      final match = configuration.matchUri(Uri(path: '/products/42'));

      expect(match.route, isA<ProductRoute>());
      expect((match.route as ProductRoute).id, 42);
    });

    test('rejects malformed and unknown URIs', () {
      expect(
        () => configuration.matchUri(Uri(path: '/products/not-an-int')),
        throwsA(isA<PioneerRouteNotFound>()),
      );
      expect(
        () => configuration.matchUri(Uri(path: '/unknown')),
        throwsA(isA<PioneerRouteNotFound>()),
      );
    });
  });

  group('PioneerRouter stack', () {
    late PioneerRouter router;

    setUp(() => router = PioneerRouter(configuration: configuration));
    tearDown(() => router.dispose());

    test('push and pop return a typed result', () async {
      final result = router.push<String>(const ProductRoute(7));

      expect(router.currentRoute, isA<ProductRoute>());
      expect(router.entries, hasLength(2));
      router.pop('selected');
      await expectLater(result, completion('selected'));
      expect(router.currentRoute, isA<HomeRoute>());
    });

    test('pop throws when the stack contains only its root page', () {
      expect(router.pop, throwsA(isA<PioneerCannotPop>()));
    });

    test('replace removes the current entry', () async {
      final pending = router.push<String>(const ProductRoute(1));

      router.replace(const ProfileRoute());

      await expectLater(pending, completion(isNull));
      expect(router.entries, hasLength(2));
      expect(router.currentRoute, isA<ProfileRoute>());
    });

    test('pushAndRemoveUntil and reset clear prior state', () async {
      final first = router.push<void>(const ProductRoute(1));
      final second = router.push<void>(const ProductRoute(2));

      router.pushAndRemoveUntil<void>(
        const ProfileRoute(),
        (route) => route is HomeRoute,
      );

      await expectLater(first, completion(isNull));
      await expectLater(second, completion(isNull));
      expect(router.entries, hasLength(2));

      router.reset(const ProductRoute(9));
      expect(router.entries, hasLength(1));
      expect((router.currentRoute as ProductRoute).id, 9);
    });
  });

  testWidgets('RouterDelegate builds pages and handles system back', (tester) async {
    final router = PioneerRouter(configuration: configuration);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.routerConfig),
    );
    expect(find.text('home'), findsOneWidget);

    router.push<void>(const ProductRoute(3));
    await tester.pumpAndSettle();
    expect(find.text('product 3'), findsOneWidget);
    expect(router.entries, hasLength(2));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(router.entries, hasLength(1));
    expect(find.text('home'), findsOneWidget);
    expect(router.canPop, isFalse);
  });

  testWidgets('external route information replaces the stack', (tester) async {
    final router = PioneerRouter(configuration: configuration);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router.routerConfig),
    );

    router.routeInformationProvider.setRouteInformation(
      RouteInformation(uri: Uri(path: '/products/42')),
    );
    await tester.pumpAndSettle();

    expect(find.text('product 42'), findsOneWidget);
    expect(router.entries, hasLength(1));
    expect((router.currentRoute as ProductRoute).id, 42);
  });

  testWidgets('BuildContext shortcuts resolve controllers and navigate', (tester) async {
    late BuildContext pageContext;

    final shortcutConfiguration = PioneerConfiguration(
      initialRoute: const HomeRoute(),
      routes: [
        PioneerRouteDefinition<HomeRoute>(
          builder: (context, route) {
            pageContext = context;

            return const Text('shortcut home');
          },
        ),
        PioneerRouteDefinition<ProductRoute>(
          builder: (context, route) => Text('shortcut product ${route.id}'),
        ),
      ],
    );
    final root = PioneerRouter(configuration: shortcutConfiguration);
    final shell = PioneerShellController(
      branches: [
        _branch(configuration, 'first'),
        _branch(configuration, 'second'),
      ],
    );
    addTearDown(() {
      root.dispose();
      shell.dispose();
    });

    await tester.pumpWidget(
      PioneerRouterScope(
        router: root,
        child: PioneerShellScope(
          controller: shell,
          child: MaterialApp.router(routerConfig: root.routerConfig),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(pageContext.pioneerRouter, same(root));
    expect(pageContext.pioneerRootRouter, same(root));
    expect(pageContext.pioneerShell, same(shell));

    pageContext.push<void>(const ProductRoute(12));
    expect((root.currentRoute as ProductRoute).id, 12);

    pageContext.pop();
    expect(root.currentRoute, isA<HomeRoute>());

    pageContext.goBranch(1);
    expect(shell.currentIndex, 1);
  });

  testWidgets('stateful shell preserves branch state and resets all branches', (
    tester,
  ) async {
    final shell = PioneerShellController(
      branches: [
        _branch(counterConfiguration, 'counter'),
        _branch(configuration, 'second'),
        _branch(configuration, 'third'),
      ],
    );
    addTearDown(shell.dispose);
    await tester.pumpWidget(
      MaterialApp(home: PioneerStatefulShell(controller: shell)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('increment')));
    await tester.pump();
    expect(find.text('count 1'), findsOneWidget);

    shell.goBranch(1);
    await tester.pump();
    shell.branch(1).push<void>(const ProductRoute(11));
    await tester.pumpAndSettle();
    expect(shell.branch(1).entries, hasLength(2));

    shell.goBranch(0);
    await tester.pump();
    expect(shell.currentIndex, 0);
    expect(shell.branch(0).entries, hasLength(1));
    expect(find.text('count 1', skipOffstage: false), findsOneWidget);
    expect(find.text('count 1'), findsOneWidget);

    shell.resetBranches();
    await tester.pumpAndSettle();
    expect(find.text('count 0'), findsOneWidget);
    expect(shell.currentIndex, 0);
    expect(shell.branches.every((branch) => branch.entries.length == 1), isTrue);
  });

  test('root back falls through to the active shell branch', () async {
    final shell = PioneerShellController(
      branches: [
        _branch(configuration, 'first'),
        _branch(configuration, 'second'),
        _branch(configuration, 'third'),
      ],
    );
    final root = PioneerRouter(configuration: configuration);
    root.handleSystemBack = shell.handleSystemBack;
    addTearDown(() {
      root.dispose();
      shell.dispose();
    });
    shell.branch(0).push<void>(const ProductRoute(5));

    expect(await root.routerDelegate.popRoute(), isTrue);
    expect(shell.branch(0).entries, hasLength(1));
  });

  test('system back returns a branch root to the initial branch', () async {
    final shell = PioneerShellController(
      branches: [
        _branch(configuration, 'first'),
        _branch(configuration, 'second'),
        _branch(configuration, 'third'),
      ],
    );
    final root = PioneerRouter(configuration: configuration);
    root.handleSystemBack = shell.handleSystemBack;
    addTearDown(() {
      root.dispose();
      shell.dispose();
    });

    shell.goBranch(1);

    expect(await root.routerDelegate.popRoute(), isTrue);
    expect(shell.currentIndex, shell.initialIndex);
    expect(await root.routerDelegate.popRoute(), isFalse);
  });

  testWidgets('router scope installs and removes its system back handler', (tester) async {
    final root = PioneerRouter(configuration: configuration);
    var calls = 0;
    addTearDown(root.dispose);

    await tester.pumpWidget(
      PioneerRouterScope(
        router: root,
        handleSystemBack: () {
          calls++;

          return true;
        },
        child: MaterialApp.router(routerConfig: root.routerConfig),
      ),
    );
    await tester.pumpAndSettle();

    expect(await root.routerDelegate.popRoute(), isTrue);
    expect(calls, 1);

    await tester.pumpWidget(
      PioneerRouterScope(
        router: root,
        child: MaterialApp.router(routerConfig: root.routerConfig),
      ),
    );
    await tester.pump();

    expect(await root.routerDelegate.popRoute(), isFalse);
    expect(calls, 1);
  });

  group('PioneerShellController.goTo', () {
    test('prefers the active branch when it supports the route', () {
      final shell = PioneerShellController(
        branches: [
          _branch(productConfiguration, 'home'),
          _branch(productConfiguration, 'catalog'),
        ],
      );
      addTearDown(shell.dispose);

      shell.goTo(const ProductRoute(7));

      expect(shell.currentIndex, 0);
      expect((shell.currentBranch.currentRoute as ProductRoute).id, 7);
    });

    test('selects the only matching keyed branch', () {
      final shell = PioneerShellController(
        branches: [
          _branch(profileConfiguration, 'profile'),
          _branch(productConfiguration, 'catalog'),
        ],
      );
      addTearDown(shell.dispose);

      shell.goTo(const ProductRoute(8));

      expect(shell.currentIndex, 1);
      expect((shell.currentBranch.currentRoute as ProductRoute).id, 8);
    });

    test('throws when multiple inactive branches match', () {
      final shell = PioneerShellController(
        branches: [
          _branch(profileConfiguration, 'profile'),
          _branch(productConfiguration, 'home'),
          _branch(productConfiguration, 'catalog'),
        ],
      );
      addTearDown(shell.dispose);

      expect(
        () => shell.goTo(const ProductRoute(9)),
        throwsA(isA<PioneerAmbiguousShellRoute>()),
      );
    });

    test('an explicit key searches only that branch', () {
      final shell = PioneerShellController(
        branches: [
          _branch(profileConfiguration, 'profile'),
          _branch(productConfiguration, 'home'),
          _branch(productConfiguration, 'catalog'),
        ],
      );
      addTearDown(shell.dispose);

      shell.goTo(
        const ProductRoute(10),
        branchKey: const ValueKey<String>('catalog'),
      );

      expect(shell.currentIndex, 2);
      expect((shell.currentBranch.currentRoute as ProductRoute).id, 10);
      expect(
        () => shell.goTo(
          const ProductRoute(10),
          branchKey: const ValueKey<String>('profile'),
        ),
        throwsA(isA<PioneerShellRouteNotFound>()),
      );
    });
  });

  testWidgets('nested shell does not duplicate navigator keys on startup/reset', (
    tester,
  ) async {
    final shell = PioneerShellController(
      branches: [
        _branch(counterConfiguration, 'counter'),
        _branch(configuration, 'second'),
        _branch(configuration, 'third'),
      ],
    );
    final rootConfiguration = PioneerConfiguration(
      initialRoute: const HomeRoute(),
      routes: [
        PioneerRouteDefinition<HomeRoute>(
          builder: (context, route) => PioneerStatefulShell(controller: shell),
        ),
        PioneerRouteDefinition<ProfileRoute>(
          builder: (context, route) => const Text('root admin'),
        ),
      ],
    );
    final root = PioneerRouter(configuration: rootConfiguration);
    addTearDown(() {
      root.dispose();
      shell.dispose();
    });

    await tester.pumpWidget(
      PioneerRouterScope(
        router: root,
        child: MaterialApp.router(routerConfig: root.routerConfig),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('count 0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('increment')));
    root.push<void>(const ProfileRoute());
    await tester.pumpAndSettle();
    expect(find.text('root admin'), findsOneWidget);

    shell.resetBranches();
    root.popToRoot();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('count 0'), findsOneWidget);
  });
}

class _CounterPage extends StatefulWidget {
  const _CounterPage();

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  var count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('count $count'),
        TextButton(
          key: const Key('increment'),
          onPressed: () => setState(() => count++),
          child: const Text('increment'),
        ),
      ],
    );
  }
}

final class HomeRoute implements PioneerRoute {
  const HomeRoute();

  @override
  Uri get uri => Uri(path: '/');
}

final class ProductRoute implements PioneerRoute {
  const ProductRoute(this.id);

  final int id;

  @override
  Uri get uri => Uri(path: '/products/$id');
}

final class ProfileRoute implements PioneerRoute {
  const ProfileRoute();

  @override
  Uri get uri => Uri(path: '/profile');
}

final configuration = PioneerConfiguration(
  initialRoute: const HomeRoute(),
  routes: [
    PioneerRouteDefinition<HomeRoute>(
      builder: (context, route) => const Text('home'),
    ),
    PioneerRouteDefinition<ProductRoute>.deepLink(
      parse: (uri) {
        if (uri.pathSegments.length != 2 || uri.pathSegments.first != 'products') {
          return null;
        }

        final id = int.tryParse(uri.pathSegments.last);

        return id == null ? null : ProductRoute(id);
      },
      builder: (context, route) => Text('product ${route.id}'),
    ),
    PioneerRouteDefinition<ProfileRoute>(
      builder: (context, route) => const Text('profile'),
    ),
  ],
);

final counterConfiguration = PioneerConfiguration(
  initialRoute: const HomeRoute(),
  routes: [
    PioneerRouteDefinition<HomeRoute>(
      builder: (context, route) => const _CounterPage(),
    ),
  ],
);

PioneerShellBranch _branch(PioneerConfiguration configuration, String key) => PioneerShellBranch(
      key: ValueKey<String>(key),
      configuration: configuration,
    );

final productConfiguration = PioneerConfiguration(
  initialRoute: const ProductRoute(0),
  routes: [
    PioneerRouteDefinition<ProductRoute>(
      builder: (context, route) => Text('product ${route.id}'),
    ),
  ],
);

final profileConfiguration = PioneerConfiguration(
  initialRoute: const ProfileRoute(),
  routes: [
    PioneerRouteDefinition<ProfileRoute>(
      builder: (context, route) => const Text('profile'),
    ),
  ],
);
