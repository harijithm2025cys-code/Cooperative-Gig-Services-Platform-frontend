class BulkBookingItem {
  final String id;
  final String tradeName;
  final int quantityRequested;
  final int quantityAssigned;
  final double ratePerWorker;

  const BulkBookingItem({
    required this.id,
    required this.tradeName,
    required this.quantityRequested,
    this.quantityAssigned = 0,
    required this.ratePerWorker,
  });

  factory BulkBookingItem.fromJson(Map<String, dynamic> json) {
    return BulkBookingItem(
      id: json['id']?.toString() ?? '',
      tradeName: json['trade_name']?.toString() ?? 'Service Trade',
      quantityRequested: (json['quantity_requested'] as num?)?.toInt() ?? 1,
      quantityAssigned: (json['quantity_assigned'] as num?)?.toInt() ?? 0,
      ratePerWorker: (json['rate_per_worker'] as num?)?.toDouble() ?? 350.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trade_name': tradeName,
      'quantity_requested': quantityRequested,
      'rate_per_worker': ratePerWorker,
    };
  }
}

class BulkBooking {
  final String id;
  final String customerId;
  final String? institutionName;
  final String contactPerson;
  final String contactPhone;
  final String serviceAddress;
  final String scheduledDate;
  final String scheduledTime;
  final int totalWorkersRequested;
  final int totalWorkersAssigned;
  final String status;
  final double totalEstimatedAmount;
  final String paymentStatus;
  final bool isEmergency;
  final String? notes;
  final List<BulkBookingItem> items;

  const BulkBooking({
    required this.id,
    required this.customerId,
    this.institutionName,
    required this.contactPerson,
    required this.contactPhone,
    required this.serviceAddress,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.totalWorkersRequested,
    this.totalWorkersAssigned = 0,
    this.status = 'requested',
    required this.totalEstimatedAmount,
    this.paymentStatus = 'pending',
    this.isEmergency = false,
    this.notes,
    this.items = const [],
  });

  factory BulkBooking.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? json['bulk_booking_items'] as List<dynamic>? ?? [];
    return BulkBooking(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      institutionName: json['institution_name']?.toString(),
      contactPerson: json['contact_person']?.toString() ?? 'Representative',
      contactPhone: json['contact_phone']?.toString() ?? '',
      serviceAddress: json['service_address']?.toString() ?? 'Location',
      scheduledDate: json['scheduled_date']?.toString() ?? 'Today',
      scheduledTime: json['scheduled_time']?.toString() ?? '09:00 AM',
      totalWorkersRequested: (json['total_workers_requested'] as num?)?.toInt() ?? 1,
      totalWorkersAssigned: (json['total_workers_assigned'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'requested',
      totalEstimatedAmount: (json['total_estimated_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status']?.toString() ?? 'pending',
      isEmergency: json['is_emergency'] as bool? ?? false,
      notes: json['notes']?.toString(),
      items: rawItems.map((e) => BulkBookingItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
