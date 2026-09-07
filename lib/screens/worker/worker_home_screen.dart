import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../models/user.dart';
import '../../models/assignment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/api_service.dart';
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
  String _availabilityStatus = 'available'; // available, unavailable, working, leave
  List<BookingAssignment> _assignments = [];
  bool _isLoadingAssignments = false;

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
    final workerId = auth.currentUser?.id ?? 'wrk_1';

    await bookingProv.fetchWorkerBookings(workerId);
    await _fetchAssignments(workerId);
  }

  Future<void> _fetchAssignments(String workerId) async {
    setState(() => _isLoadingAssignments = true);
    try {
      final list = await ApiService().getWorkerAssignments(workerId);
      if (mounted) {
        setState(() {
          _assignments = list;
          _isLoadingAssignments = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAssignments = false);
    }
  }

  void _updateAvailability(String newStatus) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final workerId = auth.currentUser?.id ?? 'wrk_1';

    setState(() => _availabilityStatus = newStatus);
    await ApiService().updateWorkerAvailabilityStatus(workerId, newStatus);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Availability status updated to: ${newStatus.toUpperCase()} (Cooperative verification preserved)'),
        backgroundColor: newStatus == 'available' ? AppColors.statusCompleted : AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _acceptAssignment(BookingAssignment asgn) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final workerId = auth.currentUser?.id ?? 'wrk_1';

    final success = await ApiService().acceptWorkerAssignment(workerId, asgn.id);
    if (!mounted) return;

    if (success) {
      setState(() {
        final idx = _assignments.indexWhere((a) => a.id == asgn.id);
        if (idx != -1) {
          _assignments[idx] = BookingAssignment(
            id: asgn.id,
            bookingId: asgn.bookingId,
            workerId: asgn.workerId,
            status: 'ACCEPTED',
            distanceKm: asgn.distanceKm,
            matchingScore: asgn.matchingScore,
            assignmentSequence: asgn.assignmentSequence,
            serviceName: asgn.serviceName,
            serviceAddress: asgn.serviceAddress,
            scheduledTime: asgn.scheduledTime,
            assignedAt: asgn.assignedAt,
            acceptedAt: DateTime.now(),
            cooperativeName: asgn.cooperativeName,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Accepted Gig #${asgn.bookingId}! Proceed to client address when scheduled.'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );
    }
  }

  void _rejectAssignment(BookingAssignment asgn) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final workerId = auth.currentUser?.id ?? 'wrk_1';

    final success = await ApiService().rejectWorkerAssignment(workerId, asgn.id, reason: 'Worker busy');
    if (!mounted) return;

    if (success) {
      setState(() {
        _assignments.removeWhere((a) => a.id == asgn.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment declined. Engine will re-route to next eligible co-op member.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bookingProv = Provider.of<BookingProvider>(context);
    final activeJob = bookingProv.activeWorkerJob;
    final incomingRequests = bookingProv.workerBookings.where((b) => b.status == BookingStatus.requested).toList();
    final completedCount = bookingProv.workerBookings.where((b) => b.status == BookingStatus.completed).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cooperative Worker Dashboard'),
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
              // Worker Profile & Association Verification Badge
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
                          Text(auth.currentUser?.cooperativeName ?? 'Labour Cooperative Society', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.statusCompletedBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: AppColors.statusCompleted),
                        SizedBox(width: 4),
                        Text('Association Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.statusCompleted)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Phase 3 4-State Availability Management Card
              Container(
                padding: const EdgeInsets.all(16),
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
                        const Text('Operational Availability', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _availabilityStatus == 'available'
                                ? AppColors.statusCompletedBg
                                : (_availabilityStatus == 'working' ? const Color(0xFFFEF3C7) : AppColors.surfaceVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _availabilityStatus.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _availabilityStatus == 'available'
                                  ? AppColors.statusCompleted
                                  : (_availabilityStatus == 'working' ? const Color(0xFFB45309) : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Changes allocation dispatch status only. Association membership & pre-verified status remain fully intact.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),

                    // 4-Pill Availability Selector
                    Row(
                      children: [
                        _buildStatusPill('Available', 'available', Icons.check_circle_rounded, AppColors.statusCompleted),
                        const SizedBox(width: 8),
                        _buildStatusPill('Working', 'working', Icons.build_circle_rounded, const Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        _buildStatusPill('On Leave', 'leave', Icons.beach_access_rounded, const Color(0xFF6366F1)),
                        const SizedBox(width: 8),
                        _buildStatusPill('Offline', 'unavailable', Icons.do_not_disturb_on_rounded, AppColors.textTertiary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Phase 3 Metrics Overview
              _buildMetricsRow(
                assignedCount: _assignments.length,
                upcomingCount: incomingRequests.length,
                completedCount: completedCount,
              ),
              const SizedBox(height: 20),

              // Phase 3 Automatically Allocated Jobs Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Assigned Gigs (Auto-Allocated)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_assignments.length} Allocated',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoadingAssignments)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else if (_assignments.isEmpty)
                _buildEmptyAssignmentsCard()
              else
                ..._assignments.map((asgn) => _buildAssignmentCard(asgn)),

              const SizedBox(height: 24),

              // Active Job Screen / Status Card (with Check-In / Check-Out shortcut)
              if (activeJob != null) ...[
                const Text('Active Service Gig', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildActiveJobCard(activeJob),
                const SizedBox(height: 24),
              ],

              // Earnings Summary Card
              _buildEarningsCard(),
              const SizedBox(height: 24),

              // Past Gigs
              const Text('Completed Gig History', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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

  Widget _buildStatusPill(String label, String value, IconData icon, Color color) {
    final bool isSelected = _availabilityStatus == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _updateAvailability(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? color : AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsRow({
    required int assignedCount,
    required int upcomingCount,
    required int completedCount,
  }) {
    return Row(
      children: [
        _buildMetricItem('Assigned Gigs', '$assignedCount', Icons.assignment_turned_in_rounded, AppColors.primary),
        const SizedBox(width: 10),
        _buildMetricItem('Upcoming', '$upcomingCount', Icons.pending_actions_rounded, const Color(0xFFD97706)),
        const SizedBox(width: 10),
        _buildMetricItem('Completed', '$completedCount', Icons.verified_rounded, AppColors.statusCompleted),
        const SizedBox(width: 10),
        _buildMetricItem('Workload', 'Balanced', Icons.balance_rounded, const Color(0xFF6366F1)),
      ],
    );
  }

  Widget _buildMetricItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: App3D.card3D(
          backgroundColor: Colors.white,
          borderRadius: 14,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(title, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(BookingAssignment asgn) {
    final bool isAssigned = asgn.status == 'ASSIGNED';
    final bool isAccepted = asgn.status == 'ACCEPTED';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: App3D.card3D(
        backgroundColor: Colors.white,
        borderRadius: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Specialist #${asgn.assignmentSequence}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (asgn.distanceKm != null)
                    Text(
                      '${asgn.distanceKm!.toStringAsFixed(1)} km away',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAccepted ? AppColors.statusCompletedBg : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  asgn.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAccepted ? AppColors.statusCompleted : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(asgn.serviceName ?? 'Cooperative Gig Service', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 3),
          Text(asgn.serviceAddress ?? 'Koramangala, Bengaluru', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Scheduled: ${asgn.scheduledTime ?? 'Today, Scheduled'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
          if (asgn.matchingScore != null) ...[
            const SizedBox(height: 4),
            Text('Deterministic Ranking Score: ${asgn.matchingScore!.toStringAsFixed(1)} / 100', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          ],

          if (isAssigned) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusCancelled,
                      side: const BorderSide(color: AppColors.statusCancelled),
                    ),
                    onPressed: () => _rejectAssignment(asgn),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCompleted),
                    onPressed: () => _acceptAssignment(asgn),
                    child: const Text('Accept Gig', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyAssignmentsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 32, color: AppColors.statusCompleted),
              SizedBox(height: 6),
              Text('No pending assignments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 2),
              Text('Automatic allocation engine will dispatch upcoming bookings here.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
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
              Text('Fair Wage Protected', style: TextStyle(color: Colors.white70, fontSize: 12)),
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
            SizedBox(
              width: double.infinity,
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
}
