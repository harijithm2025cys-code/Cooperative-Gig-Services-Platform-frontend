import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../services/location_service.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_map_widget.dart';
import '../../widgets/status_badge.dart';

class WorkerActiveJobScreen extends StatefulWidget {
  final Booking job;

  const WorkerActiveJobScreen({super.key, required this.job});

  @override
  State<WorkerActiveJobScreen> createState() => _WorkerActiveJobScreenState();
}

class _WorkerActiveJobScreenState extends State<WorkerActiveJobScreen> {
  late Booking _job;
  bool _isProcessing = false;
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProv = Provider.of<BookingProvider>(context, listen: false);
      bookingProv.setActiveBooking(_job);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bookingProv = Provider.of<BookingProvider>(context);
    if (bookingProv.currentActiveBooking?.id == _job.id) {
      _job = bookingProv.currentActiveBooking!;
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _setStatus(BookingStatus newStatus) async {
    setState(() => _isProcessing = true);
    final bookingProv = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProv.updateStatus(_job.id, newStatus);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (success) {
      setState(() => _job = _job.copyWith(status: newStatus));
    }
  }

  Future<void> _handleEnroute() async {
    await _setStatus(BookingStatus.workerEnroute);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status: On the way. Household notified.'), backgroundColor: AppColors.primary),
      );
    }
  }

  Future<void> _handleArrived() async {
    await _setStatus(BookingStatus.arrived);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arrival confirmed! Please ring the doorbell.'), backgroundColor: AppColors.statusAccepted),
      );
    }
  }

  Future<void> _handleVerifyCheckIn() async {
    final pos = await LocationService().getCurrentPosition();
    if (!mounted) return;
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP from customer')),
      );
      return;
    }
    setState(() => _isProcessing = true);
    final bookingProv = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProv.verifyCheckIn(
      bookingId: _job.id,
      verifierRole: 'worker',
      method: 'otp_match',
      otpCode: otp,
      workerLat: pos?.latitude ?? 0,
      workerLng: pos?.longitude ?? 0,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (success) {
      final updated = Provider.of<BookingProvider>(context, listen: false).currentActiveBooking ?? _job;
      setState(() => _job = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_job.bothVerifiedCheckin
              ? 'Dual check-in verified! Waiting for household payment release…'
              : 'Your check-in recorded. Waiting for household to also verify.'),
          backgroundColor: AppColors.statusInProgress,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in failed. Verify OTP matches customer.')),
      );
    }
  }


  Future<void> _handleCompleteServiceRequest() async {
    setState(() => _isProcessing = true);
    final ok = await ApiService().completeWorkerService(
      _job.workerId,
      _job.id,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (ok) {
      final updated = _job.copyWith(
        status: BookingStatus.customerConfirmationPending,
      );
      setState(() => _job = updated);
      Provider.of<BookingProvider>(context, listen: false).setActiveBooking(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Work marked complete! Customer has received their 6-digit confirmation OTP.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _handleVerifyCustomerOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit OTP from customer')),
      );
      return;
    }
    setState(() => _isProcessing = true);
    final res = await ApiService().verifyWorkerCompletionOtp(
      workerId: _job.workerId,
      bookingId: _job.id,
      otpCode: otp,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _otpController.clear();
    if (res['status'] == 'success') {
      final updated = _job.copyWith(
        status: BookingStatus.completed,
        settlementStatus: 'ELIGIBLE',
        invoiceId: res['invoice_id'] as String?,
        workerVerifiedCheckout: true,
        householdVerifiedCheckout: true,
        checkOutTime: DateTime.now(),
      );
      setState(() => _job = updated);
      Provider.of<BookingProvider>(context, listen: false).markCustomerConfirmed(
        bookingId: _job.id,
        invoiceId: res['invoice_id'] as String?,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Completion OTP verified! Settlement is ELIGIBLE. Invoice ${res['invoice_id'] ?? ''} generated.'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['detail'] ?? res['message'] ?? 'OTP verification failed. Please re-check with customer.'),
          backgroundColor: AppColors.statusCancelled,
        ),
      );
    }
  }

  void _showOtpDialog({required String title, required VoidCallback onConfirm, required String hint}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hint, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            const SizedBox(height: 14),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                counterText: '',
                hintText: '• • • • • •',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 10),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _otpController.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final bookingProv = Provider.of<BookingProvider>(context);
    final liveJob = bookingProv.currentActiveBooking?.id == _job.id ? bookingProv.currentActiveBooking! : _job;
    _job = liveJob;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Active Gig #${_job.id}'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Live Job Status', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                          const SizedBox(height: 4),
                          StatusBadge(status: _job.status),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Direct Payout', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                          const SizedBox(height: 2),
                          Text(
                            '₹${_job.amount.toInt()}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomMapWidget(
                    showHousehold: true,
                    showNearbyWorkers: false,
                    showLiveWorkerTracking: false,
                    serviceLatitude: 12.9352,
                    serviceLongitude: 77.6245,
                    activeBooking: _job,
                    workerLiveLat: _job.workerLiveLat,
                    workerLiveLng: _job.workerLiveLng,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Customer & Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.primaryContainer,
                            child: Icon(Icons.person, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_job.householdName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(_job.householdPhone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.call, color: AppColors.primary),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Calling ${_job.householdPhone}...')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_job.serviceAddress, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                      if (_job.verificationOtp != null && _job.verificationOtp!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDDD6FE)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Shared Check-In OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.primaryDark)),
                              Text(_job.verificationOtp!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 4, color: AppColors.primaryDark)),
                            ],
                          ),
                        ),
                      ],
                      if (_job.notes.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Customer instructions: "${_job.notes}"',
                            style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dual Verification Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 14),
                      _buildVerifyRow(
                        label: 'Check-In (Both Sides)',
                        hVerified: _job.householdVerifiedCheckin,
                        wVerified: _job.workerVerifiedCheckin,
                        hTime: _job.householdCheckinTime,
                        wTime: _job.workerCheckinTime,
                        timeFormat: timeFormat,
                      ),
                      const SizedBox(height: 14),
                      _buildVerifyRow(
                        label: 'Check-Out (Both Sides)',
                        hVerified: _job.householdVerifiedCheckout,
                        wVerified: _job.workerVerifiedCheckout,
                        hTime: _job.householdCheckoutTime,
                        wTime: _job.workerCheckoutTime,
                        timeFormat: timeFormat,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              if (_job.status == BookingStatus.accepted) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.two_wheeler_rounded),
                    label: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Start Travelling → En Route', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: _isProcessing ? null : _handleEnroute,
                  ),
                ),
              ] else if (_job.status == BookingStatus.workerEnroute) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusAccepted),
                    icon: const Icon(Icons.location_on_rounded),
                    label: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('I Have Arrived at Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: _isProcessing ? null : _handleArrived,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.my_location_rounded, size: 18),
                    label: const Text('Transmit Live GPS Location to Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final pos = await LocationService().getCurrentPosition();
                      if (pos != null) {
                        await ApiService().pushWorkerAssignmentLocation(
                          assignmentId: _job.id,
                          latitude: pos.latitude,
                          longitude: pos.longitude,
                          bookingId: _job.id,
                          workerId: _job.workerId,
                        );
                        if (mounted) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('✓ Live GPS transmitted. Customer tracking map and ETA updated.'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ] else if (_job.status == BookingStatus.arrived ||
                  (_job.status == BookingStatus.verifiedCheckin && !_job.workerVerifiedCheckin)) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusInProgress),
                    icon: const Icon(Icons.verified_user_rounded),
                    label: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Verify Check-In (GPS + OTP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: _isProcessing
                        ? null
                        : () => _showOtpDialog(
                              title: 'Worker Check-In Verification',
                              hint: 'Ask the household for their 6-digit OTP and enter it here. Your GPS will also be auto-verified.',
                              onConfirm: _handleVerifyCheckIn,
                            ),
                  ),
                ),
              ] else if (_job.status == BookingStatus.verifiedCheckin && _job.bothVerifiedCheckin) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.payments_rounded, color: AppColors.primary),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text('Dual Check-In Verified! Waiting for household to release escrow payment before service starts.',
                                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.build_rounded),
                    label: const Text('Customer Paid - Begin Service Work', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await _setStatus(BookingStatus.inProgress);
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Service timer started.'), backgroundColor: AppColors.statusInProgress),
                        );
                      }
                    },
                  ),
                ),
              ] else if (_job.status == BookingStatus.inProgress) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCompleted),
                    icon: const Icon(Icons.task_alt_rounded),
                    label: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Mark Service Completed (Generate OTP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: _isProcessing ? null : _handleCompleteServiceRequest,
                  ),
                ),
              ] else if (_job.status == BookingStatus.customerConfirmationPending) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.hourglass_top_rounded, color: AppColors.statusCompleted),
                          SizedBox(width: 8),
                          Text('Service Finished • Customer Inspecting Work',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.statusCompleted)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The customer has received their 6-digit Acceptance OTP. Once they inspect and accept the completed work, ask for the code and enter it below to confirm completion and unlock payout eligibility.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusCompleted,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.pin_rounded, size: 20),
                          label: const Text('Enter Customer Confirmation OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          onPressed: _isProcessing
                              ? null
                              : () => _showOtpDialog(
                                    title: 'Customer Acceptance OTP',
                                    hint: 'Enter the 6-digit OTP provided by customer after inspection.',
                                    onConfirm: _handleVerifyCustomerOtp,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_job.status == BookingStatus.verifiedCheckout && !_job.bothVerifiedCheckout) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.statusCompletedBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.hourglass_top_rounded, color: AppColors.statusCompleted),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text('Your check-out recorded. Waiting for household to confirm completion.',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.statusCompleted)),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.statusCompletedBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.statusCompleted),
                      SizedBox(width: 8),
                      Text('Gig is marked as Completed', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.statusCompleted)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyRow({
    required String label,
    required bool hVerified,
    required bool wVerified,
    required DateTime? hTime,
    required DateTime? wTime,
    required DateFormat timeFormat,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: hVerified ? AppColors.statusCompletedBg : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: hVerified ? AppColors.statusCompleted.withValues(alpha: 0.4) : AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(hVerified ? Icons.check_circle : Icons.hourglass_empty_rounded,
                        size: 16, color: hVerified ? AppColors.statusCompleted : AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Household', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: hVerified ? AppColors.statusCompleted : AppColors.textTertiary)),
                          if (hTime != null)
                            Text(timeFormat.format(hTime), style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: wVerified ? AppColors.statusCompletedBg : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: wVerified ? AppColors.statusCompleted.withValues(alpha: 0.4) : AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(wVerified ? Icons.check_circle : Icons.hourglass_empty_rounded,
                        size: 16, color: wVerified ? AppColors.statusCompleted : AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('You (Worker)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: wVerified ? AppColors.statusCompleted : AppColors.textTertiary)),
                          if (wTime != null)
                            Text(timeFormat.format(wTime), style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
