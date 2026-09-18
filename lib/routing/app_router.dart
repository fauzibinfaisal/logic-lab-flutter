import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logic_lab/mini_apps/data/mini_apps_catalog.dart';
import 'package:logic_lab/mini_apps/deferred_mini_app_page.dart';
import 'package:logic_lab/portfolio_page.dart';
import 'package:logic_lab/visit_counter/data/visit_counter_repository.dart';

GoRouter createAppRouter({
  String? initialLocation,
  VisitCounterRepository? visitCounterRepository,
}) {
  // Every imperative destination in this app is also declared below as a
  // deep-linkable GoRoute, so reflecting push/pop in the web address bar is
  // safe and keeps browser history aligned with the visible mini app.
  GoRouter.optionURLReflectsImperativeAPIs = true;

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: PortfolioPage(
            visitCounterRepository: visitCounterRepository,
          ),
        ),
      ),
      GoRoute(
        path: '/mini-apps/:appId',
        pageBuilder: (context, state) {
          final app = miniAppById(state.pathParameters['appId'] ?? '');
          if (app == null) {
            return NoTransitionPage<void>(
              key: state.pageKey,
              child: const _UnknownMiniAppPage(),
            );
          }

          return MaterialPage<void>(
            key: state.pageKey,
            child: DeferredMiniAppPage(
              app: app,
              visitCounterRepository: visitCounterRepository,
              onExit: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => const _UnknownMiniAppPage(),
  );
}

class _UnknownMiniAppPage extends StatelessWidget {
  const _UnknownMiniAppPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.apps_outage_rounded,
                  color: Color(0xFF00D4FF),
                  size: 52,
                ),
                const SizedBox(height: 18),
                Text(
                  'Mini app not found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This link may be outdated. Return to the portfolio to explore the available mini apps.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white60,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to portfolio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
