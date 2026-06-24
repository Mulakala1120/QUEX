import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/domain/entities/entities.dart';

class DummyDataSource {
  static const defaultCity = 'Austin, TX';

  static final List<Business> businesses = [
    const Business(
      id: 'biz_1',
      name: 'QueX Cuts Downtown',
      category: 'Salon',
      address: '123 Main St, Austin, TX 78701',
      distanceMiles: 0.3,
      rating: 4.8,
      waitMinutes: 1,
      queueCount: 4,
      isOpen: true,
      description: 'Walk-ins welcome. Expert stylists, fast service.',
      phone: '(512) 555-0101',
      services: ['Haircut', 'Beard Trim', 'Kids Cut', 'Styling'],
      hours: 'Mon–Sat 9am–7pm',
      latitude: 30.2672,
      longitude: -97.7431,
      landmark: 'Near Congress Ave, downtown',
      closesAt: '8 PM',
    ),
    const Business(
      id: 'biz_2',
      name: 'Bright Smile Dental',
      category: 'Clinic',
      address: '456 Oak Ave, Austin, TX 78702',
      distanceMiles: 0.8,
      rating: 4.6,
      waitMinutes: 16,
      queueCount: 7,
      isOpen: true,
      description: 'Family dentistry with same-day appointments.',
      phone: '(512) 555-0202',
      services: ['Cleaning', 'Checkup', 'Whitening'],
      hours: 'Mon–Fri 8am–6pm',
      latitude: 30.2620,
      longitude: -97.7280,
      landmark: 'East Austin, near Huston-Tillotson',
      closesAt: '6 PM',
    ),
    const Business(
      id: 'biz_3',
      name: 'Luxe Nails & Spa',
      category: 'Salon',
      address: '789 Congress Blvd, Austin, TX 78704',
      distanceMiles: 1.2,
      rating: 4.9,
      waitMinutes: 18,
      queueCount: 3,
      isOpen: true,
      services: ['Manicure', 'Pedicure', 'Gel Nails'],
      hours: 'Tue–Sun 10am–8pm',
      latitude: 30.2500,
      longitude: -97.7500,
      landmark: 'South Congress district',
      closesAt: '8 PM',
    ),
    const Business(
      id: 'biz_4',
      name: 'QuickCare Urgent',
      category: 'Clinic',
      address: '321 Riverside Dr, Austin, TX 78704',
      distanceMiles: 1.5,
      rating: 4.4,
      waitMinutes: 35,
      queueCount: 11,
      isOpen: true,
      services: ['Urgent Visit', 'Lab Work', 'Vaccination'],
      hours: 'Daily 7am–10pm',
      latitude: 30.2450,
      longitude: -97.7350,
      landmark: 'Riverside & Lamar',
      closesAt: '10 PM',
    ),
    const Business(
      id: 'biz_5',
      name: 'Fade Factory',
      category: 'Salon',
      address: '88 6th St, Austin, TX 78701',
      distanceMiles: 2.1,
      rating: 4.7,
      waitMinutes: 0,
      queueCount: 2,
      isOpen: false,
      services: ['Fade', 'Line Up', 'Shave'],
      hours: 'Closed today',
      latitude: 30.2680,
      longitude: -97.7400,
      landmark: '6th Street entertainment district',
      closesAt: 'Closed',
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
        estimatedWaitMinutes: 1,
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
    name: 'Sai Deekshith Mulakala',
    phone: '(940) 758-1793',
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
