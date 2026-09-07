enum BookingStatus {
  requested,
  accepted,
  rejected,
  workerEnroute,
  arrived,
  verifiedCheckin,
  paymentPending,
  paymentReleased,
  inProgress,
  verifiedCheckout,
  completed,
  cancelled;

  String get key {
    switch (this) {
      case BookingStatus.requested:
        return 'requested';
      case BookingStatus.accepted:
        return 'accepted';
      case BookingStatus.rejected:
        return 'rejected';
      case BookingStatus.workerEnroute:
        return 'worker_enroute';
      case BookingStatus.arrived:
        return 'arrived';
      case BookingStatus.verifiedCheckin:
        return 'verified_checkin';
      case BookingStatus.paymentPending:
        return 'payment_pending';
      case BookingStatus.paymentReleased:
        return 'payment_released';
      case BookingStatus.inProgress:
        return 'in_progress';
      case BookingStatus.verifiedCheckout:
        return 'verified_checkout';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case BookingStatus.requested:
        return 'Request Sent';
      case BookingStatus.accepted:
        return 'Accepted by Worker';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.workerEnroute:
        return 'Worker En Route';
      case BookingStatus.arrived:
        return 'Worker Arrived';
      case BookingStatus.verifiedCheckin:
        return 'Check-In Verified';
      case BookingStatus.paymentPending:
        return 'Awaiting Payment';
      case BookingStatus.paymentReleased:
        return 'Payment Released';
      case BookingStatus.inProgress:
        return 'Service In Progress';
      case BookingStatus.verifiedCheckout:
        return 'Check-Out Verified';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case BookingStatus.requested:
        return 0;
      case BookingStatus.accepted:
      case BookingStatus.workerEnroute:
      case BookingStatus.arrived:
        return 1;
      case BookingStatus.verifiedCheckin:
      case BookingStatus.paymentPending:
      case BookingStatus.paymentReleased:
        return 2;
      case BookingStatus.inProgress:
        return 3;
      case BookingStatus.verifiedCheckout:
      case BookingStatus.completed:
        return 4;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return -1;
    }
  }

  static BookingStatus fromString(String? val) {
    switch (val?.toLowerCase().replaceAll(' ', '_')) {
      case 'requested':
      case 'request':
        return BookingStatus.requested;
      case 'accepted':
      case 'confirmed':
        return BookingStatus.accepted;
      case 'rejected':
      case 'declined':
        return BookingStatus.rejected;
      case 'worker_enroute':
      case 'enroute':
      case 'traveling':
        return BookingStatus.workerEnroute;
      case 'arrived':
        return BookingStatus.arrived;
      case 'verified_checkin':
      case 'checkin_verified':
      case 'dual_verified':
        return BookingStatus.verifiedCheckin;
      case 'payment_pending':
        return BookingStatus.paymentPending;
      case 'payment_released':
      case 'paid':
        return BookingStatus.paymentReleased;
      case 'in_progress':
      case 'inprogress':
      case 'checked_in':
        return BookingStatus.inProgress;
      case 'verified_checkout':
      case 'checkout_verified':
        return BookingStatus.verifiedCheckout;
      case 'completed':
      case 'done':
      case 'checked_out':
        return BookingStatus.completed;
      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;
      case 'pending':
      default:
        return BookingStatus.requested;
    }
  }
}

enum VerificationMethod { gpsProximity, otpMatch, qrScan, manual }

enum PaymentStatus { pending, heldInEscrow, released, refunded, failed }

class Booking {
  final String id;
  final String workerId;
  final String workerName;
  final String workerSkill;
  final String workerPhone;
  final String workerCoop;
  final String householdId;
  final String householdName;
  final String householdPhone;
  final String serviceAddress;
  final double latitude;
  final double longitude;
  final BookingStatus status;
  final double amount;
  final double? finalAmount;
  final String scheduledDate;
  final String scheduledTime;
  final String notes;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double? rating;
  final String? review;
  final DateTime createdAt;

  final bool householdVerifiedCheckin;
  final bool workerVerifiedCheckin;
  final bool householdVerifiedCheckout;
  final bool workerVerifiedCheckout;
  final String? verificationOtp;
  final PaymentStatus paymentStatus;
  final double? workerLiveLat;
  final double? workerLiveLng;
  final DateTime? workerLastSeen;
  final DateTime? householdCheckinTime;
  final DateTime? workerCheckinTime;
  final DateTime? householdCheckoutTime;
  final DateTime? workerCheckoutTime;

  const Booking({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.workerSkill,
    required this.workerPhone,
    this.workerCoop = 'Metro Labour Cooperative',
    required this.householdId,
    required this.householdName,
    required this.householdPhone,
    required this.serviceAddress,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.status = BookingStatus.requested,
    required this.amount,
    this.finalAmount,
    required this.scheduledDate,
    required this.scheduledTime,
    this.notes = '',
    this.checkInTime,
    this.checkOutTime,
    this.rating,
    this.review,
    required this.createdAt,
    this.householdVerifiedCheckin = false,
    this.workerVerifiedCheckin = false,
    this.householdVerifiedCheckout = false,
    this.workerVerifiedCheckout = false,
    this.verificationOtp,
    this.paymentStatus = PaymentStatus.pending,
    this.workerLiveLat,
    this.workerLiveLng,
    this.workerLastSeen,
    this.householdCheckinTime,
    this.workerCheckinTime,
    this.householdCheckoutTime,
    this.workerCheckoutTime,
  });

  bool get bothVerifiedCheckin => householdVerifiedCheckin && workerVerifiedCheckin;
  bool get bothVerifiedCheckout => householdVerifiedCheckout && workerVerifiedCheckout;
  bool get paymentReleased => paymentStatus == PaymentStatus.released || paymentStatus == PaymentStatus.heldInEscrow;

  Booking copyWith({
    BookingStatus? status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    double? rating,
    String? review,
    String? notes,
    bool? householdVerifiedCheckin,
    bool? workerVerifiedCheckin,
    bool? householdVerifiedCheckout,
    bool? workerVerifiedCheckout,
    String? verificationOtp,
    PaymentStatus? paymentStatus,
    double? finalAmount,
    double? workerLiveLat,
    double? workerLiveLng,
    DateTime? workerLastSeen,
    DateTime? householdCheckinTime,
    DateTime? workerCheckinTime,
    DateTime? householdCheckoutTime,
    DateTime? workerCheckoutTime,
  }) {
    return Booking(
      id: id,
      workerId: workerId,
      workerName: workerName,
      workerSkill: workerSkill,
      workerPhone: workerPhone,
      workerCoop: workerCoop,
      householdId: householdId,
      householdName: householdName,
      householdPhone: householdPhone,
      serviceAddress: serviceAddress,
      latitude: latitude,
      longitude: longitude,
      status: status ?? this.status,
      amount: amount,
      finalAmount: finalAmount ?? this.finalAmount,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      notes: notes ?? this.notes,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt,
      householdVerifiedCheckin: householdVerifiedCheckin ?? this.householdVerifiedCheckin,
      workerVerifiedCheckin: workerVerifiedCheckin ?? this.workerVerifiedCheckin,
      householdVerifiedCheckout: householdVerifiedCheckout ?? this.householdVerifiedCheckout,
      workerVerifiedCheckout: workerVerifiedCheckout ?? this.workerVerifiedCheckout,
      verificationOtp: verificationOtp ?? this.verificationOtp,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      workerLiveLat: workerLiveLat ?? this.workerLiveLat,
      workerLiveLng: workerLiveLng ?? this.workerLiveLng,
      workerLastSeen: workerLastSeen ?? this.workerLastSeen,
      householdCheckinTime: householdCheckinTime ?? this.householdCheckinTime,
      workerCheckinTime: workerCheckinTime ?? this.workerCheckinTime,
      householdCheckoutTime: householdCheckoutTime ?? this.householdCheckoutTime,
      workerCheckoutTime: workerCheckoutTime ?? this.workerCheckoutTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'worker_id': workerId,
    'worker_name': workerName,
    'worker_skill': workerSkill,
    'worker_phone': workerPhone,
    'worker_coop': workerCoop,
    'household_id': householdId,
    'household_name': householdName,
    'household_phone': householdPhone,
    'service_address': serviceAddress,
    'latitude': latitude,
    'longitude': longitude,
    'status': status.key,
    'amount': amount,
    'final_amount': finalAmount,
    'scheduled_date': scheduledDate,
    'scheduled_time': scheduledTime,
    'notes': notes,
    'check_in_time': checkInTime?.toIso8601String(),
    'check_out_time': checkOutTime?.toIso8601String(),
    'rating': rating,
    'review': review,
    'created_at': createdAt.toIso8601String(),
    'household_verified_checkin': householdVerifiedCheckin,
    'worker_verified_checkin': workerVerifiedCheckin,
    'household_verified_checkout': householdVerifiedCheckout,
    'worker_verified_checkout': workerVerifiedCheckout,
    'verification_otp': verificationOtp,
    'payment_status': paymentStatus.name,
    'worker_live_lat': workerLiveLat,
    'worker_live_lng': workerLiveLng,
    'worker_last_seen': workerLastSeen?.toIso8601String(),
  };

  factory Booking.fromJson(Map<String, dynamic> json) {
    PaymentStatus pStatus = PaymentStatus.pending;
    final ps = json['payment_status']?.toString().toLowerCase();
    if (ps == 'released') {
      pStatus = PaymentStatus.released;
    } else if (ps == 'held_in_escrow' || ps == 'held') {
      pStatus = PaymentStatus.heldInEscrow;
    } else if (ps == 'refunded') {
      pStatus = PaymentStatus.refunded;
    } else if (ps == 'failed') {
      pStatus = PaymentStatus.failed;
    }

    return Booking(
      id: json['id']?.toString() ?? json['booking_id']?.toString() ?? json['_id']?.toString() ?? 'BK-001',
      workerId: json['worker_id']?.toString() ?? json['workerId']?.toString() ?? '',
      workerName: json['worker_name']?.toString() ?? json['workerName']?.toString() ?? 'Cooperative Specialist',
      workerSkill: json['worker_skill']?.toString() ?? json['service_id']?.toString() ?? 'Service',
      workerPhone: json['worker_phone']?.toString() ?? json['workerPhone']?.toString() ?? '+91 98450 11223',
      workerCoop: json['worker_coop']?.toString() ?? json['workerCoop']?.toString() ?? 'Bengaluru Labour Guild Co-op',
      householdId: json['household_id']?.toString() ?? json['householdId']?.toString() ?? '',
      householdName: json['household_name']?.toString() ?? json['householdName']?.toString() ?? 'Household Client',
      householdPhone: json['household_phone']?.toString() ?? json['householdPhone']?.toString() ?? '+91 98765 12345',
      serviceAddress: json['service_address']?.toString() ?? json['address']?.toString() ?? 'MG Road, Bengaluru',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 12.9716,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.5946,
      status: BookingStatus.fromString(json['status']?.toString()),
      amount: (json['amount'] as num?)?.toDouble() ?? (json['estimated_amount'] as num?)?.toDouble() ?? 700.0,
      finalAmount: (json['final_amount'] as num?)?.toDouble(),
      scheduledDate: json['scheduled_date']?.toString() ?? 'Today',
      scheduledTime: json['scheduled_time']?.toString() ?? '10:00 AM',
      notes: json['notes']?.toString() ?? '',
      checkInTime: json['check_in_time'] != null ? DateTime.tryParse(json['check_in_time'].toString()) : null,
      checkOutTime: json['check_out_time'] != null ? DateTime.tryParse(json['check_out_time'].toString()) : null,
      rating: (json['rating'] as num?)?.toDouble(),
      review: json['review']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      householdVerifiedCheckin: json['household_verified_checkin'] == true || json['household_verified_checkin']?.toString().toLowerCase() == 'true',
      workerVerifiedCheckin: json['worker_verified_checkin'] == true || json['worker_verified_checkin']?.toString().toLowerCase() == 'true',
      householdVerifiedCheckout: json['household_verified_checkout'] == true || json['household_verified_checkout']?.toString().toLowerCase() == 'true',
      workerVerifiedCheckout: json['worker_verified_checkout'] == true || json['worker_verified_checkout']?.toString().toLowerCase() == 'true',
      verificationOtp: json['verification_otp']?.toString(),
      paymentStatus: pStatus,
      workerLiveLat: (json['worker_live_lat'] as num?)?.toDouble(),
      workerLiveLng: (json['worker_live_lng'] as num?)?.toDouble(),
      workerLastSeen: json['worker_last_seen'] != null ? DateTime.tryParse(json['worker_last_seen'].toString()) : null,
      householdCheckinTime: json['household_checkin_time'] != null ? DateTime.tryParse(json['household_checkin_time'].toString()) : null,
      workerCheckinTime: json['worker_checkin_time'] != null ? DateTime.tryParse(json['worker_checkin_time'].toString()) : null,
      householdCheckoutTime: json['household_checkout_time'] != null ? DateTime.tryParse(json['household_checkout_time'].toString()) : null,
      workerCheckoutTime: json['worker_checkout_time'] != null ? DateTime.tryParse(json['worker_checkout_time'].toString()) : null,
    );
  }
}
