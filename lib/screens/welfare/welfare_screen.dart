import 'package:flutter/material.dart';

class WelfareScreen extends StatelessWidget {
  const WelfareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isTamil = Localizations.localeOf(context).languageCode == 'ta';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isTamil ? 'கூட்டுறவு நலத்திட்டங்கள்' : 'Welfare & Social Security',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welfare Fund Health Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                    blurRadius: 10,
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
                      Text(
                        isTamil ? 'கூட்டுறவு நல நிதி ஆரோக்கியம்' : 'Cooperative Welfare Fund',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '85% Good Standing',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '₹ 14,82,500',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isTamil
                        ? '1,240 தொழிலாளர் குடும்பங்கள் காப்பீட்டுப் பாதுகாப்பில் உள்ளன'
                        : 'Covering 1,240 verified worker-owner families across 18 cooperative societies.',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(
                      value: 0.85,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section: Social Security Schemes
            Text(
              isTamil ? 'அரசு மற்றும் கூட்டுறவு நலத்திட்டங்கள்' : 'Government & Cooperative Schemes',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // 1. PMJJBY Scheme Card
            _SchemeCard(
              title: 'PMJJBY — Life Insurance',
              subtitle: 'Pradhan Mantri Jeevan Jyoti Bima Yojana',
              coverage: '₹ 2,00,000 Life Cover',
              status: isTamil ? 'செயலில் உள்ளது' : 'Active & Enrolled',
              badgeColor: const Color(0xFF10B981),
              icon: Icons.shield_rounded,
              color: const Color(0xFF4F46E5),
              description: isTamil
                  ? 'ஆயுள் காப்பீட்டு பிரீமியம் கூட்டுறவு சமூக பாதுகாப்பு நிதியிலிருந்து நேரடியாக செலுத்தப்படுகிறது.'
                  : 'Annual life insurance premium is subsidized and managed via the cooperative social security cess.',
            ),
            const SizedBox(height: 12),

            // 2. PMSBY Scheme Card
            _SchemeCard(
              title: 'PMSBY — Accident Insurance',
              subtitle: 'Pradhan Mantri Suraksha Bima Yojana',
              coverage: '₹ 2,00,000 Accident / Disability',
              status: isTamil ? 'செயலில் உள்ளது' : 'Active & Enrolled',
              badgeColor: const Color(0xFF10B981),
              icon: Icons.health_and_safety_rounded,
              color: const Color(0xFF0284C7),
              description: isTamil
                  ? 'பணியிட மற்றும் பயண விபத்துகளுக்கு முழு சிகிச்சை மற்றும் இழப்பீடு உத்தரவாதம்.'
                  : 'Comprehensive accidental disability and death cover for all verified on-duty gig workers.',
            ),
            const SizedBox(height: 12),

            // 3. Ayushman Bharat PM-JAY
            _SchemeCard(
              title: 'Ayushman Bharat — PM-JAY',
              subtitle: 'National Health Protection Scheme',
              coverage: '₹ 5,00,000 / Year Family Cover',
              status: isTamil ? 'சரிபார்க்கப்பட்டது' : 'Golden Card Verified',
              badgeColor: const Color(0xFF059669),
              icon: Icons.local_hospital_rounded,
              color: const Color(0xFF059669),
              description: isTamil
                  ? 'அங்கீகரிக்கப்பட்ட அனைத்து அரசு மற்றும் தனியார் மருத்துவமனைகளில் பணமில்லா சிகிச்சை.'
                  : 'Cashless secondary and tertiary hospitalization across empaneled public and private hospitals.',
            ),
            const SizedBox(height: 12),

            // 4. Cooperative Emergency Relief Grant
            _SchemeCard(
              title: 'Cooperative Emergency Relief Grant',
              subtitle: 'State Federation Social Security Fund',
              coverage: '₹ 25,000 Instant Support',
              status: isTamil ? 'கோரிக்கை வைக்கலாம்' : 'Available On Demand',
              badgeColor: const Color(0xFFF59E0B),
              icon: Icons.volunteer_activism_rounded,
              color: const Color(0xFFD97706),
              description: isTamil
                  ? 'மருத்துவ அவசரநிலை அல்லது எதிர்பாராத இழப்புகளுக்கு 24 மணி நேரத்திற்குள் உடனடி நிதி உதவி.'
                  : 'Immediate emergency relief granted within 24 hours of incident verification by the Association Head.',
            ),
            const SizedBox(height: 24),

            // Claim Assistance CTA Box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: Color(0xFF4F46E5), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTamil ? 'உரிமைகோரல் உதவி மையம்' : 'Welfare Claim Assistance Desk',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              isTamil ? 'ஆவணங்கள் மற்றும் உரிமைகோரல் வழிகாட்டல்' : 'Document verification & quick filing',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isTamil
                        ? 'மருத்துவ பில்கள், ஆதார் அட்டை மற்றும் கூட்டுறவு உறுப்பினர் ஐடியுடன் உரிமைகோரலை சமர்ப்பிக்கலாம்.'
                        : 'Submit medical claims, hospital discharge summaries, or accident relief applications directly to your cooperative association officer.',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(isTamil ? 'உரிமைகோரல் உதவி' : 'Submit Welfare Claim'),
                            content: Text(
                              isTamil
                                  ? 'உங்கள் கூட்டுறவு அதிகாரிக்கு கோரிக்கை அனுப்பப்பட்டது. 24 மணி நேரத்திற்குள் உங்களுக்கு அழைப்பு வரும்.'
                                  : 'Claim ticket #WLF-2026 has been registered with your Cooperative Association Officer. You will be contacted within 24 hours.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(isTamil ? 'சரி' : 'OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4F46E5),
                        side: const BorderSide(color: Color(0xFF4F46E5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isTamil ? 'உரிமைகோரல் சமர்ப்பிக்கவும்' : 'Apply for Assistance / Claim',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String coverage;
  final String status;
  final Color badgeColor;
  final IconData icon;
  final Color color;
  final String description;

  const _SchemeCard({
    required this.title,
    required this.subtitle,
    required this.coverage,
    required this.status,
    required this.badgeColor,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 2)),
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: badgeColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF10B981)),
                const SizedBox(width: 6),
                Text(
                  coverage,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.35),
          ),
        ],
      ),
    );
  }
}
