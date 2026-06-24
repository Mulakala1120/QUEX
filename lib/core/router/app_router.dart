import 'package:go_router/go_router.dart';
import 'package:quex/features/business_owner/presentation/screens/owner_screens.dart';
import 'package:quex/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_login_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_profile_notifications_screen.dart';
import 'package:quex/features/customer/presentation/screens/customer_queue_screens.dart';
import 'package:quex/features/customer/presentation/screens/customer_search_screen.dart';
import 'package:quex/features/shared/presentation/screens/splash_screen.dart';
import 'package:quex/features/staff/presentation/screens/staff_screens.dart';

final appRouter = GoRouter(
  initialLocation: '/role-select',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/role-select',
      builder: (context, state) => const RoleSelectScreen(),
    ),
    // Customer routes
    GoRoute(
      path: '/customer/login',
      builder: (context, state) => const CustomerLoginScreen(),
    ),
    GoRoute(
      path: '/customer/home',
      builder: (context, state) => const CustomerHomeScreen(),
    ),
    GoRoute(
      path: '/customer/search',
      builder: (context, state) => const CustomerSearchScreen(),
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
    // Business owner routes
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
    // Staff routes
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
