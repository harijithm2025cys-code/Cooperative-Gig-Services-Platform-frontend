import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/worker.dart';
import '../models/booking.dart';
import '../models/admin_stats.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _inMemoryToken;

  static const String _tokenKey = 'jwt_auth_token';
  static const String _userKey = 'cached_user_profile';

  User? currentUser = const User(
    id: 'usr_house_01',
    name: 'Ananya Sharma',
    phone: '+91 98765 12345',
    email: 'ananya@example.com',
    role: UserRole.household,
    address: 'Flat 402, Green Glen Layout, Bellandur, Bengaluru',
  );

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.activeBaseUrl,
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 6),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Attach JWT Bearer Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  // Token management
  Future<String?> getToken() async {
    if (_inMemoryToken != null) return _inMemoryToken;
    try {
      _inMemoryToken = await _storage.read(key: _tokenKey);
      return _inMemoryToken;
    } catch (_) {
      return _inMemoryToken;
    }
  }

  Future<void> saveToken(String token) async {
    _inMemoryToken = token;
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {}
  }

  Future<void> clearAuth() async {
    _inMemoryToken = null;
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    } catch (_) {}
  }

  // Mock State Storage
  // Mock State Storage with Rich Specialists Roster
  final List<Worker> _mockWorkers = [
    // --- Cleaners ---
    const Worker(
      id: 'wrk_3',
      name: 'Lakshmi Devi',
      skill: 'Cleaner',
      rating: 4.98,
      reviewsCount: 220,
      distanceKm: 0.9,
      latitude: 12.9740,
      longitude: 77.5910,
      isVerified: true,
      hourlyRate: 250.0,
      phone: '+91 98450 33445',
      cooperativeName: 'Mahila Shramik Swavalambi Co-op',
      completedJobs: 330,
      bio: 'Deep sanitization, kitchen deep clean, and home organization expert.',
    ),
    const Worker(
      id: 'wrk_3b',
      name: 'Anandi Soundarajan',
      skill: 'Cleaner',
      rating: 4.92,
      reviewsCount: 178,
      distanceKm: 1.4,
      latitude: 12.9710,
      longitude: 77.5930,
      isVerified: true,
      hourlyRate: 250.0,
      phone: '+91 98450 33446',
      cooperativeName: 'Chennai Labour Cooperative Society',
      completedJobs: 215,
      bio: 'Eco-friendly chemical-free home cleaning and floor scrubbing specialist.',
    ),
    const Worker(
      id: 'wrk_3c',
      name: 'Meena Kumari',
      skill: 'Cleaner',
      rating: 4.89,
      reviewsCount: 145,
      distanceKm: 2.3,
      latitude: 12.9690,
      longitude: 77.5960,
      isVerified: true,
      hourlyRate: 220.0,
      phone: '+91 98450 33447',
      cooperativeName: 'Mahila Shramik Swavalambi Co-op',
      completedJobs: 190,
      bio: 'Post-renovation cleanup, sofa shampooing, and window glass detailing.',
    ),
    const Worker(
      id: 'wrk_3d',
      name: 'Kavitha Raman',
      skill: 'Cleaner',
      rating: 4.95,
      reviewsCount: 310,
      distanceKm: 2.8,
      latitude: 12.9760,
      longitude: 77.5890,
      isVerified: true,
      hourlyRate: 260.0,
      phone: '+91 98450 33448',
      cooperativeName: 'Bengaluru Central Labour Guild',
      completedJobs: 420,
      bio: 'Senior hygiene auditor and full-villa deep sanitization expert.',
    ),

    // --- Electricians ---
    const Worker(
      id: 'wrk_1',
      name: 'Ramesh Kumar',
      skill: 'Electrician',
      rating: 4.95,
      reviewsCount: 142,
      distanceKm: 1.2,
      latitude: 12.9720,
      longitude: 77.5950,
      isVerified: true,
      hourlyRate: 350.0,
      phone: '+91 98450 11223',
      cooperativeName: 'Bengaluru Electrical Workers Co-op',
      completedJobs: 240,
      bio: 'Master Electrician with 10+ years experience in MCB wiring, UPS setup, earthing & diagnostics.',
    ),
    const Worker(
      id: 'wrk_1b',
      name: 'Manoj Sharma',
      skill: 'Electrician',
      rating: 4.88,
      reviewsCount: 110,
      distanceKm: 1.9,
      latitude: 12.9700,
      longitude: 77.5920,
      isVerified: true,
      hourlyRate: 320.0,
      phone: '+91 98450 11224',
      cooperativeName: 'Chennai Labour Cooperative Society',
      completedJobs: 165,
      bio: 'Specialist in smart home lighting, EV charger installation, and short-circuit repair.',
    ),
    const Worker(
      id: 'wrk_1c',
      name: 'Harish Venkatesh',
      skill: 'Electrician',
      rating: 4.91,
      reviewsCount: 195,
      distanceKm: 2.6,
      latitude: 12.9750,
      longitude: 77.5980,
      isVerified: true,
      hourlyRate: 350.0,
      phone: '+91 98450 11225',
      cooperativeName: 'Tamil Nadu Skilled Workers Cooperative',
      completedJobs: 280,
      bio: 'Heavy appliance load calculation, generator switchboard wiring, and industrial safety.',
    ),

    // --- Plumbers ---
    const Worker(
      id: 'wrk_2',
      name: 'Suresh Patil',
      skill: 'Plumber',
      rating: 4.88,
      reviewsCount: 96,
      distanceKm: 2.1,
      latitude: 12.9680,
      longitude: 77.5990,
      isVerified: true,
      hourlyRate: 300.0,
      phone: '+91 98450 22334',
      cooperativeName: 'Metro Plumbers & Fitters Cooperative',
      completedJobs: 180,
      bio: 'Certified plumber specializing in pipeline leak repairs, bathroom fittings & geysers.',
    ),
    const Worker(
      id: 'wrk_2b',
      name: 'Vijay Anand',
      skill: 'Plumber',
      rating: 4.94,
      reviewsCount: 160,
      distanceKm: 1.5,
      latitude: 12.9730,
      longitude: 77.5940,
      isVerified: true,
      hourlyRate: 320.0,
      phone: '+91 98450 22335',
      cooperativeName: 'Chennai South Cooperative',
      completedJobs: 290,
      bio: 'Motor pump setup, overhead tank pipe fitting, and high-pressure block removal.',
    ),
    const Worker(
      id: 'wrk_2c',
      name: 'Dinesh Kumar',
      skill: 'Plumber',
      rating: 4.85,
      reviewsCount: 88,
      distanceKm: 3.1,
      latitude: 12.9650,
      longitude: 77.5970,
      isVerified: true,
      hourlyRate: 280.0,
      phone: '+91 98450 22336',
      cooperativeName: 'Metro Plumbers & Fitters Cooperative',
      completedJobs: 135,
      bio: 'Emergency drain unclogging and modern sanitary ware installation.',
    ),

    // --- Caregivers ---
    const Worker(
      id: 'wrk_4',
      name: 'Sister Mary Joseph',
      skill: 'Caregiver',
      rating: 4.96,
      reviewsCount: 165,
      distanceKm: 1.8,
      latitude: 12.9650,
      longitude: 77.5930,
      isVerified: true,
      hourlyRate: 350.0,
      phone: '+91 98450 55667',
      cooperativeName: 'Compassion Care Workers Guild',
      completedJobs: 410,
      bio: 'Certified geriatric caregiver and nursing assistant with first-aid & CPR credentials.',
    ),
    const Worker(
      id: 'wrk_4b',
      name: 'Geetha Natarajan',
      skill: 'Caregiver',
      rating: 4.98,
      reviewsCount: 205,
      distanceKm: 2.2,
      latitude: 12.9670,
      longitude: 77.5910,
      isVerified: true,
      hourlyRate: 340.0,
      phone: '+91 98450 55668',
      cooperativeName: 'Mahila Shramik Swavalambi Co-op',
      completedJobs: 350,
      bio: 'Post-surgery recovery assistance, medication management, and patient companionship.',
    ),

    // --- Carpenters / Home Repair ---
    const Worker(
      id: 'wrk_5',
      name: 'Rajesh Naidu',
      skill: 'Carpenter',
      rating: 4.84,
      reviewsCount: 84,
      distanceKm: 3.2,
      latitude: 12.9790,
      longitude: 77.6010,
      isVerified: true,
      hourlyRate: 400.0,
      phone: '+91 98450 44556',
      cooperativeName: 'South Zone Woodcraft Cooperative',
      completedJobs: 155,
      bio: 'Custom woodwork, hinge alignment, furniture assembly, and modular repair.',
    ),
    const Worker(
      id: 'wrk_5b',
      name: 'Anand Raj',
      skill: 'Carpenter',
      rating: 4.90,
      reviewsCount: 125,
      distanceKm: 1.7,
      latitude: 12.9735,
      longitude: 77.5955,
      isVerified: true,
      hourlyRate: 380.0,
      phone: '+91 98450 44557',
      cooperativeName: 'Tamil Nadu Skilled Workers Cooperative',
      completedJobs: 210,
      bio: 'Modular kitchen repair, wooden door frame adjustments, and lock replacements.',
    ),

    // --- Gardeners & Drivers ---
    const Worker(
      id: 'wrk_6',
      name: 'Murugan Gounder',
      skill: 'Gardener',
      rating: 4.92,
      reviewsCount: 95,
      distanceKm: 1.1,
      latitude: 12.9715,
      longitude: 77.5925,
      isVerified: true,
      hourlyRate: 200.0,
      phone: '+91 98450 66778',
      cooperativeName: 'Salem Construction & Allied Services Society',
      completedJobs: 175,
      bio: 'Lawn mowing, organic pest control, terrace garden curation, and plant trimming.',
    ),
    const Worker(
      id: 'wrk_7',
      name: 'Praveen Krishnan',
      skill: 'Driver',
      rating: 4.97,
      reviewsCount: 280,
      distanceKm: 0.8,
      latitude: 12.9725,
      longitude: 77.5965,
      isVerified: true,
      hourlyRate: 250.0,
      phone: '+91 98450 77889',
      cooperativeName: 'Chennai Labour Cooperative Society',
      completedJobs: 520,
      bio: 'Commercial & automatic vehicle specialist with 12+ years accident-free driving record.',
    ),
  ];

  final List<Booking> _mockBookings = [
    Booking(
      id: 'SC10245',
      workerId: 'wrk_1',
      workerName: 'Harijith M',
      workerSkill: 'AC Technician',
      workerPhone: '+91 98450 11223',
      workerCoop: 'Independent Skilled Worker',
      householdId: 'usr_house_01',
      householdName: 'Dhanabalan R',
      householdPhone: '+91 98765 12345',
      serviceAddress: '123, 4th Cross, Koramangala 5th Block, Bengaluru',
      latitude: 12.9352,
      longitude: 77.6245,
      status: BookingStatus.requested,
      amount: 350.0,
      scheduledDate: 'Today, 02 Sep 2026',
      scheduledTime: '10:00 AM - 11:00 AM',
      notes: 'Cooling coil inspection and gas pressure check.',
      createdAt: DateTime.now(),
    ),
    Booking(
      id: 'SC10246',
      workerId: 'wrk_1',
      workerName: 'Harijith M',
      workerSkill: 'AC Specialist',
      workerPhone: '+91 98450 11223',
      workerCoop: 'Tamil Nadu Skilled Workers Cooperative',
      householdId: 'usr_house_02',
      householdName: 'Ajaipravin S',
      householdPhone: '+91 98765 54321',
      serviceAddress: '88, 100 Feet Rd, Indiranagar, Bengaluru',
      latitude: 12.9716,
      longitude: 77.5946,
      status: BookingStatus.requested,
      amount: 420.0,
      scheduledDate: 'Today, 02 Sep 2026',
      scheduledTime: '02:30 PM - 03:30 PM',
      notes: 'Deep jet foam cleaning and indoor unit drain pipe replacement.',
      createdAt: DateTime.now(),
    ),
    Booking(
      id: 'BK-8901',
      workerId: 'wrk_1',
      workerName: 'Harijith M',
      workerSkill: 'Electrician',
      workerPhone: '+91 98450 11223',
      workerCoop: 'Bengaluru Electrical Workers Co-op',
      householdId: 'usr_house_01',
      householdName: 'Dhanabalan R',
      householdPhone: '+91 98765 12345',
      serviceAddress: 'Flat 402, Green Glen Layout, Bellandur, Bengaluru',
      latitude: 12.9716,
      longitude: 77.5946,
      status: BookingStatus.accepted,
      amount: 700.0,
      scheduledDate: 'Today',
      scheduledTime: '11:00 AM',
      notes: 'Replace main MCB switch and check socket earthing.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Booking(
      id: 'BK-8822',
      workerId: 'wrk_3',
      workerName: 'Lakshmi Devi',
      workerSkill: 'Cleaner',
      workerPhone: '+91 98450 33445',
      workerCoop: 'Mahila Shramik Swavalambi Co-op',
      householdId: 'usr_house_01',
      householdName: 'Ananya Sharma',
      householdPhone: '+91 98765 12345',
      serviceAddress: 'Flat 402, Green Glen Layout, Bellandur, Bengaluru',
      latitude: 12.9716,
      longitude: 77.5946,
      status: BookingStatus.completed,
      amount: 750.0,
      scheduledDate: 'Yesterday',
      scheduledTime: '02:00 PM',
      notes: 'Full house eco deep cleaning.',
      rating: 5.0,
      review: 'Exceptional work and very polite worker-owner!',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // 1. POST /auth/register or /register
  Future<User> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final payload = {
      'name': name,
      'phone': phone,
      'email': email.isNotEmpty ? email : null,
      'password': password,
      'role': role.name,
    };

    try {
      final response = await _dio.post(ApiConfig.register, data: payload);
      final data = response.data is Map ? response.data : jsonDecode(response.data);
      final token = data['token'] ?? data['access_token'] ?? 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      await saveToken(token.toString());
      final user = User.fromJson(data['user'] ?? data, token: token.toString());
      currentUser = user;
      if (role == UserRole.worker) {
        _mockWorkers.insert(0, Worker(
          id: user.id,
          name: name,
          skill: 'General Specialist',
          rating: 5.0,
          reviewsCount: 1,
          distanceKm: 0.8,
          isVerified: true,
          phone: phone,
          cooperativeName: 'Bengaluru Labour Guild Co-op',
        ));
      }
      return user;
    } catch (_) {
      final dummyToken = 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      await saveToken(dummyToken);
      final user = User(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        phone: phone,
        email: email,
        role: role,
        token: dummyToken,
        cooperativeName: role == UserRole.worker ? 'Bengaluru Labour Guild Co-op' : null,
      );
      currentUser = user;
      if (role == UserRole.worker) {
        _mockWorkers.insert(0, Worker(
          id: user.id,
          name: name,
          skill: 'Electrician & Technician',
          rating: 5.0,
          reviewsCount: 0,
          distanceKm: 0.5,
          isVerified: true,
          phone: phone,
          cooperativeName: 'Bengaluru Labour Guild Co-op',
        ));
      }
      return user;
    }
  }

  // 2. POST /auth/login or /login
  Future<User> login({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    final payload = {
      'email': username,
      'phone': username,
      'username': username,
      'password': password,
      'role': role.name,
    };

    try {
      final response = await _dio.post(ApiConfig.login, data: payload);
      final data = response.data is Map ? response.data : jsonDecode(response.data);
      final token = data['token'] ?? data['access_token'] ?? 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      await saveToken(token.toString());
      final user = User.fromJson(data['user'] ?? data, token: token.toString());
      currentUser = user;
      return user;
    } catch (_) {
      final dummyToken = 'jwt_token_demo_user';
      await saveToken(dummyToken);
      if (role == UserRole.worker) {
        currentUser = const User(
          id: 'wrk_1',
          name: 'Ramesh Kumar (Worker-Owner)',
          phone: '+91 98450 11223',
          email: 'ramesh.worker@coop.org',
          role: UserRole.worker,
          cooperativeName: 'Bengaluru Electrical Workers Co-op',
          address: 'Jayanagar 4th Block, Bengaluru',
          token: 'jwt_token_demo_worker',
        );
      } else if (role == UserRole.admin) {
        currentUser = const User(
          id: 'adm_01',
          name: 'Priya Sundaram (Admin)',
          phone: '+91 98450 99999',
          email: 'admin@coop.org',
          role: UserRole.admin,
          cooperativeName: 'Bengaluru District Labour Cooperative Union',
          token: 'jwt_token_demo_admin',
        );
      } else {
        currentUser = const User(
          id: 'usr_house_01',
          name: 'Ananya Sharma',
          phone: '+91 98765 12345',
          email: 'ananya@example.com',
          role: UserRole.household,
          address: 'Flat 402, Green Glen Layout, Bellandur, Bengaluru',
          token: 'jwt_token_demo_household',
        );
      }
      return currentUser!;
    }
  }

  // 3. GET /workers/available
  Future<List<Worker>> getAvailableWorkers({
    String? skill,
    double lat = 12.9716,
    double lng = 77.5946,
    double radius = 5.0,
  }) async {
    Map<String, dynamic> queryParams = {
      'lat': lat,
      'lng': lng,
      'radius': radius,
    };
    if (skill != null && skill.isNotEmpty && skill.toLowerCase() != 'all') {
      queryParams['skill'] = skill.toLowerCase();
    }

    try {
      final response = await _dio.get(
        ApiConfig.availableWorkers,
        queryParameters: queryParams,
      );
      final dynamic data = response.data;
      final List<dynamic> list = data is List ? data : (data['workers'] ?? data['data'] ?? []);
      if (list.isNotEmpty) {
        return list.map((w) => Worker.fromJson(w as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    var workers = List<Worker>.from(_mockWorkers);
    if (skill != null && skill.isNotEmpty && skill.toLowerCase() != 'all') {
      final s = skill.toLowerCase();
      final filtered = workers.where((w) => w.skill.toLowerCase().contains(s) || s.contains(w.skill.toLowerCase())).toList();
      if (filtered.isNotEmpty) return filtered;
    }
    return workers;
  }

  // Alias for getAvailableWorkers
  Future<List<Worker>> getNearbyWorkers({
    double lat = 12.9716,
    double lng = 77.5946,
    double radiusKm = 5.0,
    String? skill,
  }) => getAvailableWorkers(skill: skill, lat: lat, lng: lng, radius: radiusKm);

  // 4. POST /bookings/
  Future<Booking> createBooking({
    required String householdId,
    required String workerId,
    required String workerName,
    required String workerSkill,
    required String workerPhone,
    required String serviceAddress,
    required double amount,
    required String scheduledDate,
    required String scheduledTime,
    String notes = '',
    double lat = 12.9716,
    double lng = 77.5946,
  }) async {
    final payload = {
      'household_id': householdId,
      'service_id': workerSkill.toLowerCase(),
      'latitude': lat,
      'longitude': lng,
      'address': serviceAddress,
      'notes': notes,
    };

    try {
      final response = await _dio.post(ApiConfig.bookings, data: payload);
      final data = response.data;
      final created = Booking.fromJson(data['booking'] ?? data);
      _mockBookings.insert(0, created);
      return created;
    } catch (_) {
      final newBooking = Booking(
        id: 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        workerId: workerId,
        workerName: workerName,
        workerSkill: workerSkill,
        workerPhone: workerPhone,
        householdId: householdId,
        householdName: 'Ananya Sharma',
        householdPhone: '+91 98765 12345',
        serviceAddress: serviceAddress,
        latitude: lat,
        longitude: lng,
        status: BookingStatus.requested,
        amount: amount,
        scheduledDate: scheduledDate,
        scheduledTime: scheduledTime,
        notes: notes,
        createdAt: DateTime.now(),
      );
      _mockBookings.insert(0, newBooking);
      return newBooking;
    }
  }

  // 5. GET /bookings
  Future<List<Booking>> getBookings() async => List<Booking>.from(_mockBookings);

  Future<List<Booking>> getHouseholdBookings(String householdId) async {
    try {
      final response = await _dio.get(ApiConfig.householdBookings(householdId));
      final dynamic data = response.data;
      final List<dynamic> list = data is List ? data : (data['bookings'] ?? data['data'] ?? []);
      if (list.isNotEmpty) {
        return list.map((b) => Booking.fromJson(b as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return List<Booking>.from(_mockBookings);
  }

  // 6. GET /bookings/worker/{id}
  Future<List<Booking>> getWorkerBookings(String workerId) async {
    try {
      final response = await _dio.get(ApiConfig.workerBookings(workerId));
      final dynamic data = response.data;
      final List<dynamic> list = data is List ? data : (data['bookings'] ?? data['data'] ?? []);
      if (list.isNotEmpty) {
        return list.map((b) => Booking.fromJson(b as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return List<Booking>.from(_mockBookings);
  }

  // 7. PUT /bookings/{id}/status
  Future<Booking> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      final response = await _dio.put(
        ApiConfig.updateBookingStatus(bookingId),
        data: {'status': status.key},
      );
      final data = response.data;
      final updated = Booking.fromJson(data['booking'] ?? data);
      final idx = _mockBookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) _mockBookings[idx] = updated;
      return updated;
    } catch (_) {
      final idx = _mockBookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        DateTime? checkIn = _mockBookings[idx].checkInTime;
        DateTime? checkOut = _mockBookings[idx].checkOutTime;
        if (status == BookingStatus.inProgress && checkIn == null) {
          checkIn = DateTime.now();
        } else if (status == BookingStatus.completed && checkOut == null) {
          checkOut = DateTime.now();
        }
        final updated = _mockBookings[idx].copyWith(
          status: status,
          checkInTime: checkIn,
          checkOutTime: checkOut,
        );
        _mockBookings[idx] = updated;
        return updated;
      }
      throw Exception('Booking not found');
    }
  }

  // 8. POST /ratings/
  Future<bool> submitRating({
    required String bookingId,
    required double rating,
    required String review,
  }) async {
    try {
      await _dio.post(
        ApiConfig.ratings,
        data: {
          'booking_id': bookingId,
          'rating': rating,
          'review': review,
        },
      );
    } catch (_) {}

    final idx = _mockBookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _mockBookings[idx] = _mockBookings[idx].copyWith(
        rating: rating,
        review: review,
      );
    }
    return true;
  }

  // 9. GET /admin/stats
  Future<AdminStats> getAdminStats() async {
    try {
      final response = await _dio.get(ApiConfig.adminStats);
      final data = response.data;
      return AdminStats.fromJson(data is Map<String, dynamic> ? data : {});
    } catch (_) {
      return const AdminStats();
    }
  }

  // 10. POST /bookings/verify-checkin
  Future<Map<String, dynamic>> verifyCheckIn({
    required String bookingId,
    required String verifierRole,
    required String method,
    String? otpCode,
    double? workerLat,
    double? workerLng,
    double? householdLat,
    double? householdLng,
    double maxDistanceMeters = 100.0,
  }) async {
    final payload = {
      'booking_id': bookingId,
      'verifier_role': verifierRole,
      'method': method,
      'max_distance_meters': maxDistanceMeters,
    };
    if (otpCode != null) payload['otp_code'] = otpCode;
    if (workerLat != null) payload['worker_latitude'] = workerLat;
    if (workerLng != null) payload['worker_longitude'] = workerLng;
    if (householdLat != null) payload['household_latitude'] = householdLat;
    if (householdLng != null) payload['household_longitude'] = householdLng;

    try {
      final res = await _dio.post(ApiConfig.verifyCheckIn, data: payload);
      final data = res.data is Map ? res.data : {'success': true};
      _updateMockBookingVerification(
        bookingId: bookingId,
        verifierRole: verifierRole,
        isCheckin: true,
      );
      return data is Map ? Map<String, dynamic>.from(data) : {'success': true};
    } catch (e) {
      debugPrint('verifyCheckIn API failed — applying optimistic local update: $e');
      _updateMockBookingVerification(
        bookingId: bookingId,
        verifierRole: verifierRole,
        isCheckin: true,
      );
      final b = _mockBookings.firstWhere(
        (b) => b.id == bookingId,
        orElse: () => _mockBookings.first,
      );
      return {
        'success': true,
        'booking_id': bookingId,
        'verified_role': verifierRole,
        'method': method,
        'both_verified': b.bothVerifiedCheckin,
        'message': '✅ $verifierRole locally verified check-in.',
      };
    }
  }

  // 11. POST /bookings/verify-checkout
  Future<Map<String, dynamic>> verifyCheckOut({
    required String bookingId,
    required String verifierRole,
    required String method,
    String? otpCode,
  }) async {
    final payload = {
      'booking_id': bookingId,
      'verifier_role': verifierRole,
      'method': method,
    };
    if (otpCode != null) payload['otp_code'] = otpCode;

    try {
      final res = await _dio.post(ApiConfig.verifyCheckOut, data: payload);
      final data = res.data is Map ? res.data : {'success': true};
      _updateMockBookingVerification(
        bookingId: bookingId,
        verifierRole: verifierRole,
        isCheckin: false,
      );
      return data is Map ? Map<String, dynamic>.from(data) : {'success': true};
    } catch (e) {
      debugPrint('verifyCheckOut API failed — applying optimistic local update: $e');
      _updateMockBookingVerification(
        bookingId: bookingId,
        verifierRole: verifierRole,
        isCheckin: false,
      );
      final b = _mockBookings.firstWhere(
        (b) => b.id == bookingId,
        orElse: () => _mockBookings.first,
      );
      return {
        'success': true,
        'booking_id': bookingId,
        'verified_role': verifierRole,
        'method': method,
        'both_verified': b.bothVerifiedCheckout,
        'message': '✅ $verifierRole locally verified checkout.',
      };
    }
  }

  void _updateMockBookingVerification({
    required String bookingId,
    required String verifierRole,
    required bool isCheckin,
  }) {
    final idx = _mockBookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return;
    final now = DateTime.now();
    final old = _mockBookings[idx];
    Booking updated;
    if (isCheckin) {
      updated = old.copyWith(
        householdVerifiedCheckin: verifierRole == 'household' ? true : old.householdVerifiedCheckin,
        workerVerifiedCheckin: verifierRole == 'worker' ? true : old.workerVerifiedCheckin,
        householdCheckinTime: verifierRole == 'household' ? now : old.householdCheckinTime,
        workerCheckinTime: verifierRole == 'worker' ? now : old.workerCheckinTime,
      );
      if (updated.bothVerifiedCheckin) {
        updated = updated.copyWith(
          status: BookingStatus.verifiedCheckin,
          checkInTime: now,
        );
      }
    } else {
      updated = old.copyWith(
        householdVerifiedCheckout: verifierRole == 'household' ? true : old.householdVerifiedCheckout,
        workerVerifiedCheckout: verifierRole == 'worker' ? true : old.workerVerifiedCheckout,
        householdCheckoutTime: verifierRole == 'household' ? now : old.householdCheckoutTime,
        workerCheckoutTime: verifierRole == 'worker' ? now : old.workerCheckoutTime,
      );
      if (updated.bothVerifiedCheckout) {
        updated = updated.copyWith(
          status: BookingStatus.completed,
          checkOutTime: now,
        );
      }
    }
    _mockBookings[idx] = updated;
  }

  // 12. POST /bookings/process-payment
  Future<Map<String, dynamic>> processPayment({
    required String bookingId,
    required double amount,
    required String paymentMethod,
    bool releaseAfterVerification = true,
  }) async {
    final payload = {
      'booking_id': bookingId,
      'amount': amount,
      'payment_method': paymentMethod,
      'release_after_verification': releaseAfterVerification,
    };

    try {
      final res = await _dio.post(ApiConfig.processPayment, data: payload);
      final data = res.data is Map ? res.data : {'success': true};
      final idx = _mockBookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        _mockBookings[idx] = _mockBookings[idx].copyWith(
          finalAmount: amount,
          paymentStatus: releaseAfterVerification ? PaymentStatus.heldInEscrow : PaymentStatus.released,
          status: releaseAfterVerification ? _mockBookings[idx].status : BookingStatus.paymentReleased,
        );
      }
      return data is Map ? Map<String, dynamic>.from(data) : {'success': true};
    } catch (e) {
      debugPrint('processPayment API failed — optimistic update: $e');
      final idx = _mockBookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        _mockBookings[idx] = _mockBookings[idx].copyWith(
          finalAmount: amount,
          paymentStatus: PaymentStatus.heldInEscrow,
        );
      }
      return {
        'success': true,
        'booking_id': bookingId,
        'transaction_id': 'TXN-LOCAL${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'status': releaseAfterVerification ? 'held_in_escrow' : 'released',
        'message': '💰 Payment held securely in Cooperative Escrow.',
      };
    }
  }

  // 13. POST /bookings/worker-location
  Future<Map<String, dynamic>> updateWorkerLocation({
    required String workerId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
    String? bookingId,
  }) async {
    final payload = {
      'worker_id': workerId,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (heading != null) payload['heading'] = heading;
    if (speedKmh != null) payload['speed_kmh'] = speedKmh;
    if (bookingId != null) payload['booking_id'] = bookingId;

    try {
      final res = await _dio.post(ApiConfig.updateWorkerLocation, data: payload);
      final data = res.data is Map ? res.data : {'success': true};
      return data is Map ? Map<String, dynamic>.from(data) : {'success': true};
    } catch (e) {
      debugPrint('updateWorkerLocation API failed (non-fatal): $e');
      return {
        'success': true,
        'worker_id': workerId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Local GPS logged.',
      };
    }
  }

  // 14. GET /bookings/worker-location/{workerId}
  Future<Map<String, dynamic>?> getWorkerLiveLocation(String workerId) async {
    try {
      final res = await _dio.get(ApiConfig.getWorkerLocation(workerId));
      final data = res.data is Map ? res.data : null;
      return data is Map ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      debugPrint('getWorkerLiveLocation API failed: $e');
      return null;
    }
  }
}
