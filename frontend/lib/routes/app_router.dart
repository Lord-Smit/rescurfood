import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/admin/screens/admin_dashboard.dart';
import '../features/admin/screens/approval_detail_screen.dart';
import '../features/admin/screens/manage_donations_screen.dart';
import '../features/admin/screens/manage_users_screen.dart';
import '../features/admin/screens/pending_approvals_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/donor/screens/donation_history_screen.dart';
import '../features/donor/screens/donor_home.dart';
import '../features/donor/screens/upload_donation_screen.dart';
import '../features/ngo/screens/ngo_home.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Notifies [GoRouter] when auth changes without recreating the router.
class _AuthRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh();
  ref.listen<AuthState>(authProvider, (_, __) => refresh.ping());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final loggedIn = authState.status == AuthStatus.authenticated;
      final location = state.matchedLocation;
      final onAuthPage =
          location.startsWith('/login') || location.startsWith('/signup');
      final isSplash = location == '/splash';

      if (isSplash) return null;

      if (authState.status == AuthStatus.unknown) return '/splash';
      if (!loggedIn && !onAuthPage) return '/login';
      if (loggedIn && onAuthPage) {
        return _homeForRole(authState.user?.role) ?? '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignupScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) =>
            _roleShell(ref.read(authProvider).user?.role, child),
        routes: [
          GoRoute(
            path: '/',
            redirect: (_, __) =>
                _homeForRole(ref.read(authProvider).user?.role),
          ),
          GoRoute(
            path: '/donor/home',
            builder: (_, __) => const DonorHomeScreen(),
          ),
          GoRoute(
            path: '/donor/history',
            builder: (_, __) => const DonationHistoryScreen(),
          ),
          GoRoute(
            path: '/donor/upload',
            builder: (_, __) => const UploadDonationScreen(),
          ),
          GoRoute(
            path: '/ngo/home',
            builder: (_, __) => const NgoHomeScreen(),
          ),
          GoRoute(
            path: '/admin/dashboard',
            builder: (_, __) => const AdminDashboard(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (_, __) => const ManageUsersScreen(),
          ),
          GoRoute(
            path: '/admin/donations',
            builder: (_, __) => const ManageDonationsScreen(),
          ),
          GoRoute(
            path: '/admin/approvals',
            builder: (_, __) => const PendingApprovalsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ApprovalDetailScreen(
                  requestId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

String? _homeForRole(UserRole? role) {
  if (role == null) return '/login';
  switch (role) {
    case UserRole.donor:
      return '/donor/home';
    case UserRole.ngo:
      return '/ngo/home';
    case UserRole.admin:
      return '/admin/dashboard';
  }
}

Widget _roleShell(UserRole? role, Widget child) {
  if (role == null) return child;
  return _RoleScaffold(role: role, child: child);
}

class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    try {
      await ref
          .read(authProvider.notifier)
          .checkAuth()
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('Splash auth check failed: $e');
      if (ref.read(authProvider).status == AuthStatus.unknown) {
        ref.read(authProvider.notifier).markUnauthenticated();
      }
    }

    if (!mounted) return;
    final state = ref.read(authProvider);
    if (state.status == AuthStatus.authenticated) {
      context.go(_homeForRole(state.user?.role) ?? '/login');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _RoleScaffold extends StatelessWidget {
  final UserRole role;
  final Widget child;

  const _RoleScaffold({required this.role, required this.child});

  @override
  Widget build(BuildContext context) {
    final tabs = _tabsForRole(role);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context, tabs),
        onDestinationSelected: (i) => _onTap(context, i, tabs),
        destinations: tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }

  List<_TabItem> _tabsForRole(UserRole role) {
    switch (role) {
      case UserRole.donor:
        return const [
          _TabItem('Home', Icons.home_outlined, '/donor/home'),
          _TabItem('History', Icons.history, '/donor/history'),
          _TabItem('Upload', Icons.add_circle_outline, '/donor/upload'),
        ];
      case UserRole.ngo:
        return const [
          _TabItem('Available', Icons.inventory_2_outlined, '/ngo/home'),
          _TabItem('Home', Icons.home_outlined, '/ngo/home'),
        ];
      case UserRole.admin:
        return const [
          _TabItem('Dashboard', Icons.dashboard_outlined, '/admin/dashboard'),
          _TabItem('Users', Icons.people_outlined, '/admin/users'),
          _TabItem('Approvals', Icons.checklist, '/admin/approvals'),
          _TabItem('Donations', Icons.fastfood_outlined, '/admin/donations'),
        ];
    }
  }

  int _currentIndex(BuildContext context, List<_TabItem> tabs) {
    final location = GoRouterState.of(context).matchedLocation;
    final index =
        tabs.indexWhere((t) => t.path != null && location.startsWith(t.path!));
    return index < 0 ? 0 : index;
  }

  void _onTap(BuildContext context, int index, List<_TabItem> tabs) {
    if (index >= 0 && index < tabs.length) {
      final tab = tabs[index];
      if (tab.path != null) {
        context.go(tab.path!);
      }
    }
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final String? path;

  const _TabItem(this.label, this.icon, this.path);
}
