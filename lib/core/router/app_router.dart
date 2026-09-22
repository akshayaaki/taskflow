import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/lists/presentation/list_detail_screen.dart';
import '../../features/lists/presentation/lists_screen.dart';
import '../../features/search_filter/presentation/search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/tasks/presentation/home_screen.dart';
import '../../features/tasks/presentation/smart_views_screen.dart';
import '../../features/tasks/presentation/task_detail_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        return null;
      }

      final hasAccess = authState.status.hasAccess;

      if (!hasAccess && !isAuthRoute) {
        return '/login';
      }

      if (hasAccess && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home / Tasks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 2: Lists
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lists',
                name: 'lists',
                builder: (context, state) => const ListsScreen(),
              ),
            ],
          ),
          // Branch 3: Stats
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                name: 'stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          // Branch 4: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/smart-views',
        name: 'smart-views',
        builder: (context, state) {
          final tab = int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
          return SmartViewsScreen(initialTabIndex: tab);
        },
      ),
      GoRoute(
        path: '/tasks/:id',
        name: 'task-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TaskDetailScreen(taskId: id);
        },
      ),
      GoRoute(
        path: '/lists/:id',
        name: 'list-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ListDetailScreen(listId: id);
        },
      ),
    ],
  );
});

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder_rounded),
            label: 'Lists',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
