class BookingAssignment {
  final String id;
  final String bookingId;
  final String workerId;
  final String status;
  final DateTime? assignedAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? completedAt;
  final double? distanceKm;
  final double? matchingScore;
  final int assignmentSequence;
  final String? workerName;
  final String? workerPhone;
  final String? workerSkill;
  final String? cooperativeName;
  final String? serviceName;
  final String? serviceAddress;
  final String? scheduledTime;

  const BookingAssignment({
    required this.id,
    required this.bookingId,
    required this.workerId,
    this.status = 'ASSIGNED',
    this.assignedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.completedAt,
    this.distanceKm,
    this.matchingScore,
    this.assignmentSequence = 1,
    this.workerName,
    this.workerPhone,
    this.workerSkill,
    this.cooperativeName,
    this.serviceName,
    this.serviceAddress,
    this.scheduledTime,
  });

  factory BookingAssignment.fromJson(Map<String, dynamic> json) {
    final b = json['bookings'] as Map<String, dynamic>?;
    final w = json['workers'] as Map<String, dynamic>?;
    final u = w?['users'] as Map<String, dynamic>?;

    return BookingAssignment(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      workerId: json['worker_id']?.toString() ?? '',
      status: (json['status'] ?? 'ASSIGNED').toString().toUpperCase(),
      assignedAt: json['assigned_at'] != null ? DateTime.tryParse(json['assigned_at'].toString()) : null,
      acceptedAt: json['accepted_at'] != null ? DateTime.tryParse(json['accepted_at'].toString()) : null,
      rejectedAt: json['rejected_at'] != null ? DateTime.tryParse(json['rejected_at'].toString()) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'].toString()) : null,
      distanceKm: (json['distance_km'] is num) ? (json['distance_km'] as num).toDouble() : null,
      matchingScore: (json['matching_score'] is num) ? (json['matching_score'] as num).toDouble() : null,
      assignmentSequence: (json['assignment_sequence'] is num) ? (json['assignment_sequence'] as num).toInt() : 1,
      workerName: json['worker_name'] ?? u?['name'] ?? w?['name'],
      workerPhone: json['worker_phone'] ?? u?['phone'],
      workerSkill: json['worker_skill'] ?? w?['skill'],
      cooperativeName: json['cooperative_name'],
      serviceName: b?['service_id'] ?? b?['service_name'] ?? json['service_id'],
      serviceAddress: b?['address'] ?? json['address'],
      scheduledTime: b?['scheduled_time']?.toString() ?? json['scheduled_time']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'worker_id': workerId,
      'status': status,
      'assigned_at': assignedAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'distance_km': distanceKm,
      'matching_score': matchingScore,
      'assignment_sequence': assignmentSequence,
      'worker_name': workerName,
      'worker_phone': workerPhone,
      'worker_skill': workerSkill,
      'cooperative_name': cooperativeName,
    };
  }
}

class MatchingAuditLog {
  final String id;
  final String bookingId;
  final String? workerId;
  final String? workerName;
  final bool isEligible;
  final String? rejectionReason;
  final double? distanceKm;
  final double? matchingScore;

  const MatchingAuditLog({
    required this.id,
    required this.bookingId,
    this.workerId,
    this.workerName,
    required this.isEligible,
    this.rejectionReason,
    this.distanceKm,
    this.matchingScore,
  });

  factory MatchingAuditLog.fromJson(Map<String, dynamic> json) {
    return MatchingAuditLog(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      workerId: json['worker_id']?.toString(),
      workerName: json['worker_name']?.toString(),
      isEligible: json['is_eligible'] == true,
      rejectionReason: json['rejection_reason']?.toString(),
      distanceKm: (json['distance_km'] is num) ? (json['distance_km'] as num).toDouble() : null,
      matchingScore: (json['matching_score'] is num) ? (json['matching_score'] as num).toDouble() : null,
    );
  }
}
