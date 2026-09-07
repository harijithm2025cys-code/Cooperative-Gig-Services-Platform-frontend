import 'package:flutter/foundation.dart';
import '../models/worker.dart';
import '../services/api_service.dart';

class WorkerProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Worker> _workers = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';
  Worker? _selectedWorker;
  String? _errorMessage;

  List<Worker> get workers => _workers;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  Worker? get selectedWorker => _selectedWorker;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWorkers({String? skill, double? lat, double? lng, double? radius}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _api.getAvailableWorkers(
        skill: skill ?? _selectedCategory,
        lat: lat ?? 12.9716,
        lng: lng ?? 77.5946,
        radius: radius ?? 5.0,
      );
      _workers = results;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    fetchWorkers(skill: category);
  }

  void selectWorker(Worker worker) {
    _selectedWorker = worker;
    notifyListeners();
  }
}
