import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/firebase_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/users/presentation/users_screen.dart';
import '../../features/rooms/presentation/rooms_screen.dart';
import '../../features/moderation/presentation/moderation_overview_screen.dart';
import '../../features/moderation/presentation/chat_moderation_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAdminAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isAuthenticated && !isGoingToLogin) {
        return '/login';
      }

      if (isAuthenticated && isGoingToLogin) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: '/rooms',
            builder: (context, state) => const RoomsScreen(),
          ),
          // Moderation overview — list of all rooms to pick from
          GoRoute(
            path: '/moderation',
            builder: (context, state) => const ModerationOverviewScreen(),
          ),
          // Per-room chat moderation
          GoRoute(
            path: '/moderation/:roomId',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId']!;
              return ChatModerationScreen(roomId: roomId);
            },
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
