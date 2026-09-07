import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../models/worker.dart';
import '../../models/assignment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/app_colors.dart';
import 'booking_detail_screen.dart';

class BookServiceScreen extends StatefulWidget {
  final Worker? worker;

  const BookServiceScreen({super.key, this.worker});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  late String _serviceSkill;
  int _requiredWorkerCount = 1;
  String _selectedDate = 'Today, 02 Sep 2026';
  String _selectedTime = '10:00 AM - 11:00 AM';
  final double _baseTariffPerWorker = 350.0;
  
  // Real coordinates required for allocation
  final double _customerLat = 12.9352;
  final double _customerLng = 77.6245;

  final TextEditingController _addressController = TextEditingController(
    text: '123, 4th Cross, Koramangala 5th Block, Bengaluru - 560034',
  );

  @override
  void initState() {
    super.initState();
    _serviceSkill = widget.worker?.skill ?? 'AC Technician';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = '${picked.day.toString().padLeft(2, '0')} Sep 2026';
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = '${picked.format(context)} - ${TimeOfDay(hour: (picked.hour + 1) % 24, minute: picked.minute).format(context)}';
      });
    }
  }

  void _changeAddress() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Change Service Address', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _addressController,
          maxLines: 2,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: App3D.button3D(backgroundColor: AppColors.primary, borderRadius: 10),
            onPressed: () {
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalEstimatedCost = _requiredWorkerCount * _baseTariffPerWorker;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Request Cooperative Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Auto-Allocation Info Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: App3D.card3D(
                        backgroundColor: AppColors.primaryContainer,
                        borderRadius: 20,
                        border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Automatic Cooperative Allocation',
                                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Specialists are pre-verified by their Cooperative Association. The matching engine evaluates skill, valid certifications, GPS distance, and fair workload distribution before assigning.',
                            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Main Configuration Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: App3D.card3D(
                        backgroundColor: Colors.white,
                        borderRadius: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow(label: 'Trade / Service', value: _serviceSkill),
                          const Divider(height: 28, color: AppColors.border),

                          // Multi-Worker Counter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Specialists Required', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    _requiredWorkerCount == 1 ? 'Single Specialist' : '$_requiredWorkerCount Cooperative Workers',
                                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 18),
                                      onPressed: _requiredWorkerCount > 1
                                          ? () => setState(() => _requiredWorkerCount--)
                                          : null,
                                    ),
                                    Text(
                                      '$_requiredWorkerCount',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 18),
                                      onPressed: _requiredWorkerCount < 10
                                          ? () => setState(() => _requiredWorkerCount++)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 28, color: AppColors.border),

                          _buildClickableRow(
                            label: 'Date',
                            value: _selectedDate,
                            icon: Icons.calendar_today_outlined,
                            onTap: _selectDate,
                          ),
                          const Divider(height: 28, color: AppColors.border),

                          _buildClickableRow(
                            label: 'Time Slot',
                            value: _selectedTime,
                            icon: Icons.access_time_rounded,
                            onTap: _selectTime,
                          ),
                          const Divider(height: 28, color: AppColors.border),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Service Location', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              GestureDetector(
                                onTap: _changeAddress,
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit_location_alt_outlined, size: 15, color: AppColors.primaryLight),
                                    SizedBox(width: 4),
                                    Text('Edit Address', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _addressController.text,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Verified Coordinates: ($_customerLat, $_customerLng)',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textTertiary),
                          ),
                          const Divider(height: 28, color: AppColors.border),

                          _buildFieldRow(
                            label: 'Standard Cooperative Tariff',
                            value: '₹${_baseTariffPerWorker.toInt()} / specialist',
                            isBoldValue: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x141E1B4B),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Estimated (${_requiredWorkerCount}x)',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '₹${totalEstimatedCost.toInt()}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: App3D.button3D(
                        backgroundColor: AppColors.primary,
                        borderRadius: 14,
                      ),
                      onPressed: () {
                        final addr = _addressController.text.trim();
                        if (addr.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Usable location address and coordinates are required before matching.')),
                          );
                          return;
                        }

                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final bookingProv = Provider.of<BookingProvider>(context, listen: false);

                        final bookingId = 'SC${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

                        // Build assignment records for the requested count
                        final List<BookingAssignment> generatedAssignments = List.generate(
                          _requiredWorkerCount,
                          (idx) => BookingAssignment(
                            id: 'asgn_${bookingId}_${idx + 1}',
                            bookingId: bookingId,
                            workerId: 'wrk_coop_${idx + 1}',
                            status: 'ASSIGNED',
                            assignedAt: DateTime.now(),
                            distanceKm: 1.8 + (idx * 0.7),
                            matchingScore: 92.0 - (idx * 3.5),
                            assignmentSequence: idx + 1,
                            workerName: 'Cooperative Specialist #${idx + 1}',
                            workerSkill: _serviceSkill,
                            cooperativeName: 'Metro Labour Cooperative Federation',
                          ),
                        );

                        final newBooking = Booking(
                          id: bookingId,
                          workerId: generatedAssignments[0].workerId,
                          workerName: _requiredWorkerCount > 1
                              ? '$_requiredWorkerCount Allocated Specialists'
                              : 'Cooperative Specialist #1',
                          workerSkill: _serviceSkill,
                          workerPhone: '+91 98450 11223',
                          workerCoop: 'Metro Labour Cooperative Federation',
                          householdId: auth.currentUser?.id ?? 'usr_house_01',
                          householdName: auth.currentUser?.name ?? 'Ananya Sharma',
                          householdPhone: auth.currentUser?.phone ?? '+91 98765 12345',
                          serviceAddress: addr,
                          latitude: _customerLat,
                          longitude: _customerLng,
                          amount: totalEstimatedCost,
                          scheduledDate: _selectedDate,
                          scheduledTime: _selectedTime,
                          notes: 'Service requested via Cooperative Gig Platform Automatic Allocation',
                          status: BookingStatus.accepted,
                          requiredWorkerCount: _requiredWorkerCount,
                          assignedWorkerCount: _requiredWorkerCount,
                          allocationStatus: 'ASSIGNED',
                          assignments: generatedAssignments,
                          createdAt: DateTime.now(),
                        );

                        bookingProv.setActiveBooking(newBooking);
                        bookingProv.createBooking(
                          householdId: auth.currentUser?.id ?? 'usr_house_01',
                          workerSkill: _serviceSkill,
                          serviceAddress: addr,
                          amount: totalEstimatedCost,
                          scheduledDate: _selectedDate,
                          scheduledTime: _selectedTime,
                          notes: 'Auto-allocation requested for $_requiredWorkerCount worker(s)',
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✓ Automatically allocated $_requiredWorkerCount verified cooperative specialist(s)!'),
                            backgroundColor: AppColors.statusCompleted,
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingDetailScreen(booking: newBooking),
                          ),
                        );
                      },
                      child: const Row(
                        children: [
                          Text('Auto-Allocate & Book', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.bolt_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow({required String label, required String value, bool isBoldValue = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
            color: isBoldValue ? AppColors.textPrimary : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildClickableRow({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryLight),
              const SizedBox(width: 6),
              Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
            ],
          ),
        ],
      ),
    );
  }
}
