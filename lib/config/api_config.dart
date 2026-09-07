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

  // Phase 4 Endpoints
  static String cancelBooking(String id) => '/bookings/$id/cancel';
  static String assignmentLocation(String asgnId) => '/bookings/assignments/$asgnId/location';
  static String workerStartJourney(String workerId, String asgnId) => '/workers/$workerId/assignments/$asgnId/start-journey';
  static String workerArrive(String workerId, String asgnId) => '/workers/$workerId/assignments/$asgnId/arrive';
  static String workerStartService(String workerId, String asgnId) => '/workers/$workerId/assignments/$asgnId/start-service';
  static String workerCompleteService(String workerId, String asgnId) => '/workers/$workerId/assignments/$asgnId/complete-service';
  static const String notifications = '/notifications/';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static String notificationMarkRead(String id) => '/notifications/$id/read';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';

  // Phase 5 Endpoints
  static const String createPaymentOrder = '/payments/create-order';
  static const String verifyPayment = '/payments/verify';
  static String paymentDetail(String id) => '/payments/$id';
  static String refundPayment(String id) => '/payments/$id/refund';

  static String invoiceByBooking(String bookingId) => '/invoices/booking/$bookingId';
  static String invoiceDetail(String id) => '/invoices/$id';
  static String invoiceDownload(String id) => '/invoices/$id/download';

  static String bookingCompletionOtp(String bookingId) => '/bookings/$bookingId/completion-otp';
  static String workerVerifyCompletionOtp(String workerId) => '/workers/$workerId/verify-completion-otp';

  static const String complaints = '/complaints/';
  static String cooperativeComplaints(String coopId) => '/complaints/cooperative/$coopId';
  static String resolveComplaint(String id) => '/complaints/$id/resolve';
}

