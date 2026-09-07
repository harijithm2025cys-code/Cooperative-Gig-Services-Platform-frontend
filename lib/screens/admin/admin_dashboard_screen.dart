import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import 'tariff_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _tabIndex = 0; // 0 = Hub, 1 = Members, 2 = Dividends, 3 = Federation Admin
  String? _recentClaimMessage;

  final List<Map<String, dynamic>> _cooperativeWorkers = [
    {
      'id': 'MEM-KA-1021',
      'name': 'Harijith M',
      'skill': 'Senior Skilled Specialist',
      'rating': 4.9,
      'status': 'Active & Available',
      'coop': 'ABC Skilled Workers Cooperative',
      'gigsCompleted': 48,
    },
    {
      'id': 'MEM-KA-1042',
      'name': 'Dhanabalan R',
      'skill': 'Electrical & Diagnostic Engineer',
      'rating': 4.85,
      'status': 'On Job • Koramangala',
      'coop': 'ABC Skilled Workers Cooperative',
      'gigsCompleted': 36,
    },
    {
      'id': 'MEM-KA-1089',
      'name': 'Ajaipravin S',
      'skill': 'AC Jet & HVAC Master',
      'rating': 4.88,
      'status': 'Active & Available',
      'coop': 'ABC Skilled Workers Cooperative',
      'gigsCompleted': 52,
    },
    {
      'id': 'MEM-KA-1104',
      'name': 'Kumar S',
      'skill': 'AC Technician',
      'rating': 4.6,
      'status': 'En Route • 2.4 km away',
      'coop': 'ABC Skilled Workers Cooperative',
      'gigsCompleted': 29,
    },
    {
      'id': 'MEM-TN-2041',
      'name': 'Bhavani Shankar',
      'skill': 'Master Eco Cleaner',
      'rating': 4.87,
      'status': 'Active & Available',
      'coop': 'Chennai Labour Cooperative Society',
      'gigsCompleted': 64,
    },
  ];

  final List<Map<String, dynamic>> _tools = [
    {
      'title': 'High-Pressure AC Foam Jet Pump (120 Bar)',
      'price': '3,400',
      'origPrice': '4,800',
      'discount': '29% Group Discount',
      'units': 12,
    },
    {
      'title': 'R32 & R410A Dual Manifold Gauge Set',
      'price': '1,850',
      'origPrice': '2,600',
      'discount': '28% Group Discount',
      'units': 8,
    },
    {
      'title': 'True-RMS Digital Inverter Multimeter',
      'price': '1,200',
      'origPrice': '1,900',
      'discount': '36% Group Discount',
      'units': 15,
    },
  ];

  bool _isQueueDispatched = false;

  void _claimTool(int index) {
    setState(() {
      if (_tools[index]['units'] > 0) {
        _tools[index]['units'] = (_tools[index]['units'] as int) - 1;
      }
      _recentClaimMessage = 'Claim order for ${_tools[index]['title']} submitted to Secretary!';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_recentClaimMessage!),
        backgroundColor: AppColors.statusCompleted,
      ),
    );
  }

  void _autoDispatch() {
    setState(() => _isQueueDispatched = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI Algorithm matched & dispatched to Kumar S (95% Skill + 2.4km Proximity)!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showAddCooperativeWorkerDialog() {
    final nameCtrl = TextEditingController();
    final skillCtrl = TextEditingController(text: 'Electrical / AC Technician');
    final phoneCtrl = TextEditingController(text: '+91 98');
    final rateCtrl = TextEditingController(text: '400');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('➕ Register New Cooperative Worker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Worker-Owner Full Name',
                hintText: 'e.g. Sivakumar R',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: skillCtrl,
              decoration: InputDecoration(
                labelText: 'Primary Trade Skill',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: phoneCtrl,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: rateCtrl,
                    decoration: InputDecoration(
                      labelText: 'Hourly Rate (₹)',
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: App3D.button3D(backgroundColor: AppColors.primary, borderRadius: 14),
                onPressed: () {
                  if (nameCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _cooperativeWorkers.insert(0, {
                        'id': 'MEM-KA-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        'name': nameCtrl.text.trim(),
                        'skill': skillCtrl.text.trim(),
                        'rating': 5.0,
                        'status': 'Active & Available',
                        'coop': 'ABC Skilled Workers Cooperative',
                        'gigsCompleted': 0,
                      });
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cooperative Worker ${nameCtrl.text.trim()} certified and registered!'),
                        backgroundColor: AppColors.statusCompleted,
                      ),
                    );
                  }
                },
                child: const Text('Certify & Onboard Worker-Owner'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _allocateMemberModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manually Allocate Cooperative Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Text('H', style: TextStyle(color: Colors.white))),
              title: const Text('Harijith M', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Senior Specialist • 1.2 km away • 4.9 ★'),
              trailing: ElevatedButton(
                style: App3D.button3D(backgroundColor: AppColors.primary, borderRadius: 10),
                onPressed: () {
                  Navigator.pop(ctx);
                  _autoDispatch();
                },
                child: const Text('Assign'),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.primaryDark, child: Text('D', style: TextStyle(color: Colors.white))),
              title: const Text('Dhanabalan R', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Electrical & Diagnostic • 4.85 ★'),
              trailing: ElevatedButton(
                style: App3D.button3D(backgroundColor: AppColors.primary, borderRadius: 10),
                onPressed: () {
                  Navigator.pop(ctx);
                  _autoDispatch();
                },
                child: const Text('Assign'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget activeBody;
    switch (_tabIndex) {
      case 1:
        activeBody = _buildMembersTab();
        break;
      case 2:
        activeBody = _buildDividendsTab();
        break;
      case 3:
        activeBody = _buildFederationAdminTab();
        break;
      case 0:
      default:
        activeBody = _buildFederationHubTab();
        break;
    }

    final auth = Provider.of<AuthProvider>(context);
    final isSuperAdmin = auth.currentUser?.isSuperAdmin == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isSuperAdmin ? 'State Federation Super Admin Hub' : 'District Cooperative Association Portal',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.price_change_rounded, color: AppColors.primary),
            tooltip: 'Tariff Matrix & Fair Workload',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TariffManagementScreen()),
            ),
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
      body: SafeArea(child: activeBody),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Color(0x141E1B4B), blurRadius: 16, offset: Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: _tabIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => setState(() => _tabIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.speed_rounded), label: 'Federation Hub'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), label: 'Members'),
            BottomNavigationBarItem(icon: Icon(Icons.monetization_on_outlined), label: 'Dividends'),
            BottomNavigationBarItem(icon: Icon(Icons.apartment_rounded), label: 'Federation'),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: FEDERATION HUB ---
  Widget _buildFederationHubTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with 3D Depth
          Container(
            padding: const EdgeInsets.all(18),
            decoration: App3D.card3D(borderRadius: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primaryLight.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.group_work_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ABC Skilled Workers Cooperative', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      SizedBox(height: 2),
                      Text('NCD: #NCD-KA-2024-8841 • Bengaluru, KA', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusCompletedBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, size: 12, color: AppColors.statusCompleted),
                      SizedBox(width: 4),
                      Text('Certified Co-op', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.statusCompleted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Green Notification Banner if claim made
          if (_recentClaimMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.statusCompletedBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.statusCompleted, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_recentClaimMessage!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // 3D Visual Radar Map
          Container(
            decoration: App3D.card3D(borderRadius: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 160,
                width: double.infinity,
                color: const Color(0xFFEEF2FF),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _AdminGridPainter()),
                    ),
                    Positioned(
                      top: 25,
                      right: 80,
                      child: _buildMapPin('★ 4.9 Harijith', AppColors.primary),
                    ),
                    Positioned(
                      top: 65,
                      right: 140,
                      child: _buildMapPin('★ 4.85 Dhanabalan', AppColors.primaryDark),
                    ),
                    Positioned(
                      bottom: 25,
                      left: 90,
                      child: _buildMapPin('★ 4.88 Ajaipravin', AppColors.primaryLight),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Incoming Federation Dispatch Queue
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Incoming Federation Dispatch Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(10)),
                child: Text(_isQueueDispatched ? '0 Waiting' : '1 Waiting', style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 11.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (!_isQueueDispatched)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: App3D.card3D(borderRadius: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.build_rounded, size: 14, color: AppColors.primaryLight),
                            SizedBox(width: 6),
                            Text('AC Jet Foam Servicing', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.statusCompletedBg, borderRadius: BorderRadius.circular(8)),
                        child: const Text('✨ 95% Match', style: TextStyle(color: AppColors.statusCompleted, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.person, size: 16, color: AppColors.primaryLight),
                      SizedBox(width: 6),
                      Text('Customer: Sunita Rao', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('📍 88, 100 Feet Rd, Indiranagar (3.4 km away)', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(10)),
                    child: const Text('"Water leak and bad odor from indoor cooling unit."', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: App3D.button3D(backgroundColor: AppColors.primary, borderRadius: 12),
                          icon: const Icon(Icons.bolt, size: 18),
                          label: const Text('⚡ Auto-Dispatch (AI)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          onPressed: _autoDispatch,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
                          icon: const Icon(Icons.person_add_alt_1, size: 18),
                          label: const Text('Allocate Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          onPressed: _allocateMemberModal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Collective Bulk Tool Procurement Depot
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Collective Bulk Tool Procurement Depot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.statusCompletedBg, borderRadius: BorderRadius.circular(8)),
                child: const Text('Co-op Bulk Pricing', style: TextStyle(color: AppColors.statusCompleted, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          ...List.generate(_tools.length, (index) {
            final t = _tools[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: App3D.card3D(borderRadius: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text('₹${t['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.statusCompleted)),
                            const SizedBox(width: 6),
                            Text('₹${t['origPrice']}', style: const TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: AppColors.textTertiary)),
                            const SizedBox(width: 8),
                            Text(t['discount'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.statusRequested),
                            const SizedBox(width: 4),
                            Text('${t['units']} Units in Central Federation Depot', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: App3D.button3D(backgroundColor: AppColors.primary, borderRadius: 12),
                    onPressed: () => _claimTool(index),
                    child: const Text('Claim Tool', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- TAB 2: COOPERATIVE MEMBERS ---
  Widget _buildMembersTab() {
    return SingleChildScrollView(
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
                  const Text('Cooperative Worker-Owners', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text('${_cooperativeWorkers.length} Certified Active Members', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                style: App3D.button3D(backgroundColor: AppColors.primary, borderRadius: 12),
                icon: const Icon(Icons.person_add_alt_1, size: 16),
                label: const Text('Add Worker', style: TextStyle(fontSize: 12)),
                onPressed: _showAddCooperativeWorkerDialog,
              ),
            ],
          ),
          const SizedBox(height: 18),

          ..._cooperativeWorkers.map((w) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: App3D.card3D(borderRadius: 18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      (w['name'] as String).isNotEmpty ? (w['name'] as String)[0] : 'W',
                      style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(w['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, size: 15, color: AppColors.primaryLight),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('${w['skill']} • ${w['id']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.rating, size: 15),
                            const SizedBox(width: 2),
                            Text('${w['rating']} ★', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Text('• ${w['gigsCompleted']} Gigs Completed', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (w['status'] as String).contains('Active') ? AppColors.statusCompletedBg : AppColors.statusAcceptedBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (w['status'] as String).contains('Active') ? '🟢 Available' : '⚡ On Job',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: (w['status'] as String).contains('Active') ? AppColors.statusCompleted : AppColors.primary,
                      ),
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

  // --- TAB 3: DIVIDENDS POOL ---
  Widget _buildDividendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quarterly Member Dividend Pool', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('100% Shared Member Profit Distribution', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: App3D.glowCard3D(
              gradientColors: const [Color(0xFF5B21B6), Color(0xFF7C3AED)],
              borderRadius: 22,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Cooperative Surplus', style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 6),
                Text('₹1,42,800.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Divider(color: Colors.white24),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Eligible Members: 54', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Avg Dividend: ₹2,644 / member', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Recent Direct Dividend Dispatches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _buildDividendRow('Harijith M', '₹3,450.00', 'Dispatched via Canara Escrow'),
          _buildDividendRow('Dhanabalan R', '₹2,890.00', 'Dispatched via Canara Escrow'),
          _buildDividendRow('Ajaipravin S', '₹3,120.00', 'Dispatched via Canara Escrow'),
        ],
      ),
    );
  }

  Widget _buildDividendRow(String name, String amount, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: App3D.card3D(borderRadius: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            ],
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.statusCompleted)),
        ],
      ),
    );
  }

  // --- TAB 4: FEDERATION ADMINISTRATION ---
  Widget _buildFederationAdminTab() {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: App3D.card3D(borderRadius: 22),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primaryLight.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 14),
                const Text('ABC Skilled Workers Cooperative', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Registration NCD ID: #NCD-KA-2024-8841', style: TextStyle(fontSize: 12.5, color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                const Text('📍 Bengaluru, Karnataka', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.statusCompletedBg, borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user, color: AppColors.statusCompleted, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'National Cooperative Database (NCD) & Ministry of Cooperation Compliant',
                          style: TextStyle(color: Color(0xFF166534), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                    label: const Text('Edit Federation Information', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Federation Administration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 12),

          _buildAdminItem(
            icon: Icons.payment,
            title: 'Federation Escrow Settlement Account',
            subtitle: 'Canara Bank Commercial •••• 9920',
          ),
          _buildAdminItem(
            icon: Icons.military_tech_outlined,
            title: 'NCD Compliance & ISO 9001:2024',
            subtitle: 'Valid till 31 Dec 2027 • Status: In Good Standing',
            iconColor: AppColors.statusCompleted,
          ),
          _buildAdminItem(
            icon: Icons.person_outline,
            title: 'Switch to Independent Worker View',
            subtitle: 'View individual technician dashboard',
            onTap: () {
              auth.switchRole(UserRole.worker);
              Navigator.pushReplacementNamed(context, AppRoutes.workerHome);
            },
          ),
          _buildAdminItem(
            icon: Icons.swap_horiz,
            title: 'Switch to Customer Mode',
            subtitle: 'Order home services as customer',
            onTap: () {
              auth.switchRole(UserRole.household);
              Navigator.pushReplacementNamed(context, AppRoutes.householdHome);
            },
          ),
          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusCancelledBg,
                foregroundColor: AppColors.statusCancelled,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out Federation Session', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                await auth.logout();
                if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = AppColors.primary,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: App3D.card3D(borderRadius: 14),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMapPin(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}

class _AdminGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..strokeWidth = 3;

    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.6), paint);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.4, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.7, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
