import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Cooperative Gig Services';
  static const String appTagline = 'Trusted Cooperative Services';
  static const String baseUrl = 'https://cooperative-gig-services-platform.onrender.com';

  static const List<ServiceCategory> categories = [
    ServiceCategory(
      id: 'electrical',
      title: 'Electrical',
      skillParam: 'electrician',
      icon: Icons.electrical_services,
      color: Color(0xFFEAB308),
    ),
    ServiceCategory(
      id: 'plumbing',
      title: 'Plumbing',
      skillParam: 'plumber',
      icon: Icons.plumbing,
      color: Color(0xFF0284C7),
    ),
    ServiceCategory(
      id: 'cleaning',
      title: 'Cleaning',
      skillParam: 'cleaner',
      icon: Icons.cleaning_services,
      color: Color(0xFF10B981),
    ),
    ServiceCategory(
      id: 'carpentry',
      title: 'Home Repair',
      skillParam: 'carpenter',
      icon: Icons.home_repair_service,
      color: Color(0xFFD97706),
    ),
    ServiceCategory(
      id: 'caregiver',
      title: 'Caregiving',
      skillParam: 'caregiver',
      icon: Icons.health_and_safety,
      color: Color(0xFFEC4899),
    ),
    ServiceCategory(
      id: 'driver',
      title: 'Driver',
      skillParam: 'driver',
      icon: Icons.directions_car,
      color: Color(0xFF6366F1),
    ),
    ServiceCategory(
      id: 'gardening',
      title: 'Gardening',
      skillParam: 'gardener',
      icon: Icons.yard,
      color: Color(0xFF16A34A),
    ),
    ServiceCategory(
      id: 'sanitization',
      title: 'Deep Clean',
      skillParam: 'cleaner',
      icon: Icons.cleaning_services,
      color: Color(0xFF0D9488),
    ),
  ];
}

class ServiceCategory {
  final String id;
  final String title;
  final String skillParam;
  final IconData icon;
  final Color color;

  const ServiceCategory({
    required this.id,
    required this.title,
    required this.skillParam,
    required this.icon,
    required this.color,
  });
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String accountType = '/account_type';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String householdHome = '/household_home';
  static const String workerSearch = '/worker_search';
  static const String bookingConfirm = '/booking_confirm';
  static const String bookingStatus = '/booking_status';
  static const String workerHome = '/worker_home';
  static const String workerProfile = '/worker_profile';
}
