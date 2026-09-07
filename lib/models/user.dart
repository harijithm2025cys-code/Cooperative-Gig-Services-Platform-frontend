enum UserRole {
  customer,
  independentWorker,
  cooperativeAssociationHead,
  cooperativeWorker,
  superAdmin;

  // Backward compatibility aliases
  static UserRole get household => UserRole.customer;
  static UserRole get worker => UserRole.cooperativeWorker;
  static UserRole get admin => UserRole.cooperativeAssociationHead;

  String get label {
    switch (this) {
      case UserRole.customer:
        return 'Customer (Household / Institution)';
      case UserRole.independentWorker:
        return 'Independent Worker';
      case UserRole.cooperativeAssociationHead:
        return 'Cooperative Association Head';
      case UserRole.cooperativeWorker:
        return 'Cooperative Worker-Owner';
      case UserRole.superAdmin:
        return 'Super Admin (State Federation)';
    }
  }

  String get shortLabel {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.independentWorker:
        return 'Independent';
      case UserRole.cooperativeAssociationHead:
        return 'Association Head';
      case UserRole.cooperativeWorker:
        return 'Co-op Worker';
      case UserRole.superAdmin:
        return 'Super Admin';
    }
  }

  static UserRole fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'independent_worker':
      case 'independentworker':
      case 'independent':
        return UserRole.independentWorker;
      case 'cooperative_association_head':
      case 'cooperativeassociationhead':
      case 'association_head':
      case 'admin':
        return UserRole.cooperativeAssociationHead;
      case 'cooperative_worker':
      case 'cooperativeworker':
      case 'worker':
        return UserRole.cooperativeWorker;
      case 'super_admin':
      case 'superadmin':
      case 'federation_admin':
        return UserRole.superAdmin;
      case 'customer':
      case 'household':
      default:
        return UserRole.customer;
    }
  }
}

class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final String? token;
  final String? cooperativeId;
  final String? cooperativeName;
  final String? federationName;
  final String? memberRegId;
  final String? workerType; // 'cooperative' or 'independent'
  final bool isPreVerifiedByAssociation;
  final String? address;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.token,
    this.cooperativeId,
    this.cooperativeName,
    this.federationName,
    this.memberRegId,
    this.workerType,
    this.isPreVerifiedByAssociation = false,
    this.address,
  });

  bool get isCooperativeWorker => role == UserRole.cooperativeWorker || workerType == 'cooperative';
  bool get isIndependentWorker => role == UserRole.independentWorker || workerType == 'independent';
  bool get isAssociationHead => role == UserRole.cooperativeAssociationHead;
  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isCustomer => role == UserRole.customer;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'role': role.name,
    'token': token,
    'cooperative_id': cooperativeId,
    'cooperative_name': cooperativeName,
    'federation_name': federationName,
    'member_reg_id': memberRegId,
    'worker_type': workerType,
    'is_pre_verified': isPreVerifiedByAssociation,
    'address': address,
  };

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    final parsedRole = UserRole.fromString(json['role']?.toString());
    final isCoop = parsedRole == UserRole.cooperativeWorker || json['worker_type'] == 'cooperative';

    return User(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? 'User',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: parsedRole,
      token: token ?? json['token']?.toString() ?? json['access_token']?.toString(),
      cooperativeId: json['cooperative_id']?.toString() ?? json['cooperativeId']?.toString(),
      cooperativeName: json['cooperative_name']?.toString() ?? json['cooperativeName']?.toString() ?? (isCoop ? 'District Labour Cooperative' : null),
      federationName: json['federation_name']?.toString() ?? 'National Cooperative Federation',
      memberRegId: json['member_reg_id']?.toString() ?? (isCoop ? 'COOP-MEMBER-789' : null),
      workerType: json['worker_type']?.toString() ?? (isCoop ? 'cooperative' : (parsedRole == UserRole.independentWorker ? 'independent' : null)),
      isPreVerifiedByAssociation: json['is_pre_verified'] == true || isCoop,
      address: json['address']?.toString() ?? 'Bengaluru, India',
    );
  }
}
