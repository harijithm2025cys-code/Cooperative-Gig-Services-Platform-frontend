class ApiConfig {
  static const String baseUrl = 'https://cooperative-gig-services-platform.onrender.com';

  static const bool useLocal = false;
  static const String localBaseUrl = 'http://10.0.2.2:8000';

  static String get activeBaseUrl => useLocal ? localBaseUrl : baseUrl;

  static const String register = '/register';
  static const String authRegister = '/auth/register';
  static const String login = '/login';
  static const String authLogin = '/auth/login';

  static const String availableWorkers = '/workers/available';
  static const String nearbyWorkers = '/workers/nearby';
  static const String workerProfile = '/workers/profile';

  static const String bookings = '/bookings';
  static String householdBookings(String id) => '/bookings/household/$id';
  static String workerBookings(String id) => '/bookings/worker/$id';
  static String bookingDetail(String id) => '/bookings/$id';
  static String updateBookingStatus(String id) => '/bookings/$id/status';

  static const String verifyCheckIn = '/bookings/verify-checkin';
  static const String verifyCheckOut = '/bookings/verify-checkout';
  static const String processPayment = '/bookings/process-payment';
  static const String updateWorkerLocation = '/bookings/worker-location';
  static String getWorkerLocation(String id) => '/bookings/worker-location/$id';

  static const String ratings = '/ratings';
  static const String adminStats = '/admin/stats';

  // Phase 2 Endpoints
  static const String tariffs = '/tariffs';
  static const String bulkBookings = '/bulk-bookings';
  static String assignBulkBooking(String id) => '/bulk-bookings/$id/assign';
  static const String emergencyBooking = '/bookings/emergency';
  static const String workloadFairness = '/admin/workload-fairness';
  static const String emergencyDispatches = '/admin/emergency-dispatches';

  // Phase 3 Endpoints
  static String matchAssign(String bookingId) => '/match/assign/$bookingId';
  static String matchAudit(String bookingId) => '/match/audit/$bookingId';
  static String workerAvailabilityStatus(String workerId) => '/workers/$workerId/availability-status';
  static String workerAssignments(String workerId) => '/workers/$workerId/assignments';
  static String acceptAssignment(String workerId, String asgnId) => '/workers/$workerId/assignments/$asgnId/accept';
  static String rejectAssignment(String workerId, String asgnId) => '/workers/$workerId/assignments/$asgnId/reject';
}

