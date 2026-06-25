import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/features/admin/presentation/screens/admin_extra_screens.dart';
import 'package:quex/features/admin/presentation/screens/admin_screens.dart';
import 'package:quex/features/customer/presentation/screens/customer_qr_scan_screen.dart';
import 'package:quex/features/business_owner/presentation/screens/owner_screens.dart';
import 'package:quex/features/customer/presentation/screens/customer_business_detail_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_category_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_list_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_login_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_map_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_profile_notifications_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_queue_screens.dart';
import 'package:quex/features/customer/presentation/screens/customer_search_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_welcome_screen.dart';
import 'package:quex/features/shared/presentation/screens/splash_screen.dart';
import 'package:quex/features/shared/providers/app_providers.dart';
import 'package:quex/features/staff/presentation/screens/staff_screens.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final auth = ref.read(authStateProvider);
      final path = state.matchedLocation;
      final isCustomerRoute = path.startsWith('/customer');
      final isCustomerAuth = path == '/customer/welcome' || path == '/customer/login';
      final isSplash = path == '/';
      final isRoleSelect = path == '/role-select';

      if (isCustomerRoute && !auth.isAuthenticated && !isCustomerAuth) {
        return '/customer/welcome';
      }
      if (auth.isAuthenticated && isCustomerAuth) {
        return '/customer/categories';
      }
      if (isSplash || isRoleSelect) return null;
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/role-select',
        builder: (context, state) => const RoleSelectScreen(),
      ),

      // ── Customer Portal ──────────────────────────────────────────────
      GoRoute(
        path: '/customer/welcome',
        builder: (context, state) => const CustomerWelcomeScreen(),
      ),
      GoRoute(
        path: '/customer/login',
        builder: (context, state) => const CustomerLoginScreen(),
      ),
      GoRoute(
        path: '/customer/home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/customer/categories',
        builder: (context, state) => const CustomerCategoryScreen(),
      ),
      GoRoute(
        path: '/customer/list',
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: '/customer/search',
        builder: (context, state) => const CustomerSearchScreen(),
      ),
      GoRoute(
        path: '/customer/map',
        builder: (context, state) => const CustomerMapScreen(),
      ),
      GoRoute(
        path: '/customer/check-in/:id',
        builder: (context, state) => CheckInScreen(
          businessId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/customer/business/:id',
        builder: (context, state) => CustomerBusinessDetailScreen(
          businessId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/customer/join-queue/:id',
        builder: (context, state) => JoinQueueScreen(
          businessId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/customer/queue',
        builder: (context, state) => const LiveQueueScreen(),
      ),
      GoRoute(
        path: '/customer/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/customer/scan',
        builder: (context, state) => const CustomerQrScanScreen(),
      ),
      GoRoute(
        path: '/customer/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // ── Business Admin Portal ──────────────────────────────────────
      GoRoute(
        path: '/admin/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/queue',
        builder: (context, state) => const AdminLiveQueueScreen(),
      ),
      GoRoute(
        path: '/admin/appointments',
        builder: (context, state) => const AdminAppointmentsScreen(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AdminAnalyticsScreen(),
      ),
      GoRoute(
        path: '/admin/customers',
        builder: (context, state) => const AdminCustomersScreen(),
      ),
      GoRoute(
        path: '/admin/services',
        builder: (context, state) => const AdminServicesScreen(),
      ),
      GoRoute(
        path: '/admin/staff',
        builder: (context, state) => const AdminStaffScreen(),
      ),
      GoRoute(
        path: '/admin/notifications',
        builder: (context, state) => const AdminNotificationsScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/subscription',
        builder: (context, state) => const AdminSubscriptionScreen(),
      ),
      GoRoute(
        path: '/admin/qr',
        builder: (context, state) => const AdminQrScreen(),
      ),

      // ── Owner onboarding (signup flow) ─────────────────────────────
      GoRoute(
        path: '/owner/signup',
        builder: (context, state) => const BusinessSignupScreen(),
      ),
      GoRoute(
        path: '/owner/profile-setup',
        builder: (context, state) => const BusinessProfileSetupScreen(),
      ),
      GoRoute(
        path: '/owner/queue-setup',
        builder: (context, state) => const QueueSetupScreen(),
      ),
      GoRoute(
        path: '/owner/dashboard',
        redirect: (_, __) => '/admin/dashboard',
      ),
      GoRoute(
        path: '/owner/analytics',
        redirect: (_, __) => '/admin/analytics',
      ),
      GoRoute(
        path: '/owner/subscription',
        redirect: (_, __) => '/admin/subscription',
      ),
      GoRoute(
        path: '/owner/qr',
        redirect: (_, __) => '/admin/qr',
      ),

      // ── Staff ──────────────────────────────────────────────────────
      GoRoute(
        path: '/staff/login',
        builder: (context, state) => const StaffLoginScreen(),
      ),
      GoRoute(
        path: '/staff/dashboard',
        builder: (context, state) => const StaffQueueDashboardScreen(),
      ),
    ],
  );

  ref.listen<AuthState>(authStateProvider, (_, __) => router.refresh());
  ref.onDispose(router.dispose);
  return router;
});
