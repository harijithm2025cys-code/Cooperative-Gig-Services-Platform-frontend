import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../models/worker.dart';
import '../providers/booking_provider.dart';
import '../services/firebase_realtime_service.dart';
import '../utils/app_colors.dart';

class CustomMapWidget extends StatefulWidget {
  final List<Worker> workers;
  final double centerLat;
  final double centerLng;
  final Function(Worker)? onWorkerSelected;
  final Booking? activeBooking;
  final bool showLiveWorkerTracking;
  final bool showHousehold;
  final bool showNearbyWorkers;
  final double? workerLiveLat;
  final double? workerLiveLng;
  final String? workerNameForLive;
  final String? workerIdForLive;
  final double? serviceLatitude;
  final double? serviceLongitude;

  const CustomMapWidget({
    super.key,
    this.workers = const [],
    this.centerLat = 12.9716,
    this.centerLng = 77.5946,
    this.onWorkerSelected,
    this.activeBooking,
    this.showLiveWorkerTracking = false,
    this.showHousehold = true,
    this.showNearbyWorkers = true,
    this.workerLiveLat,
    this.workerLiveLng,
    this.workerNameForLive,
    this.workerIdForLive,
    this.serviceLatitude,
    this.serviceLongitude,
  });

  @override
  State<CustomMapWidget> createState() => _CustomMapWidgetState();
}

class _CustomMapWidgetState extends State<CustomMapWidget> {
  final Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  StreamSubscription? _workerLocationSubscription;
  double? _liveLat;
  double? _liveLng;
  bool _useGoogleMaps = true;

  @override
  void initState() {
    super.initState();
    _liveLat = widget.workerLiveLat;
    _liveLng = widget.workerLiveLng;
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() async {
    await _buildMarkersAndPolylines();
    if (widget.showLiveWorkerTracking && widget.activeBooking != null) {
      _startLiveLocationStream();
    }
  }

  void _startLiveLocationStream() {
    final bookingId = widget.activeBooking?.id;
    final workerId = widget.activeBooking?.workerId;
    if (bookingId == null && workerId == null) return;

    try {
      if (workerId != null) {
        _workerLocationSubscription = FirebaseRealtimeService()
            .streamWorkerLocation(workerId)
            .listen((data) {
          if (data != null) {
            final lat = (data['latitude'] as num?)?.toDouble();
            final lng = (data['longitude'] as num?)?.toDouble();
            if (lat != null && lng != null && mounted) {
              setState(() {
                _liveLat = lat;
                _liveLng = lng;
              });
              _buildMarkersAndPolylines();
              _pulseCameraToLiveWorker();
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Live map stream init notice: $e');
    }
  }

  Future<void> _pulseCameraToLiveWorker() async {
    if (_liveLat == null || _liveLng == null || !_mapController.isCompleted) return;
    try {
      final ctrl = await _mapController.future;
      await ctrl.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(_liveLat!, _liveLng!),
        16.5,
      ));
    } catch (_) {}
  }

  Future<void> _buildMarkersAndPolylines() async {
    try {
      final markers = <Marker>{};
      final polylines = <Polyline>{};

      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(widget.centerLat, widget.centerLng),
          infoWindow: const InfoWindow(title: 'Your Home Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      for (final worker in widget.workers) {
        markers.add(
          Marker(
            markerId: MarkerId('worker_${worker.id}'),
            position: LatLng(worker.latitude, worker.longitude),
            infoWindow: InfoWindow(
              title: worker.name,
              snippet: '${worker.skill} • ${worker.distanceKm.toStringAsFixed(1)} km • ₹${worker.hourlyRate.toInt()}/hr',
              onTap: () {
                if (widget.onWorkerSelected != null) {
                  widget.onWorkerSelected!(worker);
                }
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            onTap: () {
              if (widget.onWorkerSelected != null) {
                widget.onWorkerSelected!(worker);
              }
            },
          ),
        );
      }

      if (widget.showLiveWorkerTracking) {
        final wLat = _liveLat ?? widget.workerLiveLat ?? widget.activeBooking?.workerLiveLat;
        final wLng = _liveLng ?? widget.workerLiveLng ?? widget.activeBooking?.workerLiveLng;
        if (wLat != null && wLng != null) {
          markers.add(
            Marker(
              markerId: const MarkerId('live_worker'),
              position: LatLng(wLat, wLng),
              infoWindow: InfoWindow(
                title: '🛵 ${widget.workerNameForLive ?? widget.activeBooking?.workerName ?? 'Worker'} (Live)',
                snippet: 'En route to service location',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          );

          final routePoints = _buildRoutePoints(
            LatLng(wLat, wLng),
            LatLng(widget.centerLat, widget.centerLng),
          );
          if (routePoints.length >= 2) {
            polylines.add(
              Polyline(
                polylineId: const PolylineId('live_route'),
                color: AppColors.primary,
                width: 5,
                points: routePoints,
                patterns: [PatternItem.dash(12), PatternItem.gap(6)],
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _markers = markers;
          _polylines = polylines;
        });
      }
    } catch (e) {
      debugPrint('Google Maps marker build notice — falling back to canvas: $e');
      if (mounted) setState(() => _useGoogleMaps = false);
    }
  }

  List<LatLng> _buildRoutePoints(LatLng a, LatLng b) {
    final points = <LatLng>[];
    const steps = 20;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final lat = a.latitude + (b.latitude - a.latitude) * t;
      final lngOffset = 0.0008 * t * (1 - t) * 40;
      final lng = a.longitude + (b.longitude - a.longitude) * t + lngOffset;
      points.add(LatLng(lat, lng));
    }
    return points;
  }

  @override
  void didUpdateWidget(CustomMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workers.length != widget.workers.length ||
        oldWidget.activeBooking?.id != widget.activeBooking?.id ||
        oldWidget.workerLiveLat != widget.workerLiveLat ||
        oldWidget.workerLiveLng != widget.workerLiveLng) {
      _liveLat = widget.workerLiveLat ?? _liveLat;
      _liveLng = widget.workerLiveLng ?? _liveLng;
      _buildMarkersAndPolylines();
    }
  }

  @override
  void dispose() {
    _workerLocationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_useGoogleMaps) {
      return _buildCanvasFallback();
    }
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.centerLat, widget.centerLng),
                zoom: 14.0,
              ),
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              trafficEnabled: false,
              indoorViewEnabled: false,
              buildingsEnabled: true,
              zoomControlsEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) {
                if (!_mapController.isCompleted) {
                  _mapController.complete(controller);
                }
              },
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.showLiveWorkerTracking
                          ? Icons.location_searching
                          : Icons.people_alt_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.showLiveWorkerTracking
                          ? 'Live Tracking'
                          : '${widget.workers.length} Co-op Pins',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.showLiveWorkerTracking && _liveLat != null)
              Positioned(
                bottom: 12,
                left: 12,
                child: Consumer<BookingProvider>(
                  builder: (_, prov, _) {
                    final b = prov.currentActiveBooking ?? widget.activeBooking;
                    final wLat = _liveLat ?? b?.workerLiveLat;
                    final wLng = _liveLng ?? b?.workerLiveLng;
                    double distanceKm = 0;
                    if (wLat != null && wLng != null) {
                      final dLat = (wLat - widget.centerLat) * 111.0;
                      final dLng = (wLng - widget.centerLng) * 85.0;
                      distanceKm = (dLat * dLat + dLng * dLng).abs() < 1e-6
                          ? 0
                          : (dLat * dLat + dLng * dLng) / 2;
                      distanceKm = distanceKm < 0 ? 0 : distanceKm;
                      distanceKm = distanceKm > 5 ? 5 : distanceKm;
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      child: Text(
                        '🛵 ${widget.workerNameForLive ?? ''} • ${distanceKm.toStringAsFixed(1)} km away • ETA ${(distanceKm * 4).toStringAsFixed(0)} min',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasFallback() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _MapGridPainter()),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
                  ),
                  child: const Icon(Icons.home, color: Colors.white, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: const Text('You (Home)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          ...widget.workers.take(4).map((w) {
            final idx = widget.workers.indexOf(w);
            final double dx = (idx == 0 ? 50.0 : idx == 1 ? -60.0 : idx == 2 ? 70.0 : -50.0);
            final double dy = (idx == 0 ? -45.0 : idx == 1 ? -40.0 : idx == 2 ? 45.0 : 50.0);
            return Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: Offset(dx, dy),
                child: GestureDetector(
                  onTap: () {
                    if (widget.onWorkerSelected != null) widget.onWorkerSelected!(w);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                        ),
                        child: const Icon(Icons.handyman, color: Colors.white, size: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
                        ),
                        child: Text(
                          '${w.name} (${w.distanceKm}km)',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Text(
                '${widget.workers.length} Co-op Pins Nearby',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 3;

    canvas.drawLine(Offset(0, size.height * 0.35), Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(Offset(0, size.height * 0.68), Offset(size.width, size.height * 0.65), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.35, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.72, 0), Offset(size.width * 0.68, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
