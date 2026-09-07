class CooperativeTariff {
  final String id;
  final String cooperativeId;
  final String? serviceId;
  final String serviceName;
  final double hourlyRate;
  final double baseFee;
  final double emergencySurchargeRate;
  final bool isActive;

  const CooperativeTariff({
    required this.id,
    required this.cooperativeId,
    this.serviceId,
    required this.serviceName,
    required this.hourlyRate,
    this.baseFee = 150.0,
    this.emergencySurchargeRate = 1.25,
    this.isActive = true,
  });

  factory CooperativeTariff.fromJson(Map<String, dynamic> json) {
    return CooperativeTariff(
      id: json['id']?.toString() ?? '',
      cooperativeId: json['cooperative_id']?.toString() ?? '',
      serviceId: json['service_id']?.toString(),
      serviceName: json['service_name']?.toString() ?? 'General Service',
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 350.0,
      baseFee: (json['base_fee'] as num?)?.toDouble() ?? 150.0,
      emergencySurchargeRate: (json['emergency_surcharge_rate'] as num?)?.toDouble() ?? 1.25,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cooperative_id': cooperativeId,
      'service_id': serviceId,
      'service_name': serviceName,
      'hourly_rate': hourlyRate,
      'base_fee': baseFee,
      'emergency_surcharge_rate': emergencySurchargeRate,
      'is_active': isActive,
    };
  }
}
