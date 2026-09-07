import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/worker_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_map_widget.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/worker_card.dart';
import 'service_picker_screen.dart';
import 'book_service_screen.dart';
import 'bulk_booking_screen.dart';
import 'emergency_booking_screen.dart';

class HouseholdHomeScreen extends StatefulWidget {
  const HouseholdHomeScreen({super.key});

  @override
  State<HouseholdHomeScreen> createState() => _HouseholdHomeScreenState();
}

class _HouseholdHomeScreenState extends State<HouseholdHomeScreen> {
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final workerProv = Provider.of<WorkerProvider>(context, listen: false);
    final bookingProv = Provider.of<BookingProvider>(context, listen: false);

    await Future.wait([
      workerProv.fetchWorkers(),
      bookingProv.fetchHouseholdBookings(auth.currentUser?.id ?? 'usr_house_01'),
    ]);
  }

  void _openCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ServicePickerScreen(),
    );
  }

  void _triggerEmergencySos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencyBookingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final workerProv = Provider.of<WorkerProvider>(context);
    final bookingProv = Provider.of<BookingProvider>(context);
    final activeBooking = bookingProv.activeHouseholdBooking;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Co-op Home Services'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list_rounded : Icons.map_outlined, color: AppColors.primary),
            tooltip: _showMap ? 'List View' : 'Map View',
            onPressed: () => setState(() => _showMap = !_showMap),
          ),
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
              // User Greeting & Address
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name[0].toUpperCase() : 'H',
                      style: const TextStyle(color: AppColors.primaryDark, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${auth.currentUser?.name ?? "Member"} 👋',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                auth.currentUser?.address ?? 'Bengaluru Central',
                                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                        Text(
                          'Supabase Live',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // "Request a Service" Call to Action Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need Help at Home?',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Book cooperative-verified electricians, plumbers, cleaners, and caregivers with fair fixed rates.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add_task_rounded, size: 20, color: AppColors.primary),
                      label: const Text('Request a Service', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      onPressed: _openCategoryPicker,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Phase 2 Quick Actions: 24/7 Emergency SOS + Institutional Bulk Hub
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _triggerEmergencySos,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: App3D.card3D(
                          backgroundColor: const Color(0xFFFEF2F2),
                          borderRadius: 16,
                          border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('24/7 SOS', style: TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold, fontSize: 13.5)),
                                  Text('Instant Emergency', style: TextStyle(color: Color(0xFFB91C1C), fontSize: 10.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BulkBookingScreen()),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: App3D.card3D(
                          backgroundColor: const Color(0xFFEEF2FF),
                          borderRadius: 16,
                          border: Border.all(color: const Color(0xFFC7D2FE), width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Color(0xFF4F46E5), shape: BoxShape.circle),
                              child: const Icon(Icons.domain_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Bulk Booking', style: TextStyle(color: Color(0xFF3730A3), fontWeight: FontWeight.bold, fontSize: 13.5)),
                                  Text('Multi-Trade Teams', style: TextStyle(color: Color(0xFF4338CA), fontSize: 10.5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Active Booking Status Card (if any pending/accepted/in_progress)
              if (activeBooking != null) ...[
                _buildActiveBookingCard(activeBooking),
                const SizedBox(height: 24),
              ],

              // Horizontal Scrollable Service Category Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Explore Services',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: _openCategoryPicker,
                    child: const Text('All (8)'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 105,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.categories.length,
                  itemBuilder: (context, index) {
                    final cat = AppConstants.categories[index];
                    final isSelected = workerProv.selectedCategory == cat.skillParam;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          workerProv.selectCategory(cat.skillParam);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 66,
                              height: 66,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : cat.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : cat.color.withValues(alpha: 0.25),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                cat.icon,
                                color: isSelected ? Colors.white : cat.color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Map View vs List View
              if (_showMap) ...[
                const Text(
                  'Nearby Co-op Map View',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 240,
                  child: CustomMapWidget(
                    workers: workerProv.workers,
                    onWorkerSelected: (w) {
                      _showWorkerBookingSheet(w);
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Nearby Available Workers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Specialists Nearby',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        '${workerProv.workers.length} verified worker-owners ready',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  if (workerProv.selectedCategory != 'all')
                    ActionChip(
                      label: Text('Reset Filter: ${workerProv.selectedCategory}'),
                      onPressed: () => workerProv.selectCategory('all'),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (workerProv.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(28.0), child: CircularProgressIndicator()))
              else if (workerProv.workers.isEmpty)
                _buildEmptyWorkersCard()
              else
                ...workerProv.workers.map(
                  (worker) => WorkerCard(
                    worker: worker,
                    onBookNow: () => _showWorkerBookingSheet(worker),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBookingCard(dynamic booking) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final bookingProv = Provider.of<BookingProvider>(context, listen: false);
          bookingProv.setActiveBooking(booking);
          Navigator.pushNamed(context, '/booking_detail', arguments: booking);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: booking.status),
                  Text(
                    '${booking.scheduledDate} • ${booking.scheduledTime}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryContainer,
                    radius: 20,
                    child: Text(
                      booking.workerName.isNotEmpty ? booking.workerName[0] : 'W',
                      style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.workerName,
                          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${booking.workerSkill} • ${booking.workerCoop}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12.5),
                    ),
                    onPressed: () {
                      final bookingProv = Provider.of<BookingProvider>(context, listen: false);
                      bookingProv.setActiveBooking(booking);
                      Navigator.pushNamed(context, '/booking_detail', arguments: booking);
                    },
                    child: const Text('Track'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWorkersCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      child: const Padding(
        padding: EdgeInsets.all(28.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 40, color: AppColors.textTertiary),
              SizedBox(height: 10),
              Text('No workers available for selected category', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Try selecting "All" or choosing another trade.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkerBookingSheet(dynamic worker) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookServiceScreen(worker: worker),
      ),
    );
  }
}
