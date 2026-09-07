import 'package:flutter/foundation.dart';
import '../models/admin_stats.dart';
import '../models/worker.dart';
import '../services/api_service.dart';

class AdminProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  AdminStats _stats = const AdminStats();
  List<Worker> _workers = [];
  bool _isLoading = false;
  String? _errorMessage;

  AdminStats get stats => _stats;
  List<Worker> get workers => _workers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
}
