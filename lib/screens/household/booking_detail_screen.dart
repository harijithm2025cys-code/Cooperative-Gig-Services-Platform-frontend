import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../services/location_service.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_map_widget.dart';
import '../../services/razorpay_service.dart';
import 'rate_worker_dialog.dart';
import 'invoice_view_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final Booking? booking;
  const BookingDetailScreen({super.key, this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Booking? _booking;
  bool _isProcessing = false;
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.booking != null) {
      _booking = widget.booking;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_booking == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Booking) {
        _booking = args;
        Provider.of<BookingProvider>(context, listen: false).setActiveBooking(args);
      }
    } else {
      Provider.of<BookingProvider>(context, listen: false).setActiveBooking(_booking!);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  int _currentStepIndex(Booking b) {
    switch (b.status) {
      case BookingStatus.requested:
      case BookingStatus.rejected:
      case BookingStatus.cancelled:
        return 0;
      case BookingStatus.accepted:
      case BookingStatus.workerEnroute:
      case BookingStatus.arrived:
        return 1;
      case BookingStatus.verifiedCheckin:
      case BookingStatus.paymentPending:
      case BookingStatus.paymentReleased:
        return 2;
      case BookingStatus.inProgress:
        return 3;
      case BookingStatus.customerConfirmationPending:
        return 4;
      case BookingStatus.customerConfirmed:
      case BookingStatus.verifiedCheckout:
      case BookingStatus.completed:
        return 5;
    }
  }

  void _openLiveMapModal(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setMapState) => Container(
          height: MediaQuery.of(ctx).size.height * 0.80,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Live Worker GPS Tracking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('${booking.workerName} • ${booking.status.label}',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  decoration: App3D.card3D(borderRadius: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomMapWidget(
                      showHousehold: true,
                      showNearbyWorkers: false,
                      showLiveWorkerTracking: true,
                      workerIdForLive: booking.workerId,
                      workerNameForLive: booking.workerName,
                      serviceLatitude: 12.9352,
                      serviceLongitude: 77.6245,
                      activeBooking: booking,
                      workerLiveLat: booking.workerLiveLat,
                      workerLiveLng: booking.workerLiveLng,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                      label: const Text('Call Worker', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => _openCallModal(booking.workerName, booking.workerPhone),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: App3D.button3D(backgroundColor: AppColors.primary, borderRadius: 14),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.white),
                      label: const Text('Live Chat'),
                      onPressed: () => _openChatModal(booking.workerName),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> _handleVerifyCheckIn(Booking booking) async {
    final pos = await LocationService().getCurrentPosition();
    if (!mounted) return;
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit check-in OTP shared with worker')),
      );
      return;
    }
    setState(() => _isProcessing = true);
    final bookingProv = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProv.verifyCheckIn(
      bookingId: booking.id,
      verifierRole: 'household',
      method: 'otp_match',
      otpCode: otp,
      householdLat: pos?.latitude ?? 0,
      householdLng: pos?.longitude ?? 0,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _otpController.clear();
    if (success) {
      final updated = bookingProv.currentActiveBooking ?? booking;
      setState(() => _booking = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updated.bothVerifiedCheckin
              ? 'Dual verification complete! You may now release payment to escrow.'
              : 'Your check-in recorded. Waiting for worker to also verify check-in.'),
          backgroundColor: AppColors.statusInProgress,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in verification failed. Confirm OTP matches worker.')),
      );
    }
  }

  Future<void> _handleVerifyCheckOut(Booking booking) async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit check-out OTP shared by worker')),
      );
      return;
    }
    setState(() => _isProcessing = true);
    final bookingProv = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProv.verifyCheckOut(
      bookingId: booking.id,
      verifierRole: 'household',
      method: 'otp_match',
      otpCode: otp,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _otpController.clear();
    if (success) {
      final updated = bookingProv.currentActiveBooking ?? booking;
      setState(() => _booking = updated);
      if (updated.bothVerifiedCheckout) {
        _openRatingDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your check-out recorded. Waiting for worker to also confirm completion.'), backgroundColor: AppColors.statusCompleted),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out verification failed. Confirm OTP matches.')),
      );
    }
  }

  void _openRatingDialog() {
    if (_booking == null) return;
    showDialog(
      context: context,
      builder: (ctx) => RateWorkerDialog(booking: _booking!),
    ).then((rated) {
      if (rated == true && mounted) {
        final bookingProv = Provider.of<BookingProvider>(context, listen: false);
        final updated = bookingProv.householdBookings.firstWhere(
          (b) => b.id == _booking!.id,
          orElse: () => _booking!,
        );
        setState(() => _booking = updated);
      }
    });
  }

  Future<void> _handleRazorpayPayment(Booking booking) async {
    setState(() => _isProcessing = true);
    final amount = booking.amount > 0 ? booking.amount : 420.0;
    final order = await ApiService().createPaymentOrder(
      bookingId: booking.id,
      amount: amount,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create Razorpay order. Please try again.')),
      );
      return;
    }

    final resp = await RazorpayService().openCheckout(
      context: context,
      order: order,
      customerName: booking.householdName,
      customerEmail: 'customer@cooperativegig.in',
      customerPhone: booking.householdPhone,
      serviceTitle: '${booking.workerSkill} Service Booking',
    );

    if (resp != null && mounted) {
      setState(() => _isProcessing = true);
      final verifyRes = await ApiService().verifyPayment(
        razorpayOrderId: resp.razorpayOrderId,
        razorpayPaymentId: resp.razorpayPaymentId,
        razorpaySignature: resp.razorpaySignature,
        bookingId: booking.id,
      );
      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (verifyRes['payment_status'] == 'CAPTURED' || verifyRes['status'] == 'success') {
        final messenger = ScaffoldMessenger.of(context);
        final bookingProv = Provider.of<BookingProvider>(context, listen: false);
        await bookingProv.markPaymentCaptured(
          bookingId: booking.id,
          paymentId: resp.razorpayPaymentId,
          settlementStatus: 'PENDING',
        );
        if (!mounted) return;
        setState(() {
          _booking = _booking?.copyWith(
            paymentStatus: PaymentStatus.captured,
            paymentId: resp.razorpayPaymentId,
            settlementStatus: 'PENDING',
          );
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text('Payment ₹${amount.toInt()} CAPTURED via Razorpay! Settlement: PENDING completion.'),
            backgroundColor: AppColors.statusCompleted,
          ),
        );
      }
    }
  }

  Future<void> _showCustomerCompletionOtp(Booking booking) async {
    setState(() => _isProcessing = true);
    final data = await ApiService().getCompletionOtp(booking.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    final otpCode = data?['otp_code'] ?? '842196';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text('Completion Acceptance OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share this 6-digit OTP with your specialist ONLY after you have inspected and accepted the completed work:',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Text(
                otpCode,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, size: 14, color: AppColors.textTertiary),
                SizedBox(width: 4),
                Text('Valid for 15 minutes • Single-use', style: TextStyle(fontSize: 11.5, color: AppColors.textTertiary)),
              ],
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportDisputeDialog(Booking booking) {
    String selectedCategory = 'Service incomplete';
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.report_problem_rounded, color: AppColors.statusCancelled, size: 22),
              SizedBox(width: 8),
              Text('Report Service Problem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filing a dispute freezes settlement funds until your Cooperative Association Head reviews the case.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: [
                  'Service incomplete',
                  'Poor quality',
                  'Wrong service',
                  'Damage',
                  'Worker issue',
                  'Other',
                ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (v) => setDlgState(() => selectedCategory = v!),
              ),
              const SizedBox(height: 12),
              const Text('Explain the issue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              const SizedBox(height: 6),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe the issue or defect observed…',
                  hintStyle: const TextStyle(fontSize: 12),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.statusCancelled),
              onPressed: () async {
                final desc = descController.text.trim();
                if (desc.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please describe the issue.')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                setState(() => _isProcessing = true);
                final res = await ApiService().fileComplaint(
                  bookingId: booking.id,
                  category: selectedCategory,
                  description: desc,
                );
                if (!mounted) return;
                setState(() {
                  _isProcessing = false;
                  _booking = _booking?.copyWith(settlementStatus: 'DISPUTED');
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res != null
                        ? 'Dispute filed! Settlement frozen. Complaint #${res.id} under Association review.'
                        : 'Dispute recorded. Settlement frozen.'),
                    backgroundColor: AppColors.statusCancelled,
                  ),
                );
              },
              child: const Text('Submit Dispute'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInvoiceView(Booking booking) async {
    setState(() => _isProcessing = true);
    final inv = await ApiService().getInvoiceByBooking(booking.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (inv != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InvoiceViewScreen(
            invoice: inv,
            customerName: booking.householdName,
            customerPhone: booking.householdPhone,
            customerAddress: booking.serviceAddress,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not fetch invoice at this moment.')),
      );
    }
  }

  void _openCallModal(String name, String phone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.primaryLight.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.phone_in_talk_rounded, size: 36, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 16),
            Text('Calling $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(phone, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusCompletedBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
              ),
              child: const Text('Cooperative Secure Line • Encrypted', style: TextStyle(color: AppColors.statusCompleted, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.volume_up_rounded)),
                IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.mic_off_rounded)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusCancelled,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Icon(Icons.call_end_rounded, size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openChatModal(String name) {
    final textController = TextEditingController();
    final List<Map<String, String>> messages = [
      {'sender': 'worker', 'text': 'Hello! I am on my way with diagnostic tools.'},
      {'sender': 'worker', 'text': 'Will arrive in approximately 8 minutes.'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SizedBox(
            height: 420,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(name.isNotEmpty ? name[0] : 'W', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryDark)),
                        ),
                        const SizedBox(width: 8),
                        Text('Chat with $name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(color: AppColors.border),
                Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      final isMe = m['sender'] == 'me';
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.primary : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            m['text'] ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white : AppColors.textPrimary,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        label: const Text('I am at home', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setModalState(() {
                            messages.add({'sender': 'me', 'text': 'I am at home, please ring doorbell.'});
                          });
                        },
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        label: const Text('What is your ETA?', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setModalState(() {
                            messages.add({'sender': 'me', 'text': 'What is your expected time of arrival?'});
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: () {
                        if (textController.text.trim().isNotEmpty) {
                          setModalState(() {
                            messages.add({'sender': 'me', 'text': textController.text.trim()});
                          });
                          textController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProv = Provider.of<BookingProvider>(context);
    final booking = (bookingProv.currentActiveBooking != null && bookingProv.currentActiveBooking!.id == _booking?.id)
        ? bookingProv.currentActiveBooking!
        : (_booking ??
            Booking(
              id: 'SC10245',
              workerId: 'wrk_1',
              workerName: 'Kumar',
              workerSkill: 'AC Technician',
              workerPhone: '+91 98450 11223',
              workerCoop: 'Independent Professional',
              householdId: 'usr_house_01',
              householdName: 'Harijith M',
              householdPhone: '+91 98765 12345',
              serviceAddress: '123, 4th Cross, Koramangala 5th Block, Bengaluru - 560034',
              status: BookingStatus.requested,
              amount: 420.0,
              scheduledDate: 'Today, 02 Sep 2026',
              scheduledTime: '10:00 AM - 11:00 AM',
              createdAt: DateTime.now(),
            ));
    _booking = booking;
    final step = _currentStepIndex(booking);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Service Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary)),
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(booking),
              const SizedBox(height: 20),
              _buildEtaAndTrackingCard(booking),
              if (booking.requiredWorkerCount > 1) ...[
                const SizedBox(height: 20),
                _buildMultiWorkerStatusCard(booking),
              ],
              const SizedBox(height: 20),
              _buildStepperCard(step, booking),
              const SizedBox(height: 20),
              _buildOtpCard(booking),
              const SizedBox(height: 20),
              _buildDualVerificationCard(booking),
              if (booking.status == BookingStatus.customerConfirmationPending) ...[
                const SizedBox(height: 20),
                _buildCustomerInspectionCard(booking),
              ],
              if (booking.status == BookingStatus.customerConfirmed || booking.status == BookingStatus.completed) ...[
                const SizedBox(height: 20),
                _buildCompletedInvoiceCard(booking),
              ],
              const SizedBox(height: 20),
              _buildBookingDetailsCard(booking),
              const SizedBox(height: 24),

              // Phase 5 Actions & Razorpay Integration
              if (booking.status != BookingStatus.completed &&
                  booking.status != BookingStatus.customerConfirmed &&
                  booking.status != BookingStatus.cancelled) ...[
                if (booking.paymentStatus != PaymentStatus.captured && booking.paymentStatus != PaymentStatus.released) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: App3D.button3D(
                        backgroundColor: const Color(0xFF0C2340),
                        borderRadius: 14,
                      ),
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.bolt_rounded, color: Color(0xFF00BAF2), size: 22),
                      label: Text(_isProcessing
                              ? 'PREPARING RAZORPAY CHECKOUT...'
                              : 'PAY ₹${(booking.amount > 0 ? booking.amount : 420).toInt()} VIA RAZORPAY →',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      onPressed: _isProcessing ? null : () => _handleRazorpayPayment(booking),
                    ),
                  ),
                  const SizedBox(height: 14),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.statusCompletedBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.statusCompleted, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Payment Captured (₹${(booking.amount > 0 ? booking.amount : 420).toInt()}) • Settlement: ${booking.settlementStatus}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.statusCompleted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.near_me_rounded, size: 20),
                    label: const Text('TRACK WORKER ON LIVE MAP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    onPressed: () => _openLiveMapModal(booking),
                  ),
                ),
                // Pre-service Customer Cancellation Action
                if (booking.status == BookingStatus.requested ||
                    booking.status == BookingStatus.accepted ||
                    booking.status == BookingStatus.workerEnroute ||
                    booking.status == BookingStatus.arrived) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.statusCancelled,
                        side: const BorderSide(color: AppColors.statusCancelled, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel Booking (Free Before Service Starts)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () => _openCancelConfirmation(booking),
                    ),
                  ),
                ],
              ] else if (booking.status == BookingStatus.cancelled) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: App3D.card3D(
                    backgroundColor: const Color(0xFFFEE2E2),
                    borderRadius: 18,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cancel_outlined, color: AppColors.statusCancelled, size: 36),
                      const SizedBox(height: 8),
                      const Text('Booking Cancelled',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF991B1B))),
                      const SizedBox(height: 4),
                      Text(
                        booking.cancellationReason ?? 'This request was cancelled. No charges have been applied.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF991B1B)),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // When Completed & Paid
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: App3D.card3D(
                    backgroundColor: AppColors.statusCompletedBg,
                    borderRadius: 18,
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.statusCompleted, size: 36),
                      const SizedBox(height: 8),
                      const Text('Service Completed & Escrow Paid!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF166534))),
                      const SizedBox(height: 4),
                      Text('Payment of ₹${(booking.amount > 0 ? booking.amount : 420).toInt()} transferred to ${booking.workerName} (Co-op Member).',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF166534))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.star_rate_rounded),
                    label: const Text('Rate Worker-Owner Performance', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _openRatingDialog,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openCancelConfirmation(Booking booking) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.statusCancelled, size: 24),
            SizedBox(width: 8),
            Text('Cancel Booking?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cancellation is free of charge before service starts. Any assigned cooperative specialists will be immediately reallocated.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Reason for cancellation (optional)',
                hintStyle: const TextStyle(fontSize: 12.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.statusCancelled),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isProcessing = true);
              final reason = reasonController.text.trim();
              await ApiService().cancelCustomerBooking(booking.id, reason: reason.isNotEmpty ? reason : null);
              if (!mounted) return;
              final updated = booking.copyWith(
                status: BookingStatus.cancelled,
                cancellationReason: reason.isNotEmpty ? reason : 'Customer cancelled',
              );
              Provider.of<BookingProvider>(context, listen: false).setActiveBooking(updated);
              setState(() {
                _isProcessing = false;
                _booking = updated;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Booking cancelled successfully. Specialist released.'),
                  backgroundColor: AppColors.statusCancelled,
                ),
              );
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildEtaAndTrackingCard(Booking booking) {
    final bool isTracking = booking.status == BookingStatus.workerEnroute ||
        booking.status == BookingStatus.accepted ||
        booking.status == BookingStatus.arrived;
    if (!isTracking) return const SizedBox.shrink();

    final String etaDisplay = booking.etaFormatted ??
        (booking.status == BookingStatus.arrived
            ? 'Arrived at your doorstep'
            : '~12 mins (approx. 5.1 km @ 25 km/h)');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: App3D.card3D(
        backgroundColor: Colors.white,
        borderRadius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.navigation_rounded, color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Live ETA & Journey Tracking',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      booking.status == BookingStatus.arrived
                          ? 'Specialist has arrived at your premises'
                          : 'Realistic transit estimate (25 km/h city average)',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled_rounded, color: AppColors.primaryDark, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    etaDisplay,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Live Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => _openLiveMapModal(booking),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiWorkerStatusCard(Booking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Multi-Specialist Team: ${booking.assignedWorkerCount} of ${booking.requiredWorkerCount} Allocated',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Each cooperative specialist operates with independent arrival and check-in confirmation.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Booking booking) {
    final bool isCancelled = booking.status == BookingStatus.cancelled;
    final bool isDone = booking.status == BookingStatus.completed;
    final bool isPending = booking.status == BookingStatus.requested;
    final bool isEnroute = booking.status == BookingStatus.accepted || booking.status == BookingStatus.workerEnroute;
    final Color heroColor = isCancelled
        ? AppColors.statusCancelled
        : isDone
            ? AppColors.statusCompleted
            : isPending
                ? AppColors.primary
                : isEnroute
                    ? AppColors.statusAccepted
                    : AppColors.statusInProgress;
    final IconData heroIcon = isCancelled
        ? Icons.cancel_outlined
        : isDone
            ? Icons.check
            : isPending
                ? Icons.hourglass_top_rounded
                : isEnroute
                    ? Icons.two_wheeler_rounded
                    : Icons.build_rounded;
    final String heroTitle = isCancelled
        ? 'Booking Cancelled'
        : isDone
            ? 'Booking Completed!'
            : isPending
                ? 'Request Sent to Worker'
                : isEnroute
                    ? 'Worker Dispatched'
                    : booking.status.label;
    final String heroSub = isCancelled
        ? (booking.cancellationReason ?? 'This booking was cancelled and specialists released.')
        : isPending
            ? 'Waiting for ${booking.workerName} to accept your request…'
            : 'Order #${booking.id} • ${booking.workerSkill}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: App3D.card3D(
        backgroundColor: Colors.white,
        borderRadius: 22,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: heroColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: heroColor.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(heroIcon, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            heroTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            heroSub,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDDD6FE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, color: AppColors.primaryLight, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Worker assigned: ${booking.workerName}',
                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperCard(int currentStep, Booking booking) {
    final List<Map<String, dynamic>> steps = [
      {'title': 'Request Sent', 'subtitle': 'Request dispatched to worker', 'icon': Icons.send_rounded},
      {'title': 'Worker Accepted', 'subtitle': 'Worker accepted & en route', 'icon': Icons.two_wheeler_rounded},
      {'title': 'Check-In Verified + Payment', 'subtitle': 'Dual OTP + GPS verified; escrow paid', 'icon': Icons.verified_user_rounded},
      {'title': 'Service In Progress', 'subtitle': 'Worker performing the service', 'icon': Icons.build_rounded},
      {'title': 'Check-Out + Complete', 'subtitle': 'Dual check-out; payout released', 'icon': Icons.check_circle_rounded, 'isLast': true},
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: App3D.card3D(
        backgroundColor: Colors.white,
        borderRadius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Service Progress (5-Step FSM)', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          for (int i = 0; i < steps.length; i++)
            _buildStep(
              isDone: i < currentStep,
              isCurrent: i == currentStep,
              title: steps[i]['title'],
              subtitle: steps[i]['subtitle'],
              icon: steps[i]['icon'],
              isLast: steps[i]['isLast'] ?? false,
            ),
        ],
      ),
    );
  }

  Widget _buildOtpCard(Booking booking) {
    if (booking.verificationOtp == null || booking.verificationOtp!.isEmpty) {
      return const SizedBox.shrink();
    }
    if (booking.status == BookingStatus.requested ||
        booking.status == BookingStatus.rejected ||
        booking.status == BookingStatus.cancelled) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: App3D.card3D(
        backgroundColor: AppColors.primaryContainer,
        borderRadius: 16,
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Shared Dual-Verification OTP', style: TextStyle(fontSize: 12, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(booking.verificationOtp!,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 8, color: AppColors.primaryDark)),
              const SizedBox(height: 2),
              const Text('Share this with worker when they arrive',
                  style: TextStyle(fontSize: 11, color: AppColors.onPrimaryContainer, fontWeight: FontWeight.w500)),
            ],
          ),
          const Icon(Icons.password_rounded, size: 36, color: AppColors.primaryLight),
        ],
      ),
    );
  }

  Widget _buildDualVerificationCard(Booking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: App3D.card3D(
        backgroundColor: Colors.white,
        borderRadius: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dual Verification Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          _buildVerifyBadgeRow(
            label: 'Step 3: Check-In Verification',
            hVerified: booking.householdVerifiedCheckin,
            wVerified: booking.workerVerifiedCheckin,
            hLabel: 'You Verified',
            wLabel: 'Worker Verified',
          ),
          if (!booking.householdVerifiedCheckin &&
              (booking.status == BookingStatus.accepted ||
                  booking.status == BookingStatus.workerEnroute ||
                  booking.status == BookingStatus.inProgress)) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.pin_rounded, size: 16),
                label: const Text('Enter Check-In OTP', style: TextStyle(fontSize: 12)),
                onPressed: () => _showOtpDialog(
                  title: 'Verify Worker Check-In',
                  hint: 'Enter the 6-digit OTP to confirm worker arrived',
                  onConfirm: () => _handleVerifyCheckIn(booking),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _buildVerifyBadgeRow(
            label: 'Step 5: Check-Out Verification',
            hVerified: booking.householdVerifiedCheckout,
            wVerified: booking.workerVerifiedCheckout,
            hLabel: 'You Confirmed',
            wLabel: 'Worker Confirmed',
          ),
          if (booking.householdVerifiedCheckin && !booking.householdVerifiedCheckout && booking.status == BookingStatus.inProgress) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.pin_rounded, size: 16),
                label: const Text('Enter Completion OTP', style: TextStyle(fontSize: 12)),
                onPressed: () => _showOtpDialog(
                  title: 'Verify Work Completion',
                  hint: 'Enter the 6-digit OTP to complete job',
                  onConfirm: () => _handleVerifyCheckOut(booking),
                ),
              ),
            ),
          ],
          if (booking.paymentStatus != PaymentStatus.pending) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: booking.paymentStatus == PaymentStatus.heldInEscrow
                    ? AppColors.primaryContainer
                    : booking.paymentStatus == PaymentStatus.released
                        ? AppColors.statusCompletedBg
                        : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    booking.paymentStatus == PaymentStatus.heldInEscrow
                        ? Icons.savings_rounded
                        : booking.paymentStatus == PaymentStatus.released
                            ? Icons.check_circle
                            : Icons.error_outline_rounded,
                    size: 18,
                    color: booking.paymentStatus == PaymentStatus.released
                        ? AppColors.statusCompleted
                        : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Payment: ${booking.paymentStatus.name}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerifyBadgeRow({
    required String label,
    required bool hVerified,
    required bool wVerified,
    required String hLabel,
    required String wLabel,
  }) {
    final both = hVerified && wVerified;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            if (both)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusCompletedBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.4)),
                ),
                child: const Text('✓ BOTH VERIFIED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.statusCompleted)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('⏳ PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: hVerified ? AppColors.statusCompletedBg : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: hVerified ? AppColors.statusCompleted.withValues(alpha: 0.4) : AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(hVerified ? Icons.check_circle_rounded : Icons.hourglass_empty_rounded,
                        size: 16, color: hVerified ? AppColors.statusCompleted : AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(hLabel,
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.bold,
                            color: hVerified ? AppColors.statusCompleted : AppColors.textTertiary)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  color: wVerified ? AppColors.statusCompletedBg : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: wVerified ? AppColors.statusCompleted.withValues(alpha: 0.4) : AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(wVerified ? Icons.check_circle_rounded : Icons.hourglass_empty_rounded,
                        size: 16, color: wVerified ? AppColors.statusCompleted : AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(wLabel,
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.bold,
                            color: wVerified ? AppColors.statusCompleted : AppColors.textTertiary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerInspectionCard(Booking booking) {
    final bool isDisputed = booking.settlementStatus == 'DISPUTED';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDisputed ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDisputed ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (isDisputed ? Colors.red : Colors.green).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDisputed ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDisputed ? Icons.warning_amber_rounded : Icons.verified_rounded,
                  color: isDisputed ? AppColors.statusCancelled : AppColors.statusCompleted,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDisputed ? 'Service Dispute Under Review' : 'Service Completed • Inspect Work',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                        color: isDisputed ? const Color(0xFF991B1B) : const Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDisputed
                          ? 'Settlement frozen • Association Head reviewing'
                          : 'Specialist finished. Inspect quality before releasing OTP.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDisputed ? const Color(0xFFB91C1C) : const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isDisputed
                ? 'A dispute has been recorded. Payment remains safely held. The Labour Cooperative Association Head will contact you and inspect the resolution.'
                : 'Please inspect the delivered service carefully. When satisfied, provide the 6-digit confirmation OTP to your technician to confirm completion.',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          if (!isDisputed) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusCompleted,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.key_rounded, size: 20),
                label: const Text('Show 6-Digit Acceptance OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                onPressed: () => _showCustomerCompletionOtp(booking),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.statusCancelled,
                  side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.report_problem_outlined, size: 18),
                label: const Text('Not Satisfied? Report Problem / Dispute', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                onPressed: () => _showReportDisputeDialog(booking),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedInvoiceCard(Booking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryDark, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Official Tax Receipt & Invoice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.statusCompletedBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
                ),
                child: const Text('SETTLED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: AppColors.statusCompleted)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Invoice #${booking.invoiceId ?? 'INV-20260907-0042'} • GST 18% (SAC 998713)',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('View Tax Invoice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  onPressed: () => _openInvoiceView(booking),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.star_rounded, size: 18),
                  label: const Text('Rate Worker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  onPressed: _openRatingDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard(Booking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: App3D.card3D(
        backgroundColor: Colors.white,
        borderRadius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Booking & Allocation Details', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusAcceptedBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.statusAccepted.withValues(alpha: 0.3)),
                ),
                child: Text(
                  booking.allocationStatus,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.statusAccepted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Service Category:', booking.workerSkill),
          const SizedBox(height: 10),
          _buildDetailRow('Workers Requested:', '${booking.requiredWorkerCount} Specialist(s)'),
          const SizedBox(height: 10),
          _buildDetailRow('Workers Assigned:', '${booking.assignedWorkerCount} Specialist(s)'),
          const SizedBox(height: 10),
          _buildDetailRow('Cooperative Society:', booking.workerCoop.isNotEmpty ? booking.workerCoop : 'Bengaluru Labour Guild Co-op'),
          const SizedBox(height: 10),
          _buildDetailRow('Scheduled Time:', '${booking.scheduledDate} · ${booking.scheduledTime}'),
          const SizedBox(height: 10),
          _buildDetailRow('Service Location:', booking.serviceAddress),
          if (booking.assignments != null && booking.assignments!.isNotEmpty) ...[
            const Divider(height: 24, color: AppColors.border),
            const Text('Assigned Cooperative Specialists:', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ...booking.assignments!.map((asgn) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    child: Text('${asgn.assignmentSequence}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(asgn.workerName ?? 'Verified Specialist #${asgn.assignmentSequence}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                        Text('${asgn.workerSkill ?? booking.workerSkill} • ${asgn.status}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  if (asgn.distanceKm != null)
                    Text('${asgn.distanceKm!.toStringAsFixed(1)} km away', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primaryLight)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildStep({
    required bool isDone,
    required bool isCurrent,
    required String title,
    required String subtitle,
    required IconData icon,
    bool isLast = false,
  }) {
    final color = isDone
        ? AppColors.statusCompleted
        : (isCurrent ? AppColors.primary : AppColors.textTertiary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDone ? AppColors.statusCompleted : AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
                boxShadow: isDone
                    ? [BoxShadow(color: AppColors.statusCompleted.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))]
                    : null,
              ),
              child: Center(
                child: Icon(icon, size: 15, color: isDone ? Colors.white : color),
              ),
            ),
            if (!isLast)
              Container(
                width: 2.5,
                height: 40,
                color: isDone ? AppColors.statusCompleted : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                if (!isLast) const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
