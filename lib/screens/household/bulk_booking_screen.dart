import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/bulk_booking.dart';
import '../../services/api_service.dart';

class BulkBookingScreen extends StatefulWidget {
  const BulkBookingScreen({super.key});

  @override
  State<BulkBookingScreen> createState() => _BulkBookingScreenState();
}

class _BulkBookingScreenState extends State<BulkBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController(text: 'Prestige Ozone Community Association');
  final _contactPersonController = TextEditingController(text: 'Harijith M (Estate Manager)');
  final _contactPhoneController = TextEditingController(text: '+91 98765 12345');
  final _addressController = TextEditingController(text: 'Block D, Prestige Ozone, Whitefield, Bengaluru');
  final _notesController = TextEditingController(text: 'Society annual deep maintenance & electrical overhaul');

  final String _scheduledDate = 'Tomorrow, 08 Sep 2026';
  final String _scheduledTime = '09:00 AM - 05:00 PM';
  bool _isEmergency = false;
  bool _isSubmitting = false;

  final Map<String, int> _tradeQuantities = {
    'Deep Cleaners': 4,
    'Electricians': 2,
    'Plumbers': 1,
    'Carpenters': 1,
    'Gardening Staff': 2,
  };

  final Map<String, double> _tradeRates = {
    'Deep Cleaners': 300.0,
    'Electricians': 380.0,
    'Plumbers': 350.0,
    'Carpenters': 400.0,
    'Gardening Staff': 280.0,
  };

  int get _totalWorkers => _tradeQuantities.values.fold(0, (sum, q) => sum + q);

  double get _totalEstimatedCost {
    double base = 0.0;
    _tradeQuantities.forEach((trade, qty) {
      final rate = _tradeRates[trade] ?? 350.0;
      base += qty * rate * 4.0; // 4 hour standard block
    });
    return _isEmergency ? base * 1.25 : base;
  }

  Future<void> _submitBulkBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_totalWorkers == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 worker for the team dispatch.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final tradeItems = _tradeQuantities.entries
        .where((e) => e.value > 0)
        .map((e) => BulkBookingItem(
              id: '',
              tradeName: e.key,
              quantityRequested: e.value,
              ratePerWorker: _tradeRates[e.key] ?? 350.0,
            ))
        .toList();

    final result = await ApiService().createBulkBooking(
      institutionName: _institutionController.text.trim(),
      contactPerson: _contactPersonController.text.trim(),
      contactPhone: _contactPhoneController.text.trim(),
      serviceAddress: _addressController.text.trim(),
      scheduledDate: _scheduledDate,
      scheduledTime: _scheduledTime,
      trades: tradeItems,
      isEmergency: _isEmergency,
      notes: _notesController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.statusCompleted, size: 28),
            SizedBox(width: 10),
            Expanded(child: Text('Bulk Order Dispatched!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Reference: ${result.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
            const SizedBox(height: 12),
            Text('A multi-trade cooperative team of $_totalWorkers verified specialists has been dispatched.'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Manpower:'),
                      Text('$_totalWorkers Workers', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tariff Estimate:'),
                      Text('₹${_totalEstimatedCost.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Back to Home'),
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
        title: const Text('Institutional Bulk Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: App3D.card3D(
                    backgroundColor: const Color(0xFF1E1B4B),
                    borderRadius: 18,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.domain_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Institutional Multi-Trade Hub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 4),
                            Text('Procure verified cooperative teams for campuses, societies, and companies with unified billing.',
                                style: TextStyle(color: Color(0xFFC7D2FE), fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Trade Selection Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: App3D.card3D(
                    backgroundColor: Colors.white,
                    borderRadius: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Select Trade Team Members', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('$_totalWorkers Selected', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark)),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.border, height: 24),
                      ..._tradeQuantities.keys.map((trade) {
                        final qty = _tradeQuantities[trade] ?? 0;
                        final rate = _tradeRates[trade] ?? 350.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(trade, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    Text('₹${rate.toStringAsFixed(0)}/hr standard tariff', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.surfaceVariant,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: qty > 0 ? () => setState(() => _tradeQuantities[trade] = qty - 1) : null,
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.primaryContainer,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    icon: const Icon(Icons.add, size: 16, color: AppColors.primaryDark),
                                    onPressed: () => setState(() => _tradeQuantities[trade] = qty + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Institutional Details Form Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: App3D.card3D(
                    backgroundColor: Colors.white,
                    borderRadius: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Delivery & Representative Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _institutionController,
                        decoration: const InputDecoration(
                          labelText: 'Institution / Society Name',
                          prefixIcon: Icon(Icons.apartment_rounded),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactPersonController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Representative',
                          prefixIcon: Icon(Icons.person_rounded),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Phone',
                          prefixIcon: Icon(Icons.phone_rounded),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Service Campus Address',
                          prefixIcon: Icon(Icons.location_on_rounded),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('24/7 Priority Emergency Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: const Text('Priority emergency dispatch with +25% tariff surcharge', style: TextStyle(fontSize: 11.5)),
                        value: _isEmergency,
                        onChanged: (val) => setState(() => _isEmergency = val),
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Cost Summary & Submit
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estimated Team Cost', style: TextStyle(fontSize: 12, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w600)),
                          Text('₹${_totalEstimatedCost.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                          Text('$_totalWorkers specialists • 4 hr standard block', style: const TextStyle(fontSize: 11, color: AppColors.onPrimaryContainer)),
                        ],
                      ),
                      ElevatedButton(
                        style: App3D.button3D(
                          backgroundColor: AppColors.primary,
                          borderRadius: 14,
                        ),
                        onPressed: _isSubmitting ? null : _submitBulkBooking,
                        child: _isSubmitting
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Dispatch Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
