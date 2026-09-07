import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../models/worker.dart';
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
  late Worker _worker;
  String _selectedDate = 'Today, 02 Sep 2026';
  String _selectedTime = '10:00 AM - 11:00 AM';
  final TextEditingController _addressController = TextEditingController(
    text: '123, 4th Cross, Koramangala 5th Block, Bengaluru - 560034',
  );

  @override
  void initState() {
    super.initState();
    _worker = widget.worker ??
        const Worker(
          id: 'wrk_kumar',
          name: 'Kumar',
          skill: 'AC Technician',
          rating: 4.6,
          reviewsCount: 142,
          distanceKm: 2.4,
          latitude: 12.9352,
          longitude: 77.6245,
          isVerified: true,
          hourlyRate: 350.0,
          phone: '+91 98450 11223',
          cooperativeName: 'Independent Skilled Worker',
          bio: 'AC Technician & Cooling Specialist',
        );
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
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
                    // Top Worker Summary Card with 3D Depth
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: App3D.card3D(
                        backgroundColor: Colors.white,
                        borderRadius: 20,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.primaryContainer,
                              child: Text(
                                _worker.name.isNotEmpty ? _worker.name[0] : 'K',
                                style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_worker.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(_worker.cooperativeName, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: AppColors.rating, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_worker.rating} • ${_worker.distanceKm} km away',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main Service Configuration Card with 3D Depth
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
                          _buildFieldRow(label: 'Service', value: _worker.skill),
                          const Divider(height: 30, color: AppColors.border),
                          _buildClickableRow(
                            label: 'Date',
                            value: _selectedDate,
                            icon: Icons.calendar_today_outlined,
                            onTap: _selectDate,
                          ),
                          const Divider(height: 30, color: AppColors.border),
                          _buildClickableRow(
                            label: 'Time',
                            value: _selectedTime,
                            icon: Icons.access_time_rounded,
                            onTap: _selectTime,
                          ),
                          const Divider(height: 30, color: AppColors.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Address', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              GestureDetector(
                                onTap: _changeAddress,
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit_location_alt_outlined, size: 15, color: AppColors.primaryLight),
                                    SizedBox(width: 4),
                                    Text('Change on Map', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
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
                          const Divider(height: 30, color: AppColors.border),
                          _buildFieldRow(
                            label: 'Estimated Cost',
                            value: '₹${_worker.hourlyRate.toInt()}',
                            isBoldValue: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Bar with 3D Elevated Button
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
                      const Text('Total Payable', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      Text(
                        '₹${_worker.hourlyRate.toInt()}',
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
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final bookingProv = Provider.of<BookingProvider>(context, listen: false);

                        final bookingId = 'SC${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
                        final newBooking = Booking(
                          id: bookingId,
                          workerId: _worker.id,
                          workerName: _worker.name,
                          workerSkill: _worker.skill,
                          workerPhone: _worker.phone,
                          workerCoop: _worker.cooperativeName.isNotEmpty ? _worker.cooperativeName : 'Chennai Labour Cooperative Society',
                          householdId: auth.currentUser?.id ?? 'usr_house_01',
                          householdName: auth.currentUser?.name ?? 'Harijith M',
                          householdPhone: auth.currentUser?.phone ?? '+91 98765 12345',
                          serviceAddress: _addressController.text.trim(),
                          amount: _worker.hourlyRate > 0 ? _worker.hourlyRate : 350.0,
                          scheduledDate: _selectedDate,
                          scheduledTime: _selectedTime,
                          notes: 'Service requested via Cooperative Gig Platform',
                          status: BookingStatus.requested,
                          createdAt: DateTime.now(),
                        );

                        bookingProv.setActiveBooking(newBooking);
                        bookingProv.createBooking(
                          householdId: auth.currentUser?.id ?? 'usr_house_01',
                          workerId: _worker.id,
                          workerName: _worker.name,
                          workerSkill: _worker.skill,
                          workerPhone: _worker.phone,
                          serviceAddress: _addressController.text.trim(),
                          amount: _worker.hourlyRate > 0 ? _worker.hourlyRate : 350.0,
                          scheduledDate: _selectedDate,
                          scheduledTime: _selectedTime,
                          notes: 'Service requested via Cooperative Gig Platform',
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
                          Text('Confirm Booking', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.check_circle_outline_rounded, size: 18),
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

  Widget _buildFieldRow({required String label, required String value, bool isBoldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontSize: isBoldValue ? 18 : 14,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
            color: isBoldValue ? AppColors.primary : AppColors.textPrimary,
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: AppColors.primaryLight),
            ],
          ),
        ],
      ),
    );
  }
}
