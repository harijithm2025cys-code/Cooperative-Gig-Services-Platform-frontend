import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/tariff.dart';
import '../../services/api_service.dart';

class TariffManagementScreen extends StatefulWidget {
  const TariffManagementScreen({super.key});

  @override
  State<TariffManagementScreen> createState() => _TariffManagementScreenState();
}

class _TariffManagementScreenState extends State<TariffManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CooperativeTariff> _tariffs = [];
  Map<String, dynamic>? _fairnessData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final tariffs = await ApiService().getCooperativeTariffs();
    final fairness = await ApiService().getWorkloadFairness();
    if (!mounted) return;
    setState(() {
      _tariffs = tariffs;
      _fairnessData = fairness;
      _isLoading = false;
    });
  }

  void _editTariffDialog(CooperativeTariff tariff) {
    final rateCtrl = TextEditingController(text: tariff.hourlyRate.toStringAsFixed(0));
    final baseCtrl = TextEditingController(text: tariff.baseFee.toStringAsFixed(0));
    final surchargeCtrl = TextEditingController(text: tariff.emergencySurchargeRate.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Tariff: ${tariff.serviceName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rateCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Standard Hourly Rate (₹)', prefixText: '₹ '),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: baseCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Base Visiting Fee (₹)', prefixText: '₹ '),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: surchargeCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Emergency Surcharge Multiplier (e.g. 1.25)', prefixIcon: Icon(Icons.bolt, color: Colors.orange)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final updated = CooperativeTariff(
                id: tariff.id,
                cooperativeId: tariff.cooperativeId,
                serviceName: tariff.serviceName,
                hourlyRate: double.tryParse(rateCtrl.text.trim()) ?? tariff.hourlyRate,
                baseFee: double.tryParse(baseCtrl.text.trim()) ?? tariff.baseFee,
                emergencySurchargeRate: double.tryParse(surchargeCtrl.text.trim()) ?? tariff.emergencySurchargeRate,
              );
              Navigator.pop(ctx);
              await ApiService().upsertTariff(updated);
              _loadData();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✓ Standard tariff updated for ${tariff.serviceName}'), backgroundColor: AppColors.statusCompleted),
              );
            },
            child: const Text('Save Tariff'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Society Tariffs & Fair Workload', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.price_change_rounded, size: 20), text: 'Tariff Rate Card'),
            Tab(icon: Icon(Icons.balance_rounded, size: 20), text: 'Fair Workload (Fi)'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTariffsTab(),
                _buildFairnessTab(),
              ],
            ),
    );
  }

  Widget _buildTariffsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: App3D.card3D(
            backgroundColor: AppColors.primaryContainer,
            borderRadius: 16,
          ),
          child: Row(
            children: const [
              Icon(Icons.gavel_rounded, color: AppColors.primaryDark, size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Standardized Society Tariff Matrix protects workers against predatory undercut pricing and ensures living wages.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ..._tariffs.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: App3D.card3D(backgroundColor: Colors.white, borderRadius: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.handyman_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('₹${t.hourlyRate.toStringAsFixed(0)}/hr', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                            const SizedBox(width: 8),
                            Text('• Base: ₹${t.baseFee.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                            const SizedBox(width: 8),
                            Text('• SOS: ${(t.emergencySurchargeRate * 100 - 100).toStringAsFixed(0)}%+', style: const TextStyle(color: Colors.orange, fontSize: 11.5, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
                    onPressed: () => _editTariffDialog(t),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildFairnessTab() {
    final workers = (_fairnessData?['workers'] as List?) ?? [];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: App3D.card3D(
            backgroundColor: const Color(0xFF0F172A),
            borderRadius: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
                  SizedBox(width: 8),
                  Text('Fair Allocation Engine Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Algorithm: Fi = max(0, 25 - (monthly_jobs * 2.5)). Under-assigned members gain up to +25 score priority to balance monthly livelihoods.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...workers.map((w) {
          final name = w['name'] ?? 'Worker';
          final skill = w['skill'] ?? 'Specialist';
          final jobs = w['monthly_jobs'] ?? 0;
          final mult = w['fairness_multiplier'] ?? 20.0;
          final priority = w['allocation_priority'] ?? 'Normal';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: App3D.card3D(backgroundColor: Colors.white, borderRadius: 16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(name.isNotEmpty ? name[0] : 'W', style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(skill, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Jobs this month: $jobs • Multiplier: +${mult}pts', style: const TextStyle(fontSize: 11.5, color: AppColors.primary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusCompletedBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(priority, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.statusCompleted)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
