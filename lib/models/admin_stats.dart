class DisputeItem {
  final String id;
  final String bookingId;
  final String householdName;
  final String workerName;
  final String issue;
  final String status; // 'pending' or 'resolved'
  final DateTime? date;

  const DisputeItem({
    required this.id,
    required this.bookingId,
    required this.householdName,
    required this.workerName,
    required this.issue,
    this.status = 'pending',
    this.date,
  });

  DisputeItem copyWith({String? status}) => DisputeItem(
    id: id,
    bookingId: bookingId,
    householdName: householdName,
    workerName: workerName,
    issue: issue,
    status: status ?? this.status,
    date: date,
  );
}

class AdminStats {
  final int totalWorkers;
  final int totalHouseholds;
  final int totalCooperatives;
  final int activeBookings;
  final int pendingDisputes;
  final int resolvedDisputes;
  final double cooperativeDividendPool;
  final double platformVolume;
  final List<DisputeItem> disputes;

  const AdminStats({
    this.totalWorkers = 75,
    this.totalHouseholds = 24,
    this.totalCooperatives = 10,
    this.activeBookings = 15,
    this.pendingDisputes = 2,
    this.resolvedDisputes = 13,
    this.cooperativeDividendPool = 148500.0,
    this.platformVolume = 924000.0,
    this.disputes = const [
      DisputeItem(
        id: 'DSP-101',
        bookingId: 'BK-8840',
        householdName: 'Meera Nair',
        workerName: 'Lakshmi Devi',
        issue: 'Service delay due to traffic; requested coupon refund.',
        status: 'pending',
      ),
      DisputeItem(
        id: 'DSP-102',
        bookingId: 'BK-8902',
        householdName: 'Rahul Varma',
        workerName: 'Suresh Patil',
        issue: 'Additional pipe fitting cost clarification.',
        status: 'pending',
      ),
    ],
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
    totalWorkers: (json['total_workers'] as num?)?.toInt() ?? 75,
    totalHouseholds: (json['total_households'] as num?)?.toInt() ?? 24,
    totalCooperatives: (json['total_cooperatives'] as num?)?.toInt() ?? 10,
    activeBookings: (json['active_bookings'] as num?)?.toInt() ?? 15,
    pendingDisputes: (json['pending_disputes'] as num?)?.toInt() ?? 2,
    resolvedDisputes: (json['resolved_disputes'] as num?)?.toInt() ?? 13,
    cooperativeDividendPool: (json['dividend_pool'] as num?)?.toDouble() ?? 148500.0,
    platformVolume: (json['total_volume'] as num?)?.toDouble() ?? 924000.0,
  );
}
