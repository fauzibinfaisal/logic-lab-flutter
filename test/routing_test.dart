import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logic_lab/main.dart';
import 'package:logic_lab/mini_apps/qibla/qibla_page.dart';
import 'package:logic_lab/routing/app_router.dart';

void main() {
  testWidgets('pushing a mini app updates the route URL and can pop home', (
    tester,
  ) async {
    final router = createAppRouter(initialLocation: '/');
    addTearDown(router.dispose);

    await tester.pumpWidget(PortfolioApp(router: router));
    await tester.pumpAndSettle();

    router.push('/mini-apps/qibla');
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/mini-apps/qibla');
    expect(find.byType(QiblaPage), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/');
    expect(find.text('View Mini Apps'), findsOneWidget);
  });

  testWidgets('direct mini-app URL opens Qibla and returns to portfolio', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = createAppRouter(initialLocation: '/mini-apps/qibla');
    addTearDown(router.dispose);

    await tester.pumpWidget(PortfolioApp(router: router));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/mini-apps/qibla');
    expect(find.byType(QiblaPage), findsOneWidget);
    expect(find.text('Use my location'), findsOneWidget);

    await tester.tap(find.byTooltip('Back to Mini Apps').first);
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/');
    expect(find.text('View Mini Apps'), findsOneWidget);
  });

  testWidgets('unknown mini-app URL has a safe route back home',
      (tester) async {
    final router = createAppRouter(
      initialLocation: '/mini-apps/not-a-real-app',
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(PortfolioApp(router: router));
    await tester.pumpAndSettle();

    expect(find.text('Mini app not found'), findsOneWidget);
    await tester.tap(find.text('Back to portfolio'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/');
    expect(find.text('View Mini Apps'), findsOneWidget);
  });
}
