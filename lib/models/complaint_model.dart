enum ComplaintStatus {
  open,
  underReview,
  resolved,
  dismissed;

  static ComplaintStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'under_review':
      case 'underreview':
        return ComplaintStatus.underReview;
      case 'dismissed':
        return ComplaintStatus.dismissed;
      case 'open':
      default:
        return ComplaintStatus.open;
    }
  }

  String get label {
    switch (this) {
      case ComplaintStatus.open:
        return 'OPEN';
      case ComplaintStatus.underReview:
        return 'UNDER REVIEW';
      case ComplaintStatus.resolved:
        return 'RESOLVED';
      case ComplaintStatus.dismissed:
        return 'DISMISSED';
    }
  }
}

class ComplaintModel {
  final String id;
  final String bookingId;
  final String customerId;
  final String? cooperativeId;
  final String category;
  final String description;
  final ComplaintStatus status;
  final String? resolutionNotes;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  // Compatibility alias
  String get complainantId => customerId;

  const ComplaintModel({
    required this.id,
    required this.bookingId,
    String? customerId,
    String? complainantId,
    this.cooperativeId,
    required this.category,
    required this.description,
    dynamic status = ComplaintStatus.open,
    this.resolutionNotes,
    required this.createdAt,
    this.resolvedAt,
  })  : customerId = customerId ?? (complainantId ?? ''),
        status = status is ComplaintStatus
            ? status
            : (status is String ? (status == 'open' ? ComplaintStatus.open : ComplaintStatus.resolved) : ComplaintStatus.open);

  ComplaintModel copyWith({
    String? id,
    String? bookingId,
    String? customerId,
    String? cooperativeId,
    String? category,
    String? description,
    ComplaintStatus? status,
    String? resolutionNotes,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      cooperativeId: cooperativeId ?? this.cooperativeId,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? (json['complainant_id']?.toString() ?? ''),
      cooperativeId: json['cooperative_id']?.toString(),
      category: json['category']?.toString() ?? 'Other',
      description: json['description']?.toString() ?? '',
      status: ComplaintStatus.fromString(json['status']?.toString() ?? 'open'),
      resolutionNotes: json['resolution_notes']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null ? DateTime.tryParse(json['resolved_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'customer_id': customerId,
      'cooperative_id': cooperativeId,
      'category': category,
      'description': description,
      'status': status.name,
      'resolution_notes': resolutionNotes,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}
