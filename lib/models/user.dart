enum UserRole {
  household,
  worker,
  admin;

  String get label {
    switch (this) {
      case UserRole.household:
        return 'Household';
      case UserRole.worker:
        return 'Worker';
      case UserRole.admin:
        return 'Cooperative Admin';
    }
  }

  static UserRole fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'worker':
        return UserRole.worker;
      case 'admin':
        return UserRole.admin;
      case 'household':
      default:
        return UserRole.household;
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
  final String? cooperativeName;
  final String? address;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.token,
    this.cooperativeName,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'role': role.name,
    'token': token,
    'cooperative_name': cooperativeName,
    'address': address,
  };

  factory User.fromJson(Map<String, dynamic> json, {String? token}) => User(
    id: json['id']?.toString() ?? json['user_id']?.toString() ?? json['_id']?.toString() ?? '',
    name: json['name']?.toString() ?? json['full_name']?.toString() ?? 'Co-op Member',
    phone: json['phone']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    role: UserRole.fromString(json['role']?.toString()),
    token: token ?? json['token']?.toString() ?? json['access_token']?.toString(),
    cooperativeName: json['cooperative_name']?.toString() ?? json['cooperativeName']?.toString(),
    address: json['address']?.toString() ?? 'Bengaluru, India',
  );
}
