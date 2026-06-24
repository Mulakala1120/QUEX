import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/domain/entities/entities.dart';

class DummyDataSource {
  static final List<Business> businesses = [
    const Business(
      id: 'biz_1',
      name: 'QueX Cuts Downtown',
      category: 'Salon',
      address: '123 Main St, Austin, TX',
      distanceMiles: 0.3,
      rating: 4.8,
      waitMinutes: 12,
      queueCount: 4,
      isOpen: true,
      description: 'Walk-ins welcome. Expert stylists, fast service.',
      phone: '+1 (512) 555-0101',
      services: ['Haircut', 'Beard Trim', 'Kids Cut', 'Styling'],
      hours: 'Mon–Sat 9am–7pm',
    ),
    const Business(
      id: 'biz_2',
      name: 'Bright Smile Dental',
      category: 'Clinic',
      address: '456 Oak Ave, Austin, TX',
      distanceMiles: 0.8,
      rating: 4.6,
      waitMinutes: 25,
      queueCount: 7,
      isOpen: true,
      description: 'Family dentistry with same-day appointments.',
      phone: '+1 (512) 555-0202',
      services: ['Cleaning', 'Checkup', 'Whitening'],
      hours: 'Mon–Fri 8am–6pm',
    ),
    const Business(
      id: 'biz_3',
      name: 'Luxe Nails & Spa',
      category: 'Salon',
      address: '789 Congress Blvd, Austin, TX',
      distanceMiles: 1.2,
      rating: 4.9,
      waitMinutes: 18,
      queueCount: 3,
      isOpen: true,
      services: ['Manicure', 'Pedicure', 'Gel Nails'],
      hours: 'Tue–Sun 10am–8pm',
    ),
    const Business(
      id: 'biz_4',
      name: 'QuickCare Urgent',
      category: 'Clinic',
      address: '321 Riverside Dr, Austin, TX',
      distanceMiles: 1.5,
      rating: 4.4,
      waitMinutes: 35,
      queueCount: 11,
      isOpen: true,
      services: ['Urgent Visit', 'Lab Work', 'Vaccination'],
      hours: 'Daily 7am–10pm',
    ),
    const Business(
      id: 'biz_5',
      name: 'Fade Factory',
      category: 'Salon',
      address: '88 6th St, Austin, TX',
      distanceMiles: 2.1,
      rating: 4.7,
      waitMinutes: 8,
      queueCount: 2,
      isOpen: false,
      services: ['Fade', 'Line Up', 'Shave'],
      hours: 'Closed today',
    ),
  ];

  static final Map<String, List<QueueEntry>> queues = {
    'biz_1': [
      QueueEntry(
        id: 'q_1',
        position: 1,
        customerName: 'Alex M.',
        service: 'Haircut',
        status: QueueStatus.serving,
        estimatedWaitMinutes: 0,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 18)),
      ),
      QueueEntry(
        id: 'q_2',
        position: 2,
        customerName: 'Jordan P.',
        service: 'Beard Trim',
        status: QueueStatus.waiting,
        estimatedWaitMinutes: 10,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      QueueEntry(
        id: 'q_3',
        position: 3,
        customerName: 'Sam R.',
        service: 'Kids Cut',
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
        phone: '+15551234567',
        joinedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ],
  };

  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'n_1',
      title: 'Almost your turn!',
      body: 'You are #2 in line at QueX Cuts Downtown. ~10 min wait.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    AppNotification(
      id: 'n_2',
      title: 'Queue joined',
      body: 'You joined the queue at QueX Cuts Downtown.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: true,
    ),
    AppNotification(
      id: 'n_3',
      title: 'Special offer',
      body: '20% off your next visit at Luxe Nails & Spa.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  static const UserProfile defaultProfile = UserProfile(
    id: 'user_1',
    name: 'Guest User',
    phone: '+1 (555) 123-4567',
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
