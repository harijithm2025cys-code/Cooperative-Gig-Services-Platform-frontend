import 'package:flutter/foundation.dart';
import '../models/admin_stats.dart';
import '../models/worker.dart';
import '../services/api_service.dart';

class AdminProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  // Legacy compatibility fields
  AdminStats _stats = const AdminStats();
  List<Worker> _workers = [];
  bool _isLoading = false;
  String? _errorMessage;

  AdminStats get stats => _stats;
  List<Worker> get workers => _workers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // =========================================================================
  // Phase 6: Association Head State
  // =========================================================================
  Map<String, dynamic>? _associationDashboard;
  List<Map<String, dynamic>> _associationWorkers = [];
  List<Map<String, dynamic>> _associationServices = [];
  List<Map<String, dynamic>> _associationBookings = [];
  List<Map<String, dynamic>> _associationOperations = [];
  List<Map<String, dynamic>> _associationAssignments = [];
  List<Map<String, dynamic>> _associationDisputes = [];
  Map<String, dynamic>? _associationPayments;
  Map<String, dynamic>? _associationAnalytics;

  Map<String, dynamic>? get associationDashboard => _associationDashboard;
  List<Map<String, dynamic>> get associationWorkers => _associationWorkers;
  List<Map<String, dynamic>> get associationServices => _associationServices;
  List<Map<String, dynamic>> get associationBookings => _associationBookings;
  List<Map<String, dynamic>> get associationOperations => _associationOperations;
  List<Map<String, dynamic>> get associationAssignments => _associationAssignments;
  List<Map<String, dynamic>> get associationDisputes => _associationDisputes;
  Map<String, dynamic>? get associationPayments => _associationPayments;
  Map<String, dynamic>? get associationAnalytics => _associationAnalytics;

  // =========================================================================
  // Phase 6: Super Admin Platform State
  // =========================================================================
  Map<String, dynamic>? _adminDashboard;
  List<Map<String, dynamic>> _adminUsers = [];
  Map<String, dynamic>? _adminFederationTree;
  List<Map<String, dynamic>> _adminCooperatives = [];
  List<Map<String, dynamic>> _adminAllWorkers = [];
  List<Map<String, dynamic>> _adminBookings = [];
  Map<String, dynamic>? _adminPayments;
  List<Map<String, dynamic>> _adminDisputes = [];
  List<Map<String, dynamic>> _adminAuditLogs = [];
  Map<String, dynamic>? _adminAnalytics;

  Map<String, dynamic>? get adminDashboard => _adminDashboard;
  List<Map<String, dynamic>> get adminUsers => _adminUsers;
  Map<String, dynamic>? get adminFederationTree => _adminFederationTree;
  List<Map<String, dynamic>> get adminCooperatives => _adminCooperatives;
  List<Map<String, dynamic>> get adminAllWorkers => _adminAllWorkers;
  List<Map<String, dynamic>> get adminBookings => _adminBookings;
  Map<String, dynamic>? get adminPayments => _adminPayments;
  List<Map<String, dynamic>> get adminDisputes => _adminDisputes;
  List<Map<String, dynamic>> get adminAuditLogs => _adminAuditLogs;
  Map<String, dynamic>? get adminAnalytics => _adminAnalytics;

  // =========================================================================
  // Phase 7: Real Analytics & ML Foundation State
  // =========================================================================
  String _selectedDateRange = 'last_30_days';
  Map<String, dynamic>? _platformKpis;
  Map<String, dynamic>? _phase7AssociationAnalytics;
  Map<String, dynamic>? _serviceDemand;
  List<Map<String, dynamic>> _workerUtilizationList = [];
  Map<String, dynamic>? _matchingAnalytics;
  Map<String, dynamic>? _geographicDemand;
  Map<String, dynamic>? _dataQualityReport;

  String get selectedDateRange => _selectedDateRange;
  Map<String, dynamic>? get platformKpis => _platformKpis;
  Map<String, dynamic>? get phase7AssociationAnalytics => _phase7AssociationAnalytics;
  Map<String, dynamic>? get serviceDemand => _serviceDemand;
  List<Map<String, dynamic>> get workerUtilizationList => _workerUtilizationList;
  Map<String, dynamic>? get matchingAnalytics => _matchingAnalytics;
  Map<String, dynamic>? get geographicDemand => _geographicDemand;
  Map<String, dynamic>? get dataQualityReport => _dataQualityReport;

  // =========================================================================
  // Association Head Data Fetching & Mutations
  // =========================================================================
  Future<void> fetchAssociationData({String? cooperativeId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getAssociationDashboard(cooperativeId: cooperativeId),
        _api.getAssociationWorkers(cooperativeId: cooperativeId),
        _api.getAssociationServices(cooperativeId: cooperativeId),
        _api.getAssociationBookings(cooperativeId: cooperativeId),
        _api.getAssociationOperations(cooperativeId: cooperativeId),
        _api.getAssociationAssignments(cooperativeId: cooperativeId),
        _api.getAssociationDisputes(cooperativeId: cooperativeId),
        _api.getAssociationPayments(cooperativeId: cooperativeId),
        _api.getAssociationAnalytics(cooperativeId: cooperativeId),
      ]);

      _associationDashboard = results[0] as Map<String, dynamic>?;
      final workersMap = results[1] as Map<String, dynamic>;
      _associationWorkers = (workersMap['workers'] as List? ?? []).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
      _associationServices = results[2] as List<Map<String, dynamic>>;
      final bookingsMap = results[3] as Map<String, dynamic>;
      _associationBookings = (bookingsMap['bookings'] as List? ?? []).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
      _associationOperations = results[4] as List<Map<String, dynamic>>;
      _associationAssignments = results[5] as List<Map<String, dynamic>>;
      _associationDisputes = results[6] as List<Map<String, dynamic>>;
      _associationPayments = results[7] as Map<String, dynamic>?;
      _associationAnalytics = results[8] as Map<String, dynamic>?;
    } catch (e) {
      _errorMessage = 'Failed to load association dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateWorkerProfile({
    required String workerId,
    String? phone,
    String? skill,
    bool? isAvailable,
    bool? active,
    String? cooperativeId,
  }) async {
    final success = await _api.updateAssociationWorker(
      workerId: workerId,
      phone: phone,
      skill: skill,
      isAvailable: isAvailable,
      active: active,
      cooperativeId: cooperativeId,
    );
    if (success) {
      await fetchAssociationData(cooperativeId: cooperativeId);
    }
    return success;
  }

  Future<bool> createCooperativeService({
    required String name,
    required String category,
    required double basePrice,
    String? description,
    String? unit,
    bool isActive = true,
    String? cooperativeId,
  }) async {
    final success = await _api.createAssociationService(
      name: name,
      category: category,
      basePrice: basePrice,
      description: description,
      unit: unit,
      isActive: isActive,
      cooperativeId: cooperativeId,
    );
    if (success) {
      await fetchAssociationData(cooperativeId: cooperativeId);
    }
    return success;
  }

  Future<bool> updateCooperativeService({
    required String serviceId,
    String? name,
    String? category,
    String? description,
    double? basePrice,
    String? unit,
    bool? isActive,
    String? cooperativeId,
  }) async {
    final success = await _api.updateAssociationService(
      serviceId: serviceId,
      name: name,
      category: category,
      description: description,
      basePrice: basePrice,
      unit: unit,
      isActive: isActive,
      cooperativeId: cooperativeId,
    );
    if (success) {
      await fetchAssociationData(cooperativeId: cooperativeId);
    }
    return success;
  }

  Future<bool> reviewDispute({
    required String complaintId,
    required String status,
    required String resolutionNotes,
    String? cooperativeId,
  }) async {
    final success = await _api.reviewAssociationDispute(
      complaintId: complaintId,
      status: status,
      resolutionNotes: resolutionNotes,
      cooperativeId: cooperativeId,
    );
    if (success) {
      await fetchAssociationData(cooperativeId: cooperativeId);
    }
    return success;
  }

  // =========================================================================
  // Super Admin Data Fetching & Platform Governance Actions
  // =========================================================================
  Future<void> fetchSuperAdminData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getSuperAdminDashboard(),
        _api.getAdminUsers(),
        _api.getAdminFederationTree(),
        _api.getAdminCooperatives(),
        _api.getAdminAllWorkers(),
        _api.getAdminBookings(),
        _api.getAdminPayments(),
        _api.getAdminDisputes(),
        _api.getAdminAuditLogs(),
        _api.getAdminAnalytics(),
      ]);

      _adminDashboard = results[0] as Map<String, dynamic>?;
      final usersMap = results[1] as Map<String, dynamic>;
      _adminUsers = (usersMap['users'] as List? ?? []).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
      _adminFederationTree = results[2] as Map<String, dynamic>?;
      _adminCooperatives = results[3] as List<Map<String, dynamic>>;
      final workersMap = results[4] as Map<String, dynamic>;
      _adminAllWorkers = (workersMap['workers'] as List? ?? []).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
      final bookingsMap = results[5] as Map<String, dynamic>;
      _adminBookings = (bookingsMap['bookings'] as List? ?? []).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
      _adminPayments = results[6] as Map<String, dynamic>?;
      _adminDisputes = results[7] as List<Map<String, dynamic>>;
      _adminAuditLogs = results[8] as List<Map<String, dynamic>>;
      _adminAnalytics = results[9] as Map<String, dynamic>?;
    } catch (e) {
      _errorMessage = 'Failed to load Super Admin platform data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserRole({
    required String userId,
    required String role,
    String? cooperativeId,
  }) async {
    final success = await _api.updateAdminUserRole(
      userId: userId,
      role: role,
      cooperativeId: cooperativeId,
    );
    if (success) {
      await fetchSuperAdminData();
    }
    return success;
  }

  Future<bool> registerCooperativeSociety({
    required String name,
    required String district,
    String? state,
    String? address,
    String? registrationNumber,
    String? contactEmail,
    String? contactPhone,
    bool verified = true,
  }) async {
    final success = await _api.createAdminCooperative(
      name: name,
      district: district,
      state: state,
      address: address,
      registrationNumber: registrationNumber,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      verified: verified,
    );
    if (success) {
      await fetchSuperAdminData();
    }
    return success;
  }

  Future<bool> verifyWorkerSuperAdmin({
    required String workerId,
    required bool verifiedStatus,
  }) async {
    final success = await _api.updateAdminWorker(
      workerId: workerId,
      verifiedStatus: verifiedStatus,
    );
    if (success) {
      await fetchSuperAdminData();
    }
    return success;
  }

  Future<bool> resolveDisputeWithRefundAction({
    required String complaintId,
    required String status,
    required String resolutionNotes,
    bool refundApproved = false,
  }) async {
    final success = await _api.resolveDisputeWithRefund(
      complaintId: complaintId,
      status: status,
      resolutionNotes: resolutionNotes,
      refundApproved: refundApproved,
    );
    if (success) {
      await fetchSuperAdminData();
    }
    return success;
  }

  // =========================================================================
  // Legacy Methods for Backward Compatibility
  // =========================================================================
  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final statsFuture = _api.getAdminStats();
      final workersFuture = _api.getAvailableWorkers(skill: 'all');

      final results = await Future.wait([statsFuture, workersFuture]);
      _stats = results[0] as AdminStats;
      _workers = results[1] as List<Worker>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resolveDispute(String disputeId) {
    final updatedDisputes = _stats.disputes.map((d) {
      if (d.id == disputeId) {
        return d.copyWith(status: 'resolved');
      }
      return d;
    }).toList();

    _stats = AdminStats(
      totalWorkers: _stats.totalWorkers,
      activeBookings: _stats.activeBookings,
      pendingDisputes: (_stats.pendingDisputes > 0 ? _stats.pendingDisputes - 1 : 0),
      resolvedDisputes: _stats.resolvedDisputes + 1,
      cooperativeDividendPool: _stats.cooperativeDividendPool,
      platformVolume: _stats.platformVolume,
      disputes: updatedDisputes,
    );
    notifyListeners();
  }

  // =========================================================================
  // Phase 7: Analytics & Historical Data Fetching Methods
  // =========================================================================

  Future<void> setDateRange(
    String rangeType, {
    String? cooperativeId,
    bool isSuperAdmin = false,
    String? startDate,
    String? endDate,
  }) async {
    _selectedDateRange = rangeType;
    notifyListeners();
    await fetchPhase7Analytics(
      cooperativeId: cooperativeId,
      isSuperAdmin: isSuperAdmin,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> fetchPhase7Analytics({
    String? cooperativeId,
    bool isSuperAdmin = false,
    String? startDate,
    String? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isSuperAdmin) {
        final results = await Future.wait([
          _api.getPlatformKpis(rangeType: _selectedDateRange, startDate: startDate, endDate: endDate),
          _api.getServiceDemandAnalytics(rangeType: _selectedDateRange, startDate: startDate, endDate: endDate),
          _api.getWorkerUtilizationAnalytics(rangeType: _selectedDateRange),
          _api.getGeographicDemandAnalytics(rangeType: _selectedDateRange),
          _api.getMatchingAnalytics(rangeType: _selectedDateRange),
          _api.getDataQualityReport(),
        ]);

        _platformKpis = results[0];
        _serviceDemand = results[1];
        final wData = results[2];
        if (wData != null && wData['workers'] is List) {
          _workerUtilizationList = (wData['workers'] as List).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
        }
        _geographicDemand = results[3];
        _matchingAnalytics = results[4];
        _dataQualityReport = results[5];
      } else if (cooperativeId != null) {
        final results = await Future.wait([
          _api.getAssociationScopedAnalytics(cooperativeId: cooperativeId, rangeType: _selectedDateRange, startDate: startDate, endDate: endDate),
          _api.getServiceDemandAnalytics(cooperativeId: cooperativeId, rangeType: _selectedDateRange, startDate: startDate, endDate: endDate),
          _api.getWorkerUtilizationAnalytics(cooperativeId: cooperativeId, rangeType: _selectedDateRange),
          _api.getGeographicDemandAnalytics(cooperativeId: cooperativeId, rangeType: _selectedDateRange),
          _api.getMatchingAnalytics(cooperativeId: cooperativeId, rangeType: _selectedDateRange),
        ]);

        _phase7AssociationAnalytics = results[0];
        _serviceDemand = results[1];
        final wData = results[2];
        if (wData != null && wData['workers'] is List) {
          _workerUtilizationList = (wData['workers'] as List).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
        }
        _geographicDemand = results[3];
        _matchingAnalytics = results[4];
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWorkerUtilizationList({
    String? cooperativeId,
    String? search,
    int page = 1,
  }) async {
    try {
      final res = await _api.getWorkerUtilizationAnalytics(
        cooperativeId: cooperativeId,
        search: search,
        page: page,
        rangeType: _selectedDateRange,
      );
      if (res != null && res['workers'] is List) {
        _workerUtilizationList = (res['workers'] as List).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('fetchWorkerUtilizationList error: $e');
    }
  }

  Future<void> fetchMatchingAnalyticsLogs({
    String? cooperativeId,
    int page = 1,
  }) async {
    try {
      final res = await _api.getMatchingAnalytics(
        cooperativeId: cooperativeId,
        page: page,
        rangeType: _selectedDateRange,
      );
      if (res != null) {
        _matchingAnalytics = res;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('fetchMatchingAnalyticsLogs error: $e');
    }
  }

  Future<void> fetchDataQualityAudit() async {
    try {
      final res = await _api.getDataQualityReport();
      if (res != null) {
        _dataQualityReport = res;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('fetchDataQualityAudit error: $e');
    }
  }
}
