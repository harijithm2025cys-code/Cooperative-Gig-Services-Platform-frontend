import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../config/api_config.dart';

class ChatMessageItem {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? intent;

  ChatMessageItem({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.intent,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isLoading = false;

  final List<ChatMessageItem> _messages = [
    ChatMessageItem(
      text: "Hello! I am your Cooperative Service Assistant. How can I help you today? You can ask about booking, payment options, emergency dispatch, worker verification, or welfare benefits.",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  final List<String> _quickPromptsEn = [
    'How to book a service?',
    'Emergency service',
    'Payment & UPI options',
    'How ML matching works?',
    'Worker verification & KYC',
    'Cooperative welfare benefits',
  ];

  final List<String> _quickPromptsTa = [
    'சேவை முன்பதிவு செய்வது எப்படி?',
    'அவசர சேவை',
    'கட்டண முறைகள் & UPI',
    'ML பொருத்தம் எவ்வாறு செயல்படுகிறது?',
    'தொழிலாளர் சரிபார்ப்பு & KYC',
    'கூட்டுறவு நலத்திட்டங்கள்',
  ];

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? preset]) async {
    final query = (preset ?? _textCtrl.text).trim();
    if (query.isEmpty) return;

    if (preset == null) _textCtrl.clear();

    final isTamil = Localizations.localeOf(context).languageCode == 'ta';

    setState(() {
      _messages.add(ChatMessageItem(
        text: query,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    // Call Backend /chat endpoint with local fallback
    String botReply = "";
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ));
      final res = await dio.post(
        '${ApiConfig.baseUrl}/chat',
        data: {
          'message': query,
          'language': isTamil ? 'ta' : 'en',
        },
      );

      if (res.statusCode == 200 && res.data is Map) {
        botReply = res.data['response']?.toString() ?? "";
      }
    } catch (_) {}

    // Intelligent local fallback if offline
    if (botReply.isEmpty) {
      final qLower = query.toLowerCase();
      if (qLower.contains('book') || qLower.contains('முன்பதிவு')) {
        botReply = isTamil
            ? "சேவை முன்பதிவு செய்ய: 1) வகையைத் தேர்ந்தெடுக்கவும், 2) நேரத்தைத் தேர்வு செய்யவும், 3) கட்டணம் செலுத்தவும், 4) சரிபார்க்கப்பட்ட தொழிலாளர் நியமிக்கப்படுவார்."
            : "To book a service: Select category, choose date/time slot, complete payment, and our hybrid dispatch engine auto-allocates the nearest verified cooperative worker.";
      } else if (qLower.contains('emergency') || qLower.contains('sos') || qLower.contains('அவசரம்')) {
        botReply = isTamil
            ? "அவசர சேவை சில நிமிடங்களில் முன்னுரிமை ஒதுக்கீடு வழங்குகிறது. முகப்புத் திரையிலுள்ள சிவப்பு அவசர பொத்தானை அழுத்தவும்."
            : "Emergency SOS provides prioritized dispatch within minutes. Tap the red Emergency SOS button on the home screen.";
      } else if (qLower.contains('pay') || qLower.contains('upi') || qLower.contains('பணம்') || qLower.contains('கட்டணம்')) {
        botReply = isTamil
            ? "கட்டணங்கள் ரேஸர்பே மூலம் UPI (Google Pay, PhonePe), கார்டுகள் வழியாக பாதுகாப்பாக செலுத்தப்படுகின்றன. பணி முடிந்து OTP சரிபார்க்கப்பட்ட பிறகே விடுவிக்கப்படும்."
            : "Payments are securely processed via Razorpay with full support for UPI (Google Pay, PhonePe, Paytm), Net Banking, and Cards, held in escrow until OTP verification.";
      } else if (qLower.contains('ml') || qLower.contains('ai') || qLower.contains('matching') || qLower.contains('பொருத்தம்')) {
        botReply = isTamil
            ? "எங்கள் ஹைப்ரிட் AI ஒதுக்கீட்டு முறை 45% விதிமுறை + 35% ML பொருத்தம் + 20% கூட்டுறவு சமபங்கு போனஸ் அடிப்படையில் செயல்படுகிறது."
            : "Our Hybrid AI Dispatch Engine combines Stage 1 hard eligibility filters with 45% Rule Score + 35% ML Suitability (88% Top-1 Accuracy) + 20% Fairness Bonus.";
      } else if (qLower.contains('welfare') || qLower.contains('insurance') || qLower.contains('நலத்திட்டம்')) {
        botReply = isTamil
            ? "கூட்டுறவு உறுப்பினர்களுக்கு PMJJBY (₹2L ஆயுள் காப்பீடு), PMSBY (₹2L விபத்து காப்பீடு), மற்றும் கூட்டுறவு அவசர நிவாரண நிதி பலன்கள் கிடைக்கின்றன."
            : "Cooperative members are protected under PMJJBY (₹2L Life Insurance), PMSBY (₹2L Accident Cover), Ayushman Bharat PM-JAY (₹5L Health), and Co-op Emergency Relief.";
      } else {
        botReply = isTamil
            ? "வணக்கம்! நான் கூட்டுறவு சேவை உதவியாளர். சேவை முன்பதிவு, கட்டண முறைகள், மற்றும் நலத்திட்டங்கள் குறித்து உங்களுக்கு உதவ முடியும்."
            : "I am the Cooperative Service Assistant. I can help you with booking services, payment options, worker safety, and cooperative welfare benefits.";
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _messages.add(ChatMessageItem(
        text: botReply,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = Localizations.localeOf(context).languageCode == 'ta';
    final quickPrompts = isTamil ? _quickPromptsTa : _quickPromptsEn;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTamil ? 'சேவை உதவியாளர்' : 'Service Assistant',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  isTamil ? 'AI & கூட்டுறவு உதவி • ஆன்லைன்' : 'Cooperative AI • Online',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Action Chips Header
          Container(
            height: 52,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: quickPrompts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final prompt = quickPrompts[i];
                return ActionChip(
                  label: Text(
                    prompt,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5)),
                  ),
                  backgroundColor: const Color(0xFFEEF2FF),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () => _sendMessage(prompt),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                return _ChatBubble(message: msg);
              },
            ),
          ),

          // Typing Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isTamil ? 'உதவியாளர் பதிலளிக்கிறார்...' : 'Assistant is typing...',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: isTamil
                            ? 'சேவை, கட்டணம், உதவி பற்றி கேளுங்கள்...'
                            : 'Ask about services, payments, welfare...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF4F46E5),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessageItem message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 48),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF4F46E5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message.text,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFEEF2FF),
            child: Icon(Icons.smart_toy_rounded, color: Color(0xFF4F46E5), size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
