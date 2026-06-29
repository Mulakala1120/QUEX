import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/domain/entities/entities.dart';

class DummyDataSource {
  static final List<Business> businesses = [
    const Business(
      id: 'biz_1',
      name: 'QueX Cuts Koramangala',
      category: 'Salon',
      address: '12th Main, Koramangala, Bengaluru',
      distanceMiles: 0.5,
      rating: 4.8,
      waitMinutes: 10,
      queueCount: 4,
      isOpen: true,
      description:
          'Premium unisex salon with walk-ins welcome. Expert stylists, fast service.',
      phone: '+91 98765 43210',
      services: [
        'Haircut',
        'Haircut + Beard',
        'Kids Haircut',
        'Styling',
        'Color',
      ],
      hours: 'Mon–Sat 9am–9pm',
    ),
    const Business(
      id: 'biz_2',
      name: 'Style Studio Indiranagar',
      category: 'Salon',
      address: '100 Feet Road, Indiranagar, Bengaluru',
      distanceMiles: 1.2,
      rating: 4.6,
      waitMinutes: 18,
      queueCount: 6,
      isOpen: true,
      description: 'Trendy cuts and styling for the whole family.',
      phone: '+91 98765 43211',
      services: [
        'Haircut',
        'Haircut + Beard',
        'Kids Haircut',
        'Styling',
        'Color',
      ],
      hours: 'Mon–Sun 10am–8pm',
    ),
    const Business(
      id: 'biz_3',
      name: 'Luxe Hair Lounge',
      category: 'Salon',
      address: 'Brigade Road, Bengaluru',
      distanceMiles: 2.4,
      rating: 4.9,
      waitMinutes: 8,
      queueCount: 2,
      isOpen: true,
      services: [
        'Haircut',
        'Haircut + Beard',
        'Kids Haircut',
        'Styling',
        'Color',
      ],
      hours: 'Tue–Sun 10am–9pm',
    ),
    const Business(
      id: 'biz_4',
      name: 'The Fade Factory',
      category: 'Salon',
      address: 'HSR Layout Sector 2, Bengaluru',
      distanceMiles: 3.1,
      rating: 4.7,
      waitMinutes: 15,
      queueCount: 5,
      isOpen: true,
      services: [
        'Haircut',
        'Haircut + Beard',
        'Kids Haircut',
        'Styling',
      ],
      hours: 'Daily 9am–9pm',
    ),
    const Business(
      id: 'biz_5',
      name: 'Classic Cuts MG Road',
      category: 'Salon',
      address: 'MG Road, Bengaluru',
      distanceMiles: 4.2,
      rating: 4.5,
      waitMinutes: 0,
      queueCount: 0,
      isOpen: false,
      services: [
        'Haircut',
        'Haircut + Beard',
        'Kids Haircut',
        'Styling',
        'Color',
      ],
      hours: 'Closed today',
    ),
  ];

  static final Map<String, List<QueueEntry>> queues = {
    'biz_1': [
      QueueEntry(
        id: 'q_1',
        position: 1,
        customerName: 'Rahul M.',
        service: 'Haircut',
        status: QueueStatus.serving,
        estimatedWaitMinutes: 0,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      QueueEntry(
        id: 'q_2',
        position: 2,
        customerName: 'Priya S.',
        service: 'Haircut + Beard',
        status: QueueStatus.waiting,
        estimatedWaitMinutes: 10,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      QueueEntry(
        id: 'q_3',
        position: 3,
        customerName: 'Arjun K.',
        service: 'Kids Haircut',
        status: QueueStatus.waiting,
        estimatedWaitMinutes: 20,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      QueueEntry(
        id: 'q_4',
        position: 4,
        customerName: 'You',
        service: 'Haircut',
        status: QueueStatus.waiting,
        estimatedWaitMinutes: 30,
        phone: '+919876543210',
        joinedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ],
  };

  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'n_1',
      title: 'Almost your turn!',
      body:
          'You are #2 in line at QueX Cuts Koramangala. ~10 min wait.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    AppNotification(
      id: 'n_2',
      title: 'Queue joined',
      body: 'You joined the queue at QueX Cuts Koramangala.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
    AppNotification(
      id: 'n_3',
      title: 'Wait time updated',
      body: 'Your estimated wait is now 8 minutes at Luxe Hair Lounge.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  static const UserProfile defaultProfile = UserProfile(
    id: 'user_1',
    name: 'Guest User',
    phone: '+91 98765 43210',
    email: 'guest@quex.app',
  );

  static const AnalyticsSummary defaultAnalytics = AnalyticsSummary(
    totalCustomers: 142,
    avgWaitMinutes: 14.5,
    completedToday: 28,
    noShows: 3,
    peakHour: '12:00 PM',
    weeklyTrend: [18, 22, 25, 30, 28, 35, 32],
  );

  static final List<SubscriptionPlan> subscriptionPlans = [
    const SubscriptionPlan(
      id: 'plan_starter',
      name: 'Starter',
      price: 29,
      features: ['1 location', 'Basic analytics', 'QR check-in'],
      isCurrent: false,
    ),
    const SubscriptionPlan(
      id: 'plan_pro',
      name: 'Pro',
      price: 59,
      features: [
        'Up to 3 locations',
        'Advanced analytics',
        'Staff accounts',
        'Push notifications',
      ],
      isCurrent: true,
    ),
    const SubscriptionPlan(
      id: 'plan_enterprise',
      name: 'Enterprise',
      price: 99,
      features: [
        'Unlimited locations',
        'Priority support',
        'API access',
        'Custom branding',
      ],
      isCurrent: false,
    ),
  ];
}
