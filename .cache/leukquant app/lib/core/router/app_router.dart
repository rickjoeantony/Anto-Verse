// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/diagnostics/presentation/diagnostics_screen.dart';
import '../../features/events/presentation/events_screen.dart';
import '../../features/incidents/presentation/incidents_screen.dart';
import '../../features/more/presentation/deployments_screen.dart';
import '../../features/more/presentation/more_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/overview/presentation/overview_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/shell/presentation/main_shell_screen.dart';
import '../../features/states/presentation/state_pages.dart';
import '../../features/states/presentation/state_views_showcase_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _eventsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'eventsNav');
final _incidentsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'incidentsNav');
final _reportsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'reportsNav');
final _moreNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'moreNav');

/// Provider for app-wide GoRouter instance with 5-tab customer navigation (Home, Events, Incidents, Reports, More).
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Onboarding Flow
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 3. Login Screen
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 4. State Views & Showcase Hub
      GoRoute(
        path: '/states',
        builder: (context, state) => const StateViewsShowcaseScreen(),
        routes: [
          GoRoute(
            path: 'empty',
            builder: (context, state) => const EmptyStatePage(),
          ),
          GoRoute(
            path: 'loading',
            builder: (context, state) => const LoadingStatePage(),
          ),
          GoRoute(
            path: 'error',
            builder: (context, state) => const ErrorStatePage(),
          ),
          GoRoute(
            path: 'no-internet',
            builder: (context, state) => const NoInternetPage(),
          ),
          GoRoute(
            path: 'slow-network',
            builder: (context, state) => const SlowNetworkPage(),
          ),
          GoRoute(
            path: 'no-search',
            builder: (context, state) => const NoSearchResultsPage(),
          ),
          GoRoute(
            path: 'permission-denied',
            builder: (context, state) => const PermissionDeniedPage(),
          ),
          GoRoute(
            path: 'session-expired',
            builder: (context, state) => const SessionExpiredPage(),
          ),
          GoRoute(
            path: 'form-validation',
            builder: (context, state) => const FormValidationPage(),
          ),
          GoRoute(
            path: 'success',
            builder: (context, state) => const SuccessStatePage(),
          ),
        ],
      ),

      // 5. Main Shell with 5 Bottom Navigation Branches (Home, Events, Incidents, Reports, More)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/overview',
                builder: (context, state) => const OverviewScreen(),
              ),
            ],
          ),

          // Branch 2: Events
          StatefulShellBranch(
            navigatorKey: _eventsNavigatorKey,
            routes: [
              GoRoute(
                path: '/events',
                builder: (context, state) => const EventsScreen(),
              ),
            ],
          ),

          // Branch 3: Incidents
          StatefulShellBranch(
            navigatorKey: _incidentsNavigatorKey,
            routes: [
              GoRoute(
                path: '/incidents',
                builder: (context, state) => const IncidentsScreen(),
              ),
            ],
          ),

          // Branch 4: Reports
          StatefulShellBranch(
            navigatorKey: _reportsNavigatorKey,
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),

          // Branch 5: More (Deployments, Settings, States Showcase)
          StatefulShellBranch(
            navigatorKey: _moreNavigatorKey,
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreScreen(),
                routes: [
                  GoRoute(
                    path: 'deployments',
                    builder: (context, state) => const DeploymentsScreen(),
                  ),
                  GoRoute(
                    path: 'diagnostics',
                    builder: (context, state) => const DiagnosticsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
