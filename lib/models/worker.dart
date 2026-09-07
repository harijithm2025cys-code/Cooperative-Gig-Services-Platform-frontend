class Worker {
  final String id;
  final String name;
  final String skill;
  final double rating;
  final int reviewsCount;
  final double distanceKm;
  final double latitude;
  final double longitude;
  final bool isVerified;
  final double hourlyRate;
  final String phone;
  final String cooperativeName;
  final int completedJobs;
  final String bio;
  final double? matchScore;
  final int? experienceYears;

  final String? workerType; // 'cooperative' or 'independent'
  final String? cooperativeId;
  final String? memberRegId;
  final bool isPreVerifiedByAssociation;

  const Worker({
    required this.id,
    required this.name,
    required this.skill,
    required this.rating,
    this.reviewsCount = 48,
    required this.distanceKm,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.isVerified = true,
    this.hourlyRate = 350.0,
    this.phone = '+91 98450 11223',
    this.cooperativeName = 'ABC Skilled Workers Co-op',
    this.completedJobs = 142,
    this.bio = 'Certified professional member-owner offering trusted service.',
    this.matchScore,
    this.experienceYears,
    this.workerType = 'cooperative',
    this.cooperativeId,
    this.memberRegId,
    this.isPreVerifiedByAssociation = true,
  });

  bool get isCooperativeWorker => workerType != 'independent';
  bool get isIndependentWorker => workerType == 'independent';

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'W';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'skill': skill,
    'rating': rating,
    'reviews_count': reviewsCount,
    'distance_km': distanceKm,
    'latitude': latitude,
    'longitude': longitude,
    'is_verified': isVerified,
    'hourly_rate': hourlyRate,
    'phone': phone,
    'cooperative_name': cooperativeName,
    'completed_jobs': completedJobs,
    'bio': bio,
    'match_score': matchScore,
    'experience_years': experienceYears,
  };

  factory Worker.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? json['user_id']?.toString() ?? 'wrk_01';
    final shortCode = rawId.length >= 6 ? rawId.substring(0, 6).toUpperCase() : rawId.toUpperCase();
    
    // Capitalize skill nicely
    final rawSkill = json['skill']?.toString() ?? 'Specialist';
    final formattedSkill = rawSkill.isNotEmpty 
        ? '${rawSkill[0].toUpperCase()}${rawSkill.substring(1).toLowerCase()}' 
        : 'Specialist';

    return Worker(
      id: rawId,
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? 'Member Worker ($shortCode)',
      skill: formattedSkill,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 42,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? (json['distance'] as num?)?.toDouble() ?? 1.5,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 12.9716,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.5946,
      isVerified: json['is_verified'] == true || json['isVerified'] == true || json['verified'] == true,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 350.0,
      phone: json['phone']?.toString() ?? '+91 98450 11223',
      cooperativeName: json['cooperative_name']?.toString() ?? 'Labour Cooperative Guild',
      completedJobs: (json['completed_jobs'] as num?)?.toInt() ?? 120,
      bio: json['bio']?.toString() ?? 'Cooperative-verified professional with proven craftsmanship.',
      matchScore: (json['match_score'] as num?)?.toDouble(),
      experienceYears: (json['experience_years'] as num?)?.toInt(),
    );
  }
}
