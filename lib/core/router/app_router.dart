import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/features/business_owner/presentation/screens/owner_screens.dart';
import 'package:quex/features/customer/presentation/screens/customer_category_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_login_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_map_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_profile_notifications_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_queue_screens.dart';
import 'package:quex/features/customer/presentation/screens/customer_search_screen.dart';
import 'package:quex/features/shared/presentation/screens/splash_screen.dart';
import 'package:quex/features/shared/providers/app_providers.dart';
import 'package:quex/features/staff/presentation/screens/staff_screens.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.matchedLocation;
      final isCustomerRoute = path.startsWith('/customer');
      final isCustomerLogin = path == '/customer/login';
      final isSplash = path == '/';
      final isRoleSelect = path == '/role-select';

      if (isCustomerRoute && !auth.isAuthenticated && !isCustomerLogin) {
        return '/customer/login';
      }
      if (auth.isAuthenticated && isCustomerLogin) {
        return '/customer/home';
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
        builder: (context, state) => BusinessDetailsScreen(
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
        path: '/customer/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
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
        builder: (context, state) => const OwnerDashboardScreen(),
      ),
      GoRoute(
        path: '/owner/qr',
        builder: (context, state) => const QrCodeScreen(),
      ),
      GoRoute(
        path: '/owner/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/owner/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
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
});
