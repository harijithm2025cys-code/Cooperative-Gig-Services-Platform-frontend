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
        role: UserRole.household,
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
    if (newRole == UserRole.worker) {
      _currentUser = const User(
        id: 'wrk_1',
        name: 'Ramesh Kumar (Worker-Owner)',
        phone: '+91 98450 11223',
        email: 'ramesh.worker@coop.org',
        role: UserRole.worker,
        cooperativeName: 'Bengaluru Electrical Workers Co-op',
        address: 'Jayanagar 4th Block, Bengaluru',
      );
    } else if (newRole == UserRole.admin) {
      _currentUser = const User(
        id: 'adm_01',
        name: 'Priya Sundaram (Admin)',
        phone: '+91 98450 99999',
        email: 'admin@coop.org',
        role: UserRole.admin,
        cooperativeName: 'Bengaluru District Labour Cooperative Union',
      );
    } else {
      _currentUser = const User(
        id: 'usr_house_01',
        name: 'Ananya Sharma',
        phone: '+91 98765 12345',
        email: 'ananya@example.com',
        role: UserRole.household,
        address: 'Flat 402, Green Glen Layout, Bellandur, Bengaluru',
      );
    }
    notifyListeners();
  }
}
