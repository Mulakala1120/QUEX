import 'package:equatable/equatable.dart';
import 'package:quex/core/constants/app_constants.dart';

class Business extends Equatable {
  const Business({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.distanceMiles,
    required this.rating,
    required this.waitMinutes,
    required this.queueCount,
    required this.isOpen,
    this.imageUrl,
    this.description,
    this.phone,
    this.services = const [],
    this.hours,
    this.latitude = 30.2672,
    this.longitude = -97.7431,
    this.landmark,
    this.closesAt,
  });

  final String id;
  final String name;
  final String category;
  final String address;
  final double distanceMiles;
  final double rating;
  final int waitMinutes;
  final int queueCount;
  final bool isOpen;
  final String? imageUrl;
  final String? description;
  final String? phone;
  final List<String> services;
  final String? hours;
  final double latitude;
  final double longitude;
  final String? landmark;
  final String? closesAt;

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        address,
        distanceMiles,
        rating,
        waitMinutes,
        queueCount,
        isOpen,
      ];
}

class QueueEntry extends Equatable {
  const QueueEntry({
    required this.id,
    required this.position,
    required this.customerName,
    required this.service,
    required this.status,
    required this.estimatedWaitMinutes,
    this.phone,
    this.joinedAt,
  });

  final String id;
  final int position;
  final String customerName;
  final String service;
  final QueueStatus status;
  final int estimatedWaitMinutes;
  final String? phone;
  final DateTime? joinedAt;

  QueueEntry copyWith({
    int? position,
    QueueStatus? status,
    int? estimatedWaitMinutes,
  }) {
    return QueueEntry(
      id: id,
      position: position ?? this.position,
      customerName: customerName,
      service: service,
      status: status ?? this.status,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      phone: phone,
      joinedAt: joinedAt,
    );
  }

  @override
  List<Object?> get props => [id, position, customerName, service, status];
}

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  @override
  List<Object?> get props => [id, title, body, createdAt, isRead];
}

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;

  @override
  List<Object?> get props => [id, name, phone, email];
}

class AnalyticsSummary extends Equatable {
  const AnalyticsSummary({
    required this.totalCustomers,
    required this.avgWaitMinutes,
    required this.completedToday,
    required this.noShows,
    required this.peakHour,
    required this.weeklyTrend,
  });

  final int totalCustomers;
  final double avgWaitMinutes;
  final int completedToday;
  final int noShows;
  final String peakHour;
  final List<int> weeklyTrend;

  @override
  List<Object?> get props =>
      [totalCustomers, avgWaitMinutes, completedToday, noShows];
}

class SubscriptionPlan extends Equatable {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.features,
    required this.isCurrent,
  });

  final String id;
  final String name;
  final double price;
  final List<String> features;
  final bool isCurrent;

  @override
  List<Object?> get props => [id, name, price, isCurrent];
}
