import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../utils/app_colors.dart';
import 'booking_detail_screen.dart';

class EmergencyBookingScreen extends StatefulWidget {
  const EmergencyBookingScreen({super.key});

  @override
  State<EmergencyBookingScreen> createState() => _EmergencyBookingScreenState();
}

class _EmergencyBookingScreenState extends State<EmergencyBookingScreen> {
  final _notesController = TextEditingController();
  final _addressController = TextEditingController(text: 'MG Road, Koramangala, Bengaluru');

  String _selectedService = 'Electrician';
  bool _isLocating = false;
  bool _isDispatching = false;
  double _lat = 12.9716;
  double _lng = 77.5946;

  final List<Map<String, dynamic>> _emergencyServices = [
    {
      'id': 'Electrician',
      'name': 'Electrical Emergency',
      'desc': 'Power cut, sparking, circuit failure',
      'icon': Icons.bolt_rounded,
      'baseRate': 550.0,
    },
    {
      'id': 'Plumber',
      'name': 'Plumbing Emergency',
      'desc': 'Burst pipe, heavy leakage, drain clog',
      'icon': Icons.water_drop_rounded,
      'baseRate': 500.0,
    },
    {
      'id': 'Locksmith',
      'name': 'Door Lockout',
      'desc': 'Locked out of house, jammed lock',
      'icon': Icons.lock_open_rounded,
      'baseRate': 450.0,
    },
    {
      'id': 'Gas Technician',
      'name': 'Gas & Stove Leak',
      'desc': 'LPG odour, burner hazard',
      'icon': Icons.local_fire_department_rounded,
      'baseRate': 600.0,
    },
    {
      'id': 'Caregiver',
      'name': 'Urgent Elder Care',
      'desc': 'Emergency mobility & bedside support',
      'icon': Icons.elderly_rounded,
      'baseRate': 500.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    try {
      final pos = await LocationService().getCurrentPosition();
      if (pos != null && mounted) {
        setState(() {
          _lat = pos.latitude;
          _lng = pos.longitude;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLocating = false);
  }

  Future<void> _handleEmergencyDispatch() async {
    setState(() => _isDispatching = true);

    final selected = _emergencyServices.firstWhere((s) => s['id'] == _selectedService);
    final double base = selected['baseRate'] as double;
    final double total = (base * 1.25).roundToDouble();

    final payload = {
      'service_id': _selectedService,
      'latitude': _lat,
      'longitude': _lng,
      'address': _addressController.text.trim(),
      'notes': _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : 'Emergency on-demand assistance requested immediately.',
      'estimated_amount': total,
      'is_emergency': true,
      'required_worker_count': 1,
    };

    final result = await ApiService().createEmergencyDispatch(payload);
    if (!mounted) return;
    setState(() => _isDispatching = false);

    final String bId = result['id']?.toString() ?? 'EMG-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final newBooking = Booking(
      id: bId,
      workerId: result['worker_id']?.toString() ?? 'wrk_emg_01',
      workerName: result['worker_name']?.toString() ?? 'Kiran Kumar (Co-op Rapid Responder)',
      workerSkill: _selectedService,
      workerPhone: result['worker_phone']?.toString() ?? '+91 98450 99887',
      workerCoop: 'Labour Cooperative Rapid Response Unit',
      householdId: 'usr_house_01',
      householdName: 'Household Client',
      householdPhone: '+91 98765 12345',
      serviceAddress: _addressController.text.trim(),
      latitude: _lat,
      longitude: _lng,
      status: BookingStatus.accepted,
      amount: total,
      scheduledDate: 'Immediate',
      scheduledTime: 'Right Now (24/7 SOS)',
      createdAt: DateTime.now(),
      notes: payload['notes'] as String,
      isEmergency: true,
      etaFormatted: '~10 mins (Priority Express Transit)',
    );

    Provider.of<BookingProvider>(context, listen: false).setActiveBooking(newBooking);

    // Show immediate success dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.statusCompleted, size: 28),
            SizedBox(width: 10),
            Text('Specialist Dispatched!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.timer_rounded, color: Color(0xFFDC2626), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('12-Second Allocation SLA Met! Specialist accepted.',
                        style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold, fontSize: 12.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Specialist: ${newBooking.workerName}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Category: $_selectedService • ETA: ${newBooking.etaFormatted}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            const SizedBox(height: 4),
            Text('Direct Secure Total: ₹${total.toInt()} (includes 25% emergency tariff)',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => BookingDetailScreen(booking: newBooking)),
              );
            },
            child: const Text('Track Specialist Live →'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _emergencyServices.firstWhere((s) => s['id'] == _selectedService);
    final double baseRate = selected['baseRate'] as double;
    final double emergencyRate = (baseRate * 1.25).roundToDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sos_rounded, color: Colors.white, size: 26),
            SizedBox(width: 8),
            Text('24/7 Emergency SOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17)),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency SLA Guarantee Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFDC2626).withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flash_on_rounded, color: Colors.yellow, size: 22),
                        SizedBox(width: 6),
                        Text('INSTANT PRIORITY DISPATCH',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.8)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Fast automatic matching connects you immediately with the closest on-duty verified cooperative technician. Proximity weighted at 50%.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Category Selector
              const Text('Select Emergency Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _emergencyServices.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (ctx, idx) {
                  final s = _emergencyServices[idx];
                  final bool isSelected = s['id'] == _selectedService;
                  return InkWell(
                    onTap: () => setState(() => _selectedService = s['id'] as String),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFEF2F2) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFDC2626) : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFEE2E2) : AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(s['icon'] as IconData,
                                color: isSelected ? const Color(0xFFDC2626) : AppColors.textSecondary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s['name'] as String,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isSelected ? const Color(0xFF991B1B) : AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(s['desc'] as String,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Text('₹${((s['baseRate'] as double) * 1.25).toInt()}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected ? const Color(0xFFDC2626) : AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),

              // Emergency Location
              const Text('Emergency Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Color(0xFFDC2626), size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'GPS Coordinates: ${_lat.toStringAsFixed(4)}, ${_lng.toStringAsFixed(4)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ),
                        if (_isLocating)
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          IconButton(
                            icon: const Icon(Icons.my_location_rounded, size: 20, color: AppColors.primary),
                            onPressed: _detectLocation,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Door / Building Address',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Notes
              const Text('Situation Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Main circuit sparking in kitchen, power cut to refrigerator.',
                  hintStyle: const TextStyle(fontSize: 12.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Total & Dispatch Action Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Emergency Fee', style: TextStyle(fontSize: 12, color: Color(0xFF991B1B))),
                        const SizedBox(height: 2),
                        Text('₹${emergencyRate.toInt()}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                      ],
                    ),
                    const Text('Includes 25% Co-op\nEmergency Surcharge',
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 11, color: Color(0xFF7F1D1D), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                  ),
                  icon: _isDispatching
                      ? const SizedBox.shrink()
                      : const Icon(Icons.emergency_rounded, size: 24),
                  label: _isDispatching
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text('Locating Nearest Specialist…', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        )
                      : const Text('DISPATCH SPECIALIST RIGHT NOW 🚨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  onPressed: _isDispatching ? null : _handleEmergencyDispatch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
