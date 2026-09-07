import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Association Head Filters
  String _workerSkillFilter = '';

  // Super Admin Filters
  String _userRoleFilter = 'all';
  String _userSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isSuperAdmin = auth.currentUser?.isSuperAdmin == true;
    final length = isSuperAdmin ? 7 : 6;
    if (_tabController == null || _tabController!.length != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    if (auth.currentUser?.isSuperAdmin == true) {
      await admin.fetchSuperAdminData();
      await admin.fetchPhase7Analytics(isSuperAdmin: true);
    } else if (auth.currentUser?.isAssociationHead == true) {
      final coopId = auth.currentUser?.cooperativeId;
      await admin.fetchAssociationData(cooperativeId: coopId);
      await admin.fetchPhase7Analytics(cooperativeId: coopId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final admin = Provider.of<AdminProvider>(context);
    final user = auth.currentUser;

    final isSuperAdmin = user?.isSuperAdmin == true;
    final isAssocHead = user?.isAssociationHead == true;

    // Strict Role Escalation Block: Customer, Independent Worker, Co-op Worker cannot view administrative portal
    if (!isSuperAdmin && !isAssocHead) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Access Restricted'),
          backgroundColor: Colors.red.shade800,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gpp_bad_rounded, size: 72, color: Colors.red.shade700),
                const SizedBox(height: 20),
                const Text(
                  '403 — Administrative Access Denied',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'This management console is strictly restricted to Cooperative Association Heads and Platform Super Administrators.\n\nIndividual customers and workers cannot escalate permissions or access administrative operations.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {
                    if (user?.isCooperativeWorker == true || user?.isIndependentWorker == true) {
                      Navigator.pushReplacementNamed(context, AppRoutes.workerHome);
                    } else {
                      Navigator.pushReplacementNamed(context, AppRoutes.householdHome);
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Return to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSuperAdmin
                  ? 'State Apex Labour Federation'
                  : (user?.cooperativeName ?? 'Cooperative Association'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              isSuperAdmin
                  ? 'Super Administrator Platform Oversight'
                  : 'Association Head Management Console',
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
            ),
          ],
        ),
        backgroundColor: isSuperAdmin ? const Color(0xFF1E1B4B) : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Data',
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: isSuperAdmin
              ? const [
                  Tab(icon: Icon(Icons.dashboard_rounded), text: 'Platform Overview'),
                  Tab(icon: Icon(Icons.analytics_rounded), text: 'Analytics & ML'),
                  Tab(icon: Icon(Icons.people_alt_rounded), text: 'User Directory'),
                  Tab(icon: Icon(Icons.account_tree_rounded), text: 'Federation Tree'),
                  Tab(icon: Icon(Icons.badge_rounded), text: 'All Workers'),
                  Tab(icon: Icon(Icons.gavel_rounded), text: 'Disputes & Refunds'),
                  Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Audit Trail'),
                ]
              : const [
                  Tab(icon: Icon(Icons.dashboard_rounded), text: 'Overview'),
                  Tab(icon: Icon(Icons.analytics_rounded), text: 'Analytics & Utilization'),
                  Tab(icon: Icon(Icons.engineering_rounded), text: 'Workers'),
                  Tab(icon: Icon(Icons.list_alt_rounded), text: 'Services & Tariffs'),
                  Tab(icon: Icon(Icons.assignment_rounded), text: 'Bookings & Ops'),
                  Tab(icon: Icon(Icons.payments_rounded), text: 'Disputes & Financials'),
                ],
        ),
      ),
      body: admin.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: isSuperAdmin
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSuperAdminOverview(admin),
                        _buildSuperAdminPhase7Analytics(admin),
                        _buildSuperAdminUserDirectory(admin),
                        _buildSuperAdminFederationTree(admin),
                        _buildSuperAdminWorkers(admin),
                        _buildSuperAdminDisputes(admin),
                        _buildSuperAdminAuditLogs(admin),
                      ],
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAssociationOverview(admin, user),
                        _buildAssociationPhase7Analytics(admin, user),
                        _buildAssociationWorkers(admin),
                        _buildAssociationServices(admin),
                        _buildAssociationBookingsAndOperations(admin),
                        _buildAssociationDisputesAndFinancials(admin),
                      ],
                    ),
            ),
    );
  }

  // =========================================================================
  // ASSOCIATION HEAD VIEWS
  // =========================================================================

  Widget _buildAssociationOverview(AdminProvider admin, User? user) {
    final dash = admin.associationDashboard;
    final metrics = dash?['metrics'] as Map<String, dynamic>? ?? {};
    final analytics = admin.associationAnalytics?['aggregations'] as Map<String, dynamic>? ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Society Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: App3D.card3D(backgroundColor: Colors.white),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dash?['cooperative_name'] ?? user?.cooperativeName ?? 'Labour Cooperative Society',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'District: ${dash?['district'] ?? 'Central'} • Verified Society ✓',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // KPI Grid
        const Text('Operational Key Performance Indicators', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.45,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _kpiCard('Total Workers', '${metrics['total_workers'] ?? admin.associationWorkers.length}', Icons.engineering, Colors.blue),
            _kpiCard('Active Available', '${metrics['active_available_workers'] ?? 0}', Icons.check_circle, Colors.green),
            _kpiCard('Active Jobs', '${metrics['active_jobs'] ?? 0}', Icons.trending_up, Colors.orange),
            _kpiCard('Completed Bookings', '${metrics['completed_jobs'] ?? 0}', Icons.task_alt, Colors.teal),
            _kpiCard('Total Revenue', '₹${(metrics['total_revenue'] ?? 0.0).toStringAsFixed(0)}', Icons.currency_rupee, Colors.purple),
            _kpiCard('Pending Disputes', '${metrics['pending_disputes'] ?? admin.associationDisputes.length}', Icons.warning_amber, Colors.red),
          ],
        ),
        const SizedBox(height: 20),

        // Analytics Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: App3D.card3D(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Database Operational Aggregations', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statColumn('Completion Rate', '${analytics['completion_rate_percent'] ?? 100}%', Colors.teal),
                  _statColumn('Worker Utilization', '${analytics['worker_utilization_percent'] ?? 0}%', Colors.indigo),
                  _statColumn('Avg Worker Rating', '★ ${metrics['average_worker_rating'] ?? 4.9}', Colors.amber.shade800),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSelector(AdminProvider admin, {bool isSuperAdmin = false, String? coopId}) {
    final ranges = [
      {'key': 'today', 'label': 'Today'},
      {'key': 'last_7_days', 'label': '7 Days'},
      {'key': 'last_30_days', 'label': '30 Days'},
      {'key': 'this_month', 'label': 'This Month'},
      {'key': 'all_time', 'label': 'All Time'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ranges.map((r) {
          final isSelected = admin.selectedDateRange == r['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(r['label']!),
              selected: isSelected,
              selectedColor: isSuperAdmin ? const Color(0xFF1E1B4B) : AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              onSelected: (selected) {
                if (selected) {
                  admin.setDateRange(r['key']!, isSuperAdmin: isSuperAdmin, cooperativeId: coopId);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssociationPhase7Analytics(AdminProvider admin, User? user) {
    final coopId = user?.cooperativeId ?? 'coop_north_01';
    final analytics = admin.phase7AssociationAnalytics?['metrics'] as Map<String, dynamic>? ?? {};
    final demand = admin.serviceDemand ?? {};
    final workers = admin.workerUtilizationList;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date Range Selector
        _buildDateRangeSelector(admin, isSuperAdmin: false, coopId: coopId),
        const SizedBox(height: 12),

        // Scoped KPIs
        const Text('Cooperative Analytics & Utilization', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _kpiCard('Active Workers', '${analytics['active_workers'] ?? admin.associationWorkers.length}', Icons.engineering, Colors.blue),
            _kpiCard('Available Now', '${analytics['available_workers'] ?? 0}', Icons.check_circle_outline, Colors.green),
            _kpiCard('Coop Bookings', '${analytics['total_bookings'] ?? 0}', Icons.receipt_long, Colors.purple),
            _kpiCard('Completed', '${analytics['completed_bookings'] ?? 0}', Icons.task_alt, Colors.teal),
            _kpiCard('Avg Utilization', '${analytics['average_worker_utilization_percentage'] ?? 0}%', Icons.speed, Colors.indigo),
            _kpiCard('Service GMV', '₹${(analytics['service_value'] ?? 0.0).toStringAsFixed(0)}', Icons.currency_rupee, Colors.orange.shade800),
          ],
        ),
        const SizedBox(height: 20),

        // Worker Utilization Table
        Container(
          padding: const EdgeInsets.all(16),
          decoration: App3D.card3D(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.engineering_rounded, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Worker Utilization Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text('${workers.length} Members', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const Divider(height: 20),
              if (workers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: Text('No worker utilization data available for this range.')),
                )
              else
                ...workers.map((w) {
                  final util = (w['utilization_percentage'] ?? 0.0) as num;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(w['worker_name'] ?? 'Worker', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('★ ${w['rating'] ?? 4.8}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Skill: ${w['skill']} • Completed: ${w['completed_jobs']} • Active: ${w['active_jobs']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: (util / 100.0).clamp(0.0, 1.0),
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  util > 70 ? Colors.green : (util > 40 ? Colors.orange : Colors.blue),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('$util% Utilized', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

        // Service Demand Breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: App3D.card3D(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.pie_chart_rounded, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text('Service Demand Analytics', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statColumn('Peak Day', '${demand['peak_demand_day'] ?? 'Monday'}', Colors.teal),
                  _statColumn('Peak Hour', '${demand['peak_demand_hour'] ?? 10}:00', Colors.deepOrange),
                  _statColumn('Emergency Demand', '${demand['emergency_demand_percentage'] ?? 0}%', Colors.red),
                ],
              ),
              const SizedBox(height: 12),
              if (demand['bookings_per_service'] is List)
                ...((demand['bookings_per_service'] as List).take(5)).map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s['service_name'] ?? 'Service', style: const TextStyle(fontSize: 13)),
                      Text('${s['booking_count']} bookings (${s['percentage']}%)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                )),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // CSV Export Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading Scoped Cooperative Utilization & Demand CSV...')),
              );
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Export Cooperative Analytics (CSV)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssociationWorkers(AdminProvider admin) {
    final workers = admin.associationWorkers;
    return Column(
      children: [
        // Skill filter bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search worker name, skill, phone...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (val) {
              setState(() {
                _workerSkillFilter = val.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: workers.isEmpty
              ? _buildEmptyState('No workers registered under this cooperative.')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: workers.length,
                  itemBuilder: (ctx, idx) {
                    final w = workers[idx];
                    final name = w['name'] ?? 'Worker';
                    final skill = w['skill'] ?? 'General';
                    final phone = w['phone'] ?? 'N/A';

                    if (_workerSkillFilter.isNotEmpty &&
                        !name.toLowerCase().contains(_workerSkillFilter) &&
                        !skill.toLowerCase().contains(_workerSkillFilter)) {
                      return const SizedBox.shrink();
                    }

                    final isAvailable = w['is_available'] == true || w['availability'] == true;
                    final rating = (w['rating'] ?? 4.8).toDouble();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(name.isNotEmpty ? name[0] : 'W', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isAvailable ? 'Available' : 'Busy / Off',
                                style: TextStyle(fontSize: 11, color: isAvailable ? Colors.green.shade800 : Colors.red.shade800, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Skill: $skill • Phone: $phone'),
                            Text('Monthly Jobs: ${w['monthly_jobs'] ?? 6} • Fairness Score: ${w['fairness_score'] ?? 20} pts'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('★ $rating', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: 'Edit Profile & Availability',
                              onPressed: () => _showEditWorkerDialog(w),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showEditWorkerDialog(Map<String, dynamic> worker) {
    final phoneCtrl = TextEditingController(text: worker['phone'] ?? '');
    final skillCtrl = TextEditingController(text: worker['skill'] ?? '');
    bool isAvailable = worker['is_available'] == true || worker['availability'] == true;
    bool active = worker['active'] != false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text('Edit ${worker['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: skillCtrl,
                  decoration: const InputDecoration(labelText: 'Assigned Skill / Trade'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Contact Phone Number'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Open for Dispatches (Availability)'),
                  value: isAvailable,
                  onChanged: (val) => setDlgState(() => isAvailable = val),
                ),
                SwitchListTile(
                  title: const Text('Active Member Status'),
                  value: active,
                  onChanged: (val) => setDlgState(() => active = val),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: const Text(
                    'Notice: Worker verification badges are issued exclusively by Super Administrators.',
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                final admin = Provider.of<AdminProvider>(context, listen: false);
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final success = await admin.updateWorkerProfile(
                  workerId: worker['id'].toString(),
                  phone: phoneCtrl.text.trim(),
                  skill: skillCtrl.text.trim(),
                  isAvailable: isAvailable,
                  active: active,
                  cooperativeId: auth.currentUser?.cooperativeId,
                );
                messenger.showSnackBar(
                  SnackBar(content: Text(success ? 'Worker profile updated!' : 'Failed to update worker.')),
                );
              },
              child: const Text('Save Updates'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssociationServices(AdminProvider admin) {
    final services = admin.associationServices;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddServiceDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Approved Service'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: services.isEmpty
          ? _buildEmptyState('No services listed. Add an approved tariff offering.')
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: services.length,
              itemBuilder: (ctx, idx) {
                final s = services[idx];
                final name = s['name'] ?? 'Service';
                final category = s['category'] ?? 'General';
                final price = (s['base_price'] ?? 350.0).toDouble();
                final isActive = s['is_active'] != false;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        Text('₹$price', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Category: $category • Unit: ${s['unit'] ?? 'job'} • ${isActive ? 'Active ✓' : 'Unlisted'}'),
                        if (s['description'] != null) Text(s['description'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_note, size: 24),
                      onPressed: () => _showEditServiceDialog(s),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddServiceDialog() {
    final nameCtrl = TextEditingController();
    final catCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Approved Cooperative Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Service Name')),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Category (e.g. Plumbing, HVAC)')),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Base Tariff (INR)')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description / Scope')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final price = double.tryParse(priceCtrl.text.trim()) ?? 350.0;
              Navigator.pop(ctx);
              final admin = Provider.of<AdminProvider>(context, listen: false);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final success = await admin.createCooperativeService(
                name: nameCtrl.text.trim(),
                category: catCtrl.text.trim(),
                basePrice: price,
                description: descCtrl.text.trim(),
                cooperativeId: auth.currentUser?.cooperativeId,
              );
              messenger.showSnackBar(
                SnackBar(content: Text(success ? 'Service published to catalog!' : 'Failed to publish service.')),
              );
            },
            child: const Text('Create Service'),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(Map<String, dynamic> service) {
    final priceCtrl = TextEditingController(text: (service['base_price'] ?? 350).toString());
    final descCtrl = TextEditingController(text: service['description'] ?? '');
    bool isActive = service['is_active'] != false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text('Edit Tariff: ${service['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tariff Base Price (INR)')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              SwitchListTile(
                title: const Text('Listed in Catalog'),
                value: isActive,
                onChanged: (val) => setDlgState(() => isActive = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final price = double.tryParse(priceCtrl.text.trim());
                Navigator.pop(ctx);
                final admin = Provider.of<AdminProvider>(context, listen: false);
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final success = await admin.updateCooperativeService(
                  serviceId: service['id'].toString(),
                  basePrice: price,
                  description: descCtrl.text.trim(),
                  isActive: isActive,
                  cooperativeId: auth.currentUser?.cooperativeId,
                );
                messenger.showSnackBar(
                  SnackBar(content: Text(success ? 'Service tariff updated!' : 'Failed to update tariff.')),
                );
              },
              child: const Text('Save Tariff'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssociationBookingsAndOperations(AdminProvider admin) {
    final ops = admin.associationOperations;
    final bookings = admin.associationBookings;
    final asgns = admin.associationAssignments;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Live Operations Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Live Active Operations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
              child: Text('${ops.length} In Progress', style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (ops.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: App3D.card3D(),
            child: const Text('No active ongoing service runs right now.', style: TextStyle(color: AppColors.textSecondary)),
          )
        else
          ...ops.map((op) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(op['service_name'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.getStatusBgColor(op['status'] ?? ''), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              (op['status'] ?? 'Active').toUpperCase(),
                              style: TextStyle(fontSize: 11, color: AppColors.getStatusColor(op['status'] ?? ''), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Assigned Specialist: ${op['worker_name']} (${op['worker_phone']})'),
                      Text('Customer Premise: ${op['customer_address']}'),
                      if (op['eta_minutes'] != null)
                        Text('Approximate ETA: ~${op['eta_minutes']} mins', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue)),
                    ],
                  ),
                ),
              )),
        const SizedBox(height: 24),

        // Scoped Bookings History
        const Text('Scoped Society Bookings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (bookings.isEmpty)
          _buildEmptyState('No past bookings recorded.')
        else
          ...bookings.take(15).map((b) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(b['service_id'] ?? 'Booking', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ID: #${b['id']} • Status: ${b['status']} • Payment: ${b['payment_status'] ?? 'pending'}'),
                  trailing: Text('₹${b['final_amount'] ?? b['amount'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              )),
        const SizedBox(height: 24),
        const Text('Automated Allocation Audit Logs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (asgns.isEmpty)
          const Text('No automated allocation events logged yet.', style: TextStyle(color: AppColors.textSecondary))
        else
          ...asgns.take(10).map((a) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: const Icon(Icons.hub_outlined, color: AppColors.primary),
                  title: Text('Booking #${a['booking_id']} • ${a['worker_name']}'),
                  subtitle: Text('Fairness: ${a['fairness_score']} pts • Distance: ${a['distance_km']} km • Status: ${a['status']}'),
                ),
              )),
      ],
    );
  }

  Widget _buildAssociationDisputesAndFinancials(AdminProvider admin) {
    final disputes = admin.associationDisputes;
    final pay = admin.associationPayments;
    final summary = pay?['summary'] as Map<String, dynamic>? ?? {};
    final txs = (pay?['transactions'] as List? ?? []).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Financial Overview Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: App3D.card3D(backgroundColor: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Cooperative Settlement Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statColumn('Total Captured', '₹${(summary['total_captured_revenue'] ?? 0.0).toStringAsFixed(0)}', Colors.blue),
                  _statColumn('Eligible Payout', '₹${(summary['settlement_eligible_for_payout'] ?? 0.0).toStringAsFixed(0)}', Colors.green),
                  _statColumn('Frozen (Disputes)', '₹${(summary['settlement_frozen_disputes'] ?? 0.0).toStringAsFixed(0)}', Colors.red),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Complaints & Disputes Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Customer Disputes & Inquiry Queue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${disputes.length} cases', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        if (disputes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: App3D.card3D(),
            child: const Text('No complaints filed against this cooperative. Zero settlements frozen.', style: TextStyle(color: Colors.green)),
          )
        else
          ...disputes.map((d) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Category: ${d['category'] ?? 'General'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                            child: Text(d['status'] ?? 'OPEN', style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Booking ID: #${d['booking_id']} • Payout Frozen 🔒'),
                      Text('Description: ${d['description'] ?? 'No notes provided.'}', style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _showReviewDisputeDialog(d),
                          icon: const Icon(Icons.rate_review_outlined, size: 18),
                          label: const Text('Review Inquiry Notes'),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        const SizedBox(height: 20),

        // Recent Safe Transactions
        const Text('Recent Safe Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (txs.isEmpty)
          const Text('No transactions processed yet.', style: TextStyle(color: AppColors.textSecondary))
        else
          ...txs.take(10).map((tx) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.verified_rounded, color: Colors.green),
                  title: Text('₹${tx['amount']} • ${tx['service_name'] ?? 'Service'}'),
                  subtitle: Text('Order: ${tx['razorpay_order_id'] ?? 'ORD-REF'} • Settlement: ${tx['settlement_status']}'),
                ),
              )),
      ],
    );
  }

  void _showReviewDisputeDialog(Map<String, dynamic> dispute) {
    final notesCtrl = TextEditingController(text: dispute['resolution_notes'] ?? '');
    String status = dispute['status'] ?? 'UNDER_REVIEW';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text('Review Dispute #${dispute['id']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Issue: ${dispute['description'] ?? ''}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Inquiry Notes & Findings', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status Transition'),
                items: const [
                  DropdownMenuItem(value: 'UNDER_REVIEW', child: Text('Under Investigation')),
                  DropdownMenuItem(value: 'RESOLVED', child: Text('Resolved (Mutual Settlement)')),
                ],
                onChanged: (val) => setDlgState(() => status = val ?? 'UNDER_REVIEW'),
              ),
              const SizedBox(height: 8),
              const Text('Notice: Refund authorizations require Super Administrator approval.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                final admin = Provider.of<AdminProvider>(context, listen: false);
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final success = await admin.reviewDispute(
                  complaintId: dispute['id'].toString(),
                  status: status,
                  resolutionNotes: notesCtrl.text.trim(),
                  cooperativeId: auth.currentUser?.cooperativeId,
                );
                messenger.showSnackBar(
                  SnackBar(content: Text(success ? 'Dispute status updated!' : 'Failed to update dispute.')),
                );
              },
              child: const Text('Save Review'),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // SUPER ADMIN PLATFORM GOVERNANCE VIEWS
  // =========================================================================

  Widget _buildSuperAdminOverview(AdminProvider admin) {
    final dash = admin.adminDashboard;
    final metrics = dash?['metrics'] as Map<String, dynamic>? ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Apex Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: App3D.card3D(backgroundColor: const Color(0xFF1E1B4B)),
          child: Row(
            children: [
              const Icon(Icons.shield_rounded, color: Colors.amber, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dash?['federation_name'] ?? 'State Apex Federation', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Jurisdiction: ${dash?['jurisdiction'] ?? 'State-wide (38 Districts)'}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        const Text('State-Wide Platform Aggregations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _kpiCard('Total Societies', '${metrics['total_cooperatives'] ?? admin.adminCooperatives.length}', Icons.apartment, Colors.indigo),
            _kpiCard('Verified Societies', '${metrics['verified_cooperatives'] ?? admin.adminCooperatives.length}', Icons.verified, Colors.teal),
            _kpiCard('Platform Users', '${metrics['total_users'] ?? admin.adminUsers.length}', Icons.groups, Colors.blue),
            _kpiCard('Total Workforce', '${metrics['total_workers'] ?? admin.adminAllWorkers.length}', Icons.engineering, Colors.purple),
            _kpiCard('Total Captured GMV', '₹${(metrics['total_captured_revenue'] ?? 0.0).toStringAsFixed(0)}', Icons.currency_rupee, Colors.green),
            _kpiCard('Open Disputes', '${metrics['open_disputes'] ?? admin.adminDisputes.length}', Icons.gavel, Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildSuperAdminPhase7Analytics(AdminProvider admin) {
    final kpis = admin.platformKpis ?? {};
    final users = kpis['users'] as Map<String, dynamic>? ?? {};
    final bookings = kpis['bookings'] as Map<String, dynamic>? ?? {};
    final payments = kpis['payments'] as Map<String, dynamic>? ?? {};
    final dataQuality = admin.dataQualityReport ?? {};
    final demand = admin.serviceDemand ?? {};
    final workers = admin.workerUtilizationList;
    final geo = admin.geographicDemand ?? {};
    final matching = admin.matchingAnalytics ?? {};

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date Range Selector
        _buildDateRangeSelector(admin, isSuperAdmin: true),
        const SizedBox(height: 14),

        // Data Quality & System Health Badge
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.health_and_safety_rounded, color: Colors.teal.shade800, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Data Quality: ${dataQuality['data_quality_score_percentage'] ?? 100}% Healthy',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900, fontSize: 14),
                    ),
                    Text(
                      'Zero target leakage • Validated historical lifecycle records • ${dataQuality['total_anomalies_detected'] ?? 0} anomalies',
                      style: TextStyle(fontSize: 11, color: Colors.teal.shade800),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.teal.shade700, borderRadius: BorderRadius.circular(20)),
                child: const Text('ML READY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Platform KPIs Grid
        const Text('Platform Key Metrics (Phase 7)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _kpiCard('Total Customers', '${users['total_customers'] ?? 0}', Icons.person, Colors.blue),
            _kpiCard('Coop Workers', '${users['total_cooperative_workers'] ?? 0}', Icons.groups, Colors.green),
            _kpiCard('Ind. Workers', '${users['total_independent_workers'] ?? 0}', Icons.badge, Colors.teal),
            _kpiCard('Total Bookings', '${bookings['total_bookings'] ?? 0}', Icons.assignment, Colors.purple),
            _kpiCard('Captured GMV', '₹${(payments['total_service_value'] ?? 0.0).toStringAsFixed(0)}', Icons.currency_rupee, Colors.green.shade800),
            _kpiCard('Settled Amount', '₹${(payments['settled_amount'] ?? 0.0).toStringAsFixed(0)}', Icons.account_balance, Colors.indigo),
          ],
        ),
        const SizedBox(height: 20),

        // Worker Utilization Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: App3D.card3D(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.speed_rounded, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text('Worker Utilization & Capacity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Text('${workers.length} Workers Evaluated', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              const Divider(height: 20),
              if (workers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: Text('No worker utilization records in selected timeframe.')),
                )
              else
                ...workers.take(6).map((w) {
                  final util = (w['utilization_percentage'] ?? 0.0) as num;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${w['worker_name']} (${w['skill']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('$util% Utilized', style: TextStyle(fontWeight: FontWeight.bold, color: util > 70 ? Colors.green.shade700 : Colors.indigo)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Coop: ${w['cooperative_name']} • Jobs: ${w['completed_jobs']} • Acceptance: ${w['acceptance_rate_percentage']}%', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: (util / 100.0).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(util > 70 ? Colors.green : Colors.indigo),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Service Demand & Peak Hours
        Container(
          padding: const EdgeInsets.all(16),
          decoration: App3D.card3D(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Text('Service Demand & Peak Times', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statColumn('Peak Day', '${demand['peak_demand_day'] ?? 'Monday'}', Colors.teal),
                  _statColumn('Peak Hour', '${demand['peak_demand_hour'] ?? 10}:00', Colors.deepOrange),
                  _statColumn('Emergency Ratio', '${demand['emergency_demand_percentage'] ?? 0}%', Colors.red),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Top Services Demanded:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              if (demand['bookings_per_service'] is List)
                ...((demand['bookings_per_service'] as List).take(4)).map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s['service_name'] ?? 'Service', style: const TextStyle(fontSize: 12)),
                      Text('${s['booking_count']} bookings (${s['percentage']}%)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                )),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Geographic Demand Distribution
        Container(
          padding: const EdgeInsets.all(16),
          decoration: App3D.card3D(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.map_rounded, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('District Geographic Aggregation (Safe PII)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 20),
              if (geo['district_distribution'] is List)
                ...((geo['district_distribution'] as List).take(5)).map((d) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(d['district'] ?? 'District', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('${d['total_bookings']} bookings (${d['share_percentage']}%)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                    ],
                  ),
                )),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Matching Engine Performance
        Container(
          padding: const EdgeInsets.all(16),
          decoration: App3D.card3D(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Colors.purple),
                  SizedBox(width: 8),
                  Text('Matching Engine Performance & Audit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statColumn('Total Attempts', '${matching['total_evaluations'] ?? 0}', Colors.purple),
                  _statColumn('Eligible', '${matching['eligible_evaluations'] ?? 0}', Colors.green),
                  _statColumn('Filtered Out', '${matching['ineligible_evaluations'] ?? 0}', Colors.red),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // CSV Operational Export Center
        Container(
          padding: const EdgeInsets.all(16),
          decoration: App3D.card3D(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.file_download_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Operational CSV Export Center', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Export sanitized operational logs for governance audits & ML model pipelines.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Divider(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting Worker Utilization CSV...')));
                    },
                    icon: const Icon(Icons.people_outline, size: 16),
                    label: const Text('Worker Utilization'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting Service Demand CSV...')));
                    },
                    icon: const Icon(Icons.bar_chart, size: 16),
                    label: const Text('Service Demand'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting Matching History CSV...')));
                    },
                    icon: const Icon(Icons.rule, size: 16),
                    label: const Text('Matching Audit'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting ML Ranking Features CSV...')));
                    },
                    icon: const Icon(Icons.dataset, size: 16),
                    label: const Text('ML Feature Vectors'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuperAdminUserDirectory(AdminProvider admin) {
    final users = admin.adminUsers;

    return Column(
      children: [
        // Role & Search Filter
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search user name, email, phone...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _userSearchQuery = val.toLowerCase()),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _userRoleFilter,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Roles')),
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  DropdownMenuItem(value: 'independent_worker', child: Text('Independent')),
                  DropdownMenuItem(value: 'cooperative_worker', child: Text('Cooperative Worker')),
                  DropdownMenuItem(value: 'cooperative_association_head', child: Text('Association Head')),
                  DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                ],
                onChanged: (val) => setState(() => _userRoleFilter = val ?? 'all'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: users.length,
            itemBuilder: (ctx, idx) {
              final u = users[idx];
              final role = u['role']?.toString() ?? 'customer';
              final name = u['name'] ?? 'User';
              final email = u['email'] ?? 'N/A';

              if (_userRoleFilter != 'all' && role != _userRoleFilter) {
                return const SizedBox.shrink();
              }
              if (_userSearchQuery.isNotEmpty &&
                  !name.toLowerCase().contains(_userSearchQuery) &&
                  !email.toLowerCase().contains(_userSearchQuery)) {
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRoleColor(role).withValues(alpha: 0.15),
                    child: Icon(_getRoleIcon(role), color: _getRoleColor(role), size: 20),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$email • Role: $role'),
                  trailing: IconButton(
                    icon: const Icon(Icons.manage_accounts, color: AppColors.primary),
                    tooltip: 'Change User Role',
                    onPressed: () => _showChangeRoleDialog(u),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showChangeRoleDialog(Map<String, dynamic> user) {
    String selectedRole = user['role'] ?? 'customer';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: Text('Manage Role: ${user['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Target 5-Role Classification:'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Customer (Household)')),
                  DropdownMenuItem(value: 'independent_worker', child: Text('Independent Worker')),
                  DropdownMenuItem(value: 'cooperative_worker', child: Text('Cooperative Worker')),
                  DropdownMenuItem(value: 'cooperative_association_head', child: Text('Cooperative Association Head')),
                  DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                ],
                onChanged: (val) => setDlgState(() => selectedRole = val ?? selectedRole),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);
                final admin = Provider.of<AdminProvider>(context, listen: false);
                final success = await admin.updateUserRole(
                  userId: user['id'].toString(),
                  role: selectedRole,
                );
                messenger.showSnackBar(
                  SnackBar(content: Text(success ? 'User role updated to $selectedRole!' : 'Role change blocked or failed.')),
                );
              },
              child: const Text('Update Role'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuperAdminFederationTree(AdminProvider admin) {
    final tree = admin.adminFederationTree?['federation'] as Map<String, dynamic>? ?? {};
    final societies = (tree['societies'] as List? ?? []).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRegisterSocietyDialog,
        icon: const Icon(Icons.add_business),
        label: const Text('Register Cooperative'),
        backgroundColor: const Color(0xFF1E1B4B),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: App3D.card3D(),
            child: Row(
              children: [
                const Icon(Icons.account_tree_rounded, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Multi-Level Federation Hierarchy (${societies.length} Societies Registered)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...societies.map((soc) {
            final head = soc['association_head'] as Map<String, dynamic>? ?? {};
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: const Icon(Icons.apartment_rounded, color: AppColors.primary),
                title: Text(soc['cooperative_name'] ?? 'Society', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('District: ${soc['district']} • Workers: ${soc['worker_count']}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Designated Head: ${head['name'] ?? 'Unassigned'} (${head['phone'] ?? 'N/A'})', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Registration #: ${soc['registration_number'] ?? 'N/A'}'),
                        const SizedBox(height: 6),
                        Text('Approved Tariffs: ${(soc['approved_services'] as List? ?? []).length} active offerings'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showRegisterSocietyDialog() {
    final nameCtrl = TextEditingController();
    final distCtrl = TextEditingController();
    final regCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register Labour Cooperative Society'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Society Legal Name')),
              TextField(controller: distCtrl, decoration: const InputDecoration(labelText: 'District (e.g. Coimbatore)')),
              TextField(controller: regCtrl, decoration: const InputDecoration(labelText: 'Registration Code (TN-LCS-...)')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Official Contact Email')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final admin = Provider.of<AdminProvider>(context, listen: false);
              final success = await admin.registerCooperativeSociety(
                name: nameCtrl.text.trim(),
                district: distCtrl.text.trim(),
                registrationNumber: regCtrl.text.trim(),
                contactEmail: emailCtrl.text.trim(),
              );
              messenger.showSnackBar(
                SnackBar(content: Text(success ? 'Society registered under Federation!' : 'Registration failed.')),
              );
            },
            child: const Text('Register Society'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminWorkers(AdminProvider admin) {
    final workers = admin.adminAllWorkers;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: workers.length,
      itemBuilder: (ctx, idx) {
        final w = workers[idx];
        final name = w['name'] ?? 'Worker';
        final type = w['worker_type'] ?? 'cooperative';
        final isVerified = w['verified_status'] == true;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: Icon(
              type == 'cooperative' ? Icons.groups_rounded : Icons.person_outline,
              color: type == 'cooperative' ? AppColors.primary : Colors.teal,
            ),
            title: Row(
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (isVerified) const Text(' ✓', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            subtitle: Text('Type: $type • Skill: ${w['skill'] ?? 'General'} • Coop: ${w['cooperative_name'] ?? 'None'}'),
            trailing: Switch(
              value: isVerified,
              onChanged: (val) async {
                await admin.verifyWorkerSuperAdmin(workerId: w['id'].toString(), verifiedStatus: val);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuperAdminDisputes(AdminProvider admin) {
    final disputes = admin.adminDisputes;

    if (disputes.isEmpty) {
      return _buildEmptyState('No disputes pending platform-wide.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: disputes.length,
      itemBuilder: (ctx, idx) {
        final d = disputes[idx];
        final status = d['status'] ?? 'OPEN';
        final isRefunded = status == 'REFUNDED';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dispute #${d['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isRefunded ? Colors.purple.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(status, style: TextStyle(color: isRefunded ? Colors.purple : Colors.red.shade800, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Booking ID: #${d['booking_id']} • Category: ${d['category']}'),
                Text('Details: ${d['description']}'),
                if (!isRefunded) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700, foregroundColor: Colors.white),
                        onPressed: () => _showSuperAdminRefundDialog(d),
                        icon: const Icon(Icons.currency_rupee, size: 16),
                        label: const Text('Authorize Refund & Resolve'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuperAdminRefundDialog(Map<String, dynamic> dispute) {
    final notesCtrl = TextEditingController(text: 'Full refund authorized upon administrative SLA review.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Authorize Refund: #${dispute['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Action will initiate customer Razorpay refund and unfreeze payout settlement records:'),
            const SizedBox(height: 12),
            TextField(controller: notesCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Audit Resolution Notes')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              final admin = Provider.of<AdminProvider>(context, listen: false);
              final success = await admin.resolveDisputeWithRefundAction(
                complaintId: dispute['id'].toString(),
                status: 'RESOLVED',
                resolutionNotes: notesCtrl.text.trim(),
                refundApproved: true,
              );
              messenger.showSnackBar(
                SnackBar(content: Text(success ? 'Refund issued & dispute resolved!' : 'Failed to authorize refund.')),
              );
            },
            child: const Text('Confirm Full Refund'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminAuditLogs(AdminProvider admin) {
    final logs = admin.adminAuditLogs;
    if (logs.isEmpty) {
      return _buildEmptyState('No administrative actions logged yet.');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: logs.length,
      itemBuilder: (ctx, idx) {
        final log = logs[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.history_edu_rounded, color: Colors.indigo),
            title: Text(log['action'] ?? 'ACTION', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('${log['details']}\nTarget: ${log['target_type']} #${log['target_id']} • Actor: ${log['actor_role']}'),
            trailing: Text(log['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ),
        );
      },
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================

  Widget _kpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: App3D.card3D(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_rounded, size: 54, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
        return Colors.red.shade700;
      case 'cooperative_association_head':
        return AppColors.primary;
      case 'cooperative_worker':
        return Colors.green.shade700;
      case 'independent_worker':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'super_admin':
        return Icons.shield_rounded;
      case 'cooperative_association_head':
        return Icons.account_balance_rounded;
      case 'cooperative_worker':
        return Icons.groups_rounded;
      case 'independent_worker':
        return Icons.person_rounded;
      default:
        return Icons.home_rounded;
    }
  }
}
