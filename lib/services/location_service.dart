import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_realtime_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  double _currentLatitude = 12.9716;
  double _currentLongitude = 77.5946;
  String _currentAddress = 'Bengaluru Central, Karnataka';
  bool _hasLocationPermission = false;
  bool _isTrackingLive = false;

  StreamSubscription<Position>? _positionStream;
  StreamController<Position>? _livePositionController;
  Timer? _fireStoreSyncTimer;

  double get latitude => _currentLatitude;
  double get longitude => _currentLongitude;
  String get address => _currentAddress;
  bool get hasPermission => _hasLocationPermission;
  bool get isTrackingLive => _isTrackingLive;

  final FirebaseRealtimeService _realtime = FirebaseRealtimeService();

  Stream<Position>? get livePositionStream => _livePositionController?.stream;

  Future<Position?> getCurrentPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final result = await Geolocator.requestPermission();
        if (result == LocationPermission.denied ||
            result == LocationPermission.deniedForever) {
          _hasLocationPermission = false;
          debugPrint('Location permission denied by user.');
          return null;
        }
      }
      _hasLocationPermission = true;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      );
      _currentLatitude = pos.latitude;
      _currentLongitude = pos.longitude;
      debugPrint('📍 Current GPS: (${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}) accuracy=${pos.accuracy}m');
      return pos;
    } catch (e) {
      debugPrint('Error obtaining GPS location: $e — falling back to default coordinates.');
      return Position(
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        timestamp: DateTime.now(),
        accuracy: 100.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    }
  }

  Future<void> requestLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services disabled — prompt user to enable.');
      }
      final pos = await getCurrentPosition();
      if (pos != null) {
        _hasLocationPermission = true;
        debugPrint('✅ Location permission granted. Active coordinates: ($_currentLatitude, $_currentLongitude)');
      }
    } catch (e) {
      debugPrint('Error requesting location: $e');
    }
  }

  void setCustomLocation(double lat, double lng, String addr) {
    _currentLatitude = lat;
    _currentLongitude = lng;
    _currentAddress = addr;
  }

  Future<bool> startLiveTracking({
    required String workerId,
    String? bookingId,
    Duration updateInterval = const Duration(seconds: 5),
    double distanceFilterMeters = 3.0,
  }) async {
    try {
      if (_isTrackingLive) {
        debugPrint('⚠️ Live tracking already running for worker $workerId.');
        return true;
      }
      final pos = await getCurrentPosition();
      if (pos == null) {
        debugPrint('❌ Cannot start live tracking — no GPS permission.');
        return false;
      }
      _livePositionController ??= StreamController<Position>.broadcast();
      _isTrackingLive = true;

      final settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters.toInt(),
        forceLocationManager: true,
        intervalDuration: updateInterval,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: 'Cooperative Gig — sharing live location for active service gig',
          notificationTitle: 'Live Worker Tracking Active',
          enableWakeLock: true,
        ),
      );

      _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen((Position p) {
        _currentLatitude = p.latitude;
        _currentLongitude = p.longitude;
        _livePositionController?.add(p);
      });

      _fireStoreSyncTimer?.cancel();
      _fireStoreSyncTimer = Timer.periodic(updateInterval, (_) async {
        if (!_isTrackingLive) return;
        try {
          await _realtime.updateWorkerLiveLocation(
            workerId: workerId,
            latitude: _currentLatitude,
            longitude: _currentLongitude,
            heading: 0.0,
          );
          if (bookingId != null) {
            await _realtime.updateLiveBookingState(
              bookingId: bookingId,
              status: 'worker_enroute',
              workerId: workerId,
              extra: {
                'worker_live_lat': _currentLatitude,
                'worker_live_lng': _currentLongitude,
                'worker_last_seen': DateTime.now().toIso8601String(),
              },
            );
          }
          debugPrint('🛰️ Live GPS synced: worker=$workerId booking=$bookingId pos=($_currentLatitude, $_currentLongitude)');
        } catch (e) {
          debugPrint('Warning: live Firestore sync failed (non-fatal): $e');
        }
      });

      debugPrint('✅ Live location tracking STARTED for worker=$workerId every ${updateInterval.inSeconds}s');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to start live tracking: $e');
      _isTrackingLive = false;
      return false;
    }
  }

  void stopLiveTracking() {
    _isTrackingLive = false;
    _positionStream?.cancel();
    _positionStream = null;
    _fireStoreSyncTimer?.cancel();
    _fireStoreSyncTimer = null;
    _livePositionController?.close();
    _livePositionController = null;
    debugPrint('🛑 Live GPS tracking stopped.');
  }

  static double distanceKmBetween(double lat1, double lng1, double lat2, double lng2) {
    try {
      return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000.0;
    } catch (_) {
      final dLat = (lat2 - lat1) * (3.141592653589793 / 180.0);
      final dLng = (lng2 - lng1) * (3.141592653589793 / 180.0);
      final a = _sin(dLat/2)*_sin(dLat/2) +
          _cos(lat1 * (3.141592653589793 / 180.0)) * _cos(lat2 * (3.141592653589793 / 180.0)) *
          _sin(dLng/2) * _sin(dLng/2);
      final c = 2 * _atan2(_sqrt(a), _sqrt(1-a));
      return 6371.0 * c;
    }
  }

  static double _sin(double x) => x == 0.0 ? 0.0 : (x * 1.0);
  static double _cos(double x) => x == 0.0 ? 1.0 : (1.0 - x*x/2);
  static double _sqrt(double x) => x <= 0 ? 0 : x;
  static double _atan2(double a, double b) => (a + b) * 0.785;
}
