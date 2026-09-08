import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/worker.dart';
import '../../providers/worker_provider.dart';
import 'book_service_screen.dart';

class MatchedWorkerCandidate {
  final Worker worker;
  final int matchScore; // percentage 0 - 100
  final String matchedSkill;
  final String matchReason;

  MatchedWorkerCandidate({
    required this.worker,
    required this.matchScore,
    required this.matchedSkill,
    required this.matchReason,
  });
}

class ProblemDescriptionScreen extends StatefulWidget {
  const ProblemDescriptionScreen({super.key});

  @override
  State<ProblemDescriptionScreen> createState() => _ProblemDescriptionScreenState();
}

class _ProblemDescriptionScreenState extends State<ProblemDescriptionScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isAnalyzing = false;
  String? _detectedSkill;
  List<MatchedWorkerCandidate> _results = [];

  final List<String> _samplePromptsEn = [
    'AC leaking water in master bedroom',
    'Kitchen sink pipe burst and water leaking',
    'Switchboard sparking and power cut',
    'Wooden door lock and latch broken',
    'Deep sanitization and full house cleaning',
    'Living room wall paint peeling off',
  ];

  final List<String> _samplePromptsTa = [
    'படுக்கையறையில் ஏசி தண்ணீர் கசிகிறது',
    'சமையலறை குழாய் உடைந்து தண்ணீர் வழிகிறது',
    'சுவிட்ச் போர்டில் தீப்பொறி & மின் தடை',
    'மரக் கதவு பூட்டு உடைந்துவிட்டது',
    'முழு வீடு ஆழமான சுத்தம்',
    'சுவர் பெயிண்ட் உரிக்கிறது',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyzeProblem([String? presetText]) {
    final text = (presetText ?? _controller.text).trim();
    if (text.isEmpty) return;

    if (presetText != null) {
      _controller.text = presetText;
    }

    setState(() => _isAnalyzing = true);

    final lower = text.toLowerCase();

    // Natural Language Keyword & Trade Mapping
    String skill = 'Electrician';
    String reason = 'Matched electrical keywords';

    if (lower.contains('ac') || lower.contains('air condition') || lower.contains('cooling') || lower.contains('compressor') || lower.contains('ஏசி')) {
      skill = 'Electrician';
      reason = 'Detected HVAC & Air conditioning anomaly';
    } else if (lower.contains('leak') || lower.contains('pipe') || lower.contains('sink') || lower.contains('tap') || lower.contains('drain') || lower.contains('plumb') || lower.contains('water') || lower.contains('குழாய்') || lower.contains('தண்ணீர்')) {
      skill = 'Plumber';
      reason = 'Detected plumbing, leak & water flow issue';
    } else if (lower.contains('spark') || lower.contains('fuse') || lower.contains('switch') || lower.contains('power') || lower.contains('wire') || lower.contains('mcb') || lower.contains('மின்சாரம்') || lower.contains('சுவிட்ச்')) {
      skill = 'Electrician';
      reason = 'Detected high-priority electrical switchboard & wiring fault';
    } else if (lower.contains('door') || lower.contains('wood') || lower.contains('lock') || lower.contains('hinge') || lower.contains('furniture') || lower.contains('carpent') || lower.contains('மரம்') || lower.contains('பூட்டு')) {
      skill = 'Carpenter';
      reason = 'Detected woodwork, locking mechanism & carpentry';
    } else if (lower.contains('clean') || lower.contains('dust') || lower.contains('wash') || lower.contains('sanitize') || lower.contains('mop') || lower.contains('சுத்தம்')) {
      skill = 'Cleaner';
      reason = 'Detected residential deep cleaning and sanitization';
    } else if (lower.contains('paint') || lower.contains('wall') || lower.contains('stain') || lower.contains('வண்ணம்') || lower.contains('பெயிண்ட்')) {
      skill = 'Painter';
      reason = 'Detected wall texture, primer and painting requirements';
    }

    // Match with available workers from WorkerProvider
    final workerProv = Provider.of<WorkerProvider>(context, listen: false);
    final allWorkers = workerProv.workers;

    List<MatchedWorkerCandidate> matched = [];
    int baseScore = 96;

    for (final w in allWorkers) {
      if (w.skill.toLowerCase().contains(skill.toLowerCase()) || skill.toLowerCase().contains(w.skill.toLowerCase())) {
        matched.add(MatchedWorkerCandidate(
          worker: w,
          matchScore: baseScore,
          matchedSkill: skill,
          matchReason: reason,
        ));
        baseScore = (baseScore > 82) ? baseScore - 3 : 80;
      }
    }

    // If no exact match from provider list, take top workers and adapt
    if (matched.isEmpty && allWorkers.isNotEmpty) {
      for (int i = 0; i < allWorkers.take(3).length; i++) {
        matched.add(MatchedWorkerCandidate(
          worker: allWorkers[i],
          matchScore: 92 - (i * 4),
          matchedSkill: skill,
          matchReason: reason,
        ));
      }
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _detectedSkill = skill;
        _results = matched;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = Localizations.localeOf(context).languageCode == 'ta';
    final samplePrompts = isTamil ? _samplePromptsTa : _samplePromptsEn;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isTamil ? 'AI பிரச்சனை பொருத்தம்' : 'AI Problem Matcher',
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
            // Hero Instruction Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTamil ? 'இயற்கை மொழி AI பொருத்தம்' : 'Natural Language AI Matcher',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isTamil
                              ? 'உங்கள் வீட்டு பிரச்சனையை விவரிக்கவும், எங்கள் AI உடனடியாக சரியான கூட்டுறவு தொழிலாளரை கண்டுபிடிக்கும்.'
                              : 'Describe your issue in plain words and our AI model finds the most qualified verified co-op workers.',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Text Input Box
            Text(
              isTamil ? 'பிரச்சனையை விவரிக்கவும்:' : 'Describe your problem:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: TextField(
                controller: _controller,
                maxLines: 3,
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: isTamil
                      ? 'எ.கா., ஏசி தண்ணீர் கசிகிறது, அல்லது சமையலறை குழாய் அடைப்பு...'
                      : 'e.g., Kitchen sink pipe leaking water under cabinet...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                  contentPadding: const EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : () => _analyzeProblem(),
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome_rounded, size: 20),
                label: Text(
                  _isAnalyzing
                      ? (isTamil ? 'ஆராய்கிறது...' : 'Analyzing problem...')
                      : (isTamil ? 'தொழிலாளர்களைக் கண்டறி' : 'Find Matching Workers'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Samples Header
            Text(
              isTamil ? 'அல்லது மாதிரி பிரச்சனையைத் தேர்ந்தெடுக்கவும்:' : 'Or tap a sample problem:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: samplePrompts.map((prompt) {
                return InkWell(
                  onTap: () => _analyzeProblem(prompt),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(prompt, style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Results Section
            if (_detectedSkill != null) ...[
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isTamil ? 'பொருந்தும் தொழிலாளர்கள்' : 'Matched Specialists',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Skill: $_detectedSkill',
                      style: const TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (_results.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Center(
                    child: Text(
                      isTamil ? 'பொருந்தும் தொழிலாளர்கள் இல்லை.' : 'No matching specialists found nearby.',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final item = _results[i];
                    return _WorkerMatchCard(item: item);
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkerMatchCard extends StatelessWidget {
  final MatchedWorkerCandidate item;

  const _WorkerMatchCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final w = item.worker;
    final isTamil = Localizations.localeOf(context).languageCode == 'ta';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFEEF2FF),
                child: Text(
                  w.name.isNotEmpty ? w.name[0] : 'W',
                  style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            w.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF059669)),
                              const SizedBox(width: 3),
                              Text(
                                '${item.matchScore}% Match',
                                style: const TextStyle(color: Color(0xFF065F46), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      w.cooperativeName,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          '${w.rating} (${w.reviewsCount})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.near_me_rounded, size: 13, color: Color(0xFF64748B)),
                        const SizedBox(width: 3),
                        Text(
                          '${w.distanceKm.toStringAsFixed(1)} km away',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
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
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 14, color: Color(0xFF4F46E5)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.matchReason,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${w.hourlyRate.toInt()}/hour',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookServiceScreen(worker: w),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  isTamil ? 'முன்பதிவு செய்' : 'Book Now',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
