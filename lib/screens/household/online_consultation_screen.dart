import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'book_service_screen.dart';

class OnlineConsultationScreen extends StatefulWidget {
  const OnlineConsultationScreen({super.key});

  @override
  State<OnlineConsultationScreen> createState() => _OnlineConsultationScreenState();
}

class _OnlineConsultationScreenState extends State<OnlineConsultationScreen> with SingleTickerProviderStateMixin {
  int _tabIndex = 0; // 0 = Voice Call, 1 = Video Diagnosis
  bool _isMuted = false;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _resolveRemotely() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.statusCompletedBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.statusCompleted.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.statusCompleted, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Remote Diagnosis Complete!', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            const Text('₹150 digital consultation fee released to Kumar S (ABC Skilled Workers Co-op) via Escrow.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: App3D.button3D(backgroundColor: AppColors.primary, borderRadius: 14),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Return to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Online Consultation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Top Voice / Video Selector Tabs with 3D Card
              Container(
                padding: const EdgeInsets.all(4),
                decoration: App3D.card3D(
                  backgroundColor: Colors.white,
                  borderRadius: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 0 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone_in_talk_rounded, size: 16, color: _tabIndex == 0 ? Colors.white : AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text('Voice Call', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: _tabIndex == 0 ? Colors.white : AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 1 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam_rounded, size: 18, color: _tabIndex == 1 ? Colors.white : AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Text('Video Diagnosis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: _tabIndex == 1 ? Colors.white : AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hero Audio/Video Call Card with 3D Depth
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: App3D.glowCard3D(
                  gradientColors: const [Color(0xFF1E1B4B), Color(0xFF312E81)],
                  borderRadius: 24,
                ),
                child: Column(
                  children: [
                    // Avatar with glowing 3D ring
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.primaryLight.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 38),
                    ),
                    const SizedBox(height: 16),
                    const Text('Kumar S', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('AC Technician & Cooling Specialist', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    // Cooperative Worker Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.apartment_rounded, color: Colors.amber, size: 14),
                          SizedBox(width: 6),
                          Text('ABC Skilled Workers Co-op (Member #1042)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Waveform / Video simulation
                    if (_tabIndex == 0)
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(14, (index) {
                              final height = 10 + 26 * ((index % 4 + 1) * _waveController.value);
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                width: 3.5,
                                height: height.clamp(8.0, 38.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          );
                        },
                      )
                    else
                      Container(
                        height: 70,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_front, color: Colors.greenAccent, size: 20),
                            SizedBox(width: 8),
                            Text('Camera Stream Active (720p HD Cooperative Link)', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 28),

                    // Call control buttons with 3D styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: const Color(0xFF1E1B4B)),
                            onPressed: () => setState(() => _isMuted = !_isMuted),
                          ),
                        ),
                        const SizedBox(width: 20),
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.flip_camera_ios, color: Color(0xFF1E1B4B)),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 20),
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.statusCancelled,
                          child: IconButton(
                            icon: const Icon(Icons.call_end, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Consultation Stream Active 3D Card
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.show_chart_rounded, color: AppColors.primaryDark, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Consultation Stream Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.textPrimary)),
                              Text('Live audio-video diagnostic with certified cooperative worker.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Preliminary findings
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.search, size: 16, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text('Preliminary Technician Finding:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            '"Based on the unusual humming sound and warm exhaust, the cooling coil requires in-person diagnostic and gas pressure balancing."',
                            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Button 1: SCHEDULE SITE VISIT (3D Royal Violet)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: App3D.button3D(backgroundColor: AppColors.primary, borderRadius: 14),
                  icon: const Icon(Icons.calendar_month_outlined, size: 20),
                  label: const Text('SCHEDULE SITE VISIT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookServiceScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Button 2: RESOLVED REMOTELY (3D Outlined)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const Text('RESOLVED REMOTELY (Pay ₹150 Consultation)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  onPressed: _resolveRemotely,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
