import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserRole get currentRole => _currentUser?.role ?? UserRole.household;

  // Check persisted session on startup
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final token = await _api.getToken();
    if (token != null) {
      // Restore default demo user if cached
      _currentUser = const User(
        id: 'usr_house_01',
        name: 'Ananya Sharma',
        phone: '+91 98765 12345',
        email: 'ananya@example.com',
        role: UserRole.customer,
        address: 'Flat 402, Green Glen Layout, Bellandur, Bengaluru',
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _api.login(username: username, password: password, role: role);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required UserRole role,
    String? address,
    String? skill,
    String? cooperativeId,
    String? memberRegId,
    String? workerType,
    double? hourlyRate,
    String? societyName,
    String? district,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _api.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
        role: role,
        address: address,
        skill: skill,
        cooperativeId: cooperativeId,
        memberRegId: memberRegId,
        workerType: workerType,
        hourlyRate: hourlyRate,
        societyName: societyName,
        district: district,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.clearAuth();
    _currentUser = null;
    notifyListeners();
  }

  void switchRole(UserRole newRole) {
    switch (newRole) {
      case UserRole.customer:
        _currentUser = const User(
          id: 'usr_house_01',
          name: 'Harijith M',
          phone: '+91 98765 12345',
          email: 'harijith@example.com',
          role: UserRole.customer,
          address: 'Flat 402, Green Glen Layout, Koramangala, Bengaluru',
        );
        break;

      case UserRole.cooperativeWorker:
        _currentUser = const User(
          id: 'wrk_1',
          name: 'Dhanabalan R',
          phone: '+91 98450 11223',
          email: 'dhanabalan.worker@coop.org',
          role: UserRole.cooperativeWorker,
          workerType: 'cooperative',
          isPreVerifiedByAssociation: true,
          memberRegId: 'ABC-COOP-1042',
          cooperativeId: 'coop_01',
          cooperativeName: 'ABC Skilled Workers Co-op (Member #1042)',
          address: 'Jayanagar 4th Block, Bengaluru',
        );
        break;

      case UserRole.independentWorker:
        _currentUser = const User(
          id: 'wrk_ind_01',
          name: 'Ajaipravin S',
          phone: '+91 97890 55443',
          email: 'ajaipravin.freelance@gmail.com',
          role: UserRole.independentWorker,
          workerType: 'independent',
          isPreVerifiedByAssociation: false,
          cooperativeName: null, // Outside cooperative hierarchy
          address: 'Indiranagar 100ft Rd, Bengaluru',
        );
        break;

      case UserRole.cooperativeAssociationHead:
        _currentUser = const User(
          id: 'adm_01',
          name: 'Priya Sundaram (Association Head)',
          phone: '+91 98450 99999',
          email: 'head@abccoop.org',
          role: UserRole.cooperativeAssociationHead,
          cooperativeId: 'coop_01',
          cooperativeName: 'ABC Skilled Workers Cooperative Society',
          federationName: 'Karnataka State Labour Cooperative Federation',
          address: 'District Cooperative Bhavan, Bengaluru',
        );
        break;

      case UserRole.superAdmin:
        _currentUser = const User(
          id: 'super_adm_01',
          name: 'State Federation Registrar (Super Admin)',
          phone: '+91 99000 11111',
          email: 'registrar@statefederation.gov.in',
          role: UserRole.superAdmin,
          federationName: 'National Labour Cooperative Federation of India',
          address: 'State Secretariat, Vidhana Soudha, Bengaluru',
        );
        break;
    }
    notifyListeners();
  }
}
