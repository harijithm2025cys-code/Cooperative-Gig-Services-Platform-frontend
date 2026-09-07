import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/location_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/status_badge.dart';
import 'worker_active_job_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bookingProv = Provider.of<BookingProvider>(context, listen: false);
    await bookingProv.fetchWorkerBookings(auth.currentUser?.id ?? 'wrk_1');
  }

  void _acceptBooking(Booking booking) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bookingProv = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProv.updateStatus(booking.id, BookingStatus.accepted);
    if (!mounted) return;
    if (success) {
      try {
        await LocationService().startLiveTracking(
          workerId: auth.currentUser?.id ?? 'wrk_1',
          bookingId: booking.id,
        );
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Accepted job #${booking.id}! Live GPS tracking started.'), backgroundColor: AppColors.statusAccepted),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WorkerActiveJobScreen(job: booking.copyWith(status: BookingStatus.accepted))),
      );
    }
  }

  void _declineBooking(Booking booking) async {
    final bookingProv = Provider.of<BookingProvider>(context, listen: false);
    final success = await bookingProv.updateStatus(booking.id, BookingStatus.rejected);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job request declined.'), backgroundColor: AppColors.statusCancelled),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bookingProv = Provider.of<BookingProvider>(context);
    final activeJob = bookingProv.activeWorkerJob;
    final incomingRequests = bookingProv.workerBookings.where((b) => b.status == BookingStatus.requested).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Worker-Owner Dashboard'),
        actions: [
          PopupMenuButton<UserRole>(
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
            tooltip: 'Switch Portal Persona',
            onSelected: (role) {
              auth.switchRole(role);
              if (role == UserRole.cooperativeWorker || role == UserRole.independentWorker) {
                Navigator.pushReplacementNamed(context, AppRoutes.workerHome);
              } else if (role == UserRole.cooperativeAssociationHead || role == UserRole.superAdmin) {
                Navigator.pushReplacementNamed(context, '/admin_dashboard');
              } else {
                Navigator.pushReplacementNamed(context, AppRoutes.householdHome);
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: UserRole.customer, child: Text('1. Customer (Household)')),
              PopupMenuItem(value: UserRole.cooperativeWorker, child: Text('2. Co-op Worker-Owner')),
              PopupMenuItem(value: UserRole.independentWorker, child: Text('3. Independent Worker')),
              PopupMenuItem(value: UserRole.cooperativeAssociationHead, child: Text('4. Association Head')),
              PopupMenuItem(value: UserRole.superAdmin, child: Text('5. Super Admin (Federation)')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Worker Profile & Supabase DB Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name[0].toUpperCase() : 'W',
                          style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(auth.currentUser?.name ?? 'Worker-Owner', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(auth.currentUser?.cooperativeName ?? 'Labour Guild Member', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_done_rounded, size: 13, color: AppColors.primaryDark),
                        SizedBox(width: 4),
                        Text('Supabase Live', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Online / Offline Toggle
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isOnline ? AppColors.statusCompleted : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_isOnline ? 'Online & Available' : 'Offline', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                              Text(_isOnline ? 'Receiving nearest co-op gig dispatches' : 'Toggle on to receive job requests', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _isOnline,
                        activeTrackColor: AppColors.primary,
                        activeThumbColor: Colors.white,
                        onChanged: (val) {
                          setState(() => _isOnline = val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(val ? 'Status: Online' : 'Status: Offline'), duration: const Duration(seconds: 1)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Earnings Summary Card
              _buildEarningsCard(),
              const SizedBox(height: 24),

              // Active Job Screen / Status Card (with Check-In / Check-Out shortcut)
              if (activeJob != null) ...[
                const Text('Active Assigned Gig', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildActiveJobCard(activeJob),
                const SizedBox(height: 24),
              ],

              // Incoming Job Requests (Accept / Reject)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Incoming Job Requests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${incomingRequests.length} Pending',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (incomingRequests.isEmpty)
                _buildEmptyIncomingCard()
              else
                ...incomingRequests.map((b) => _buildIncomingRequestCard(b)),

              const SizedBox(height: 24),

              // Job History / Schedule
              const Text('All Scheduled & Past Gigs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...bookingProv.workerBookings
                  .where((b) => b.status != BookingStatus.requested)
                  .map((b) => _buildHistoryCard(b)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Earnings", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Direct 100% Payout', style: TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('₹1,450.00', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quarterly Co-op Dividend: +₹1,250', style: TextStyle(color: AppColors.rating, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Completed: 18 Gigs', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobCard(Booking job) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: job.status),
                Text('Payout: ₹${job.amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 10),
            Text(job.householdName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 2),
            Text(job.serviceAddress, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => WorkerActiveJobScreen(job: job)),
                      );
                    },
                    child: const Text('Check-In / Out Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingRequestCard(Booking booking) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Gig Request #${booking.id}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
                Text('₹${booking.amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 10),
            Text(booking.householdName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(booking.serviceAddress, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('${booking.scheduledDate} • ${booking.scheduledTime}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            if (booking.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Note: "${booking.notes}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusCancelled,
                      side: const BorderSide(color: AppColors.statusCancelled),
                    ),
                    onPressed: () => _declineBooking(booking),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusAccepted),
                    onPressed: () => _acceptBooking(booking),
                    child: const Text('Accept Job'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Booking booking) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: ListTile(
        title: Text(booking.householdName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
        subtitle: Text('${booking.serviceAddress} • ${booking.scheduledDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StatusBadge(status: booking.status, fontSize: 11),
            const SizedBox(height: 4),
            Text('₹${booking.amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyIncomingCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 36, color: AppColors.statusCompleted),
              SizedBox(height: 8),
              Text('All caught up!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              SizedBox(height: 2),
              Text('New household requests will appear here automatically.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            ],
          ),
        ),
      ),
    );
  }
}
