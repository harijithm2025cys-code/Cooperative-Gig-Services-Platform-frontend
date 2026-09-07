import 'package:flutter/material.dart';

class WorkerMessagesScreen extends StatefulWidget {
  const WorkerMessagesScreen({super.key});

  @override
  State<WorkerMessagesScreen> createState() => _WorkerMessagesScreenState();
}

class _WorkerMessagesScreenState extends State<WorkerMessagesScreen> {
  bool _isAvailable = true;
  int _navIndex = 2; // Messages active

  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Dhanabalan R',
      'initial': 'D',
      'color': const Color(0xFF5B21B6),
      'service': 'Electrical & AC Troubleshooting',
      'message': 'I am at home on the 3rd floor, flat 302.',
      'time': '10:18 AM',
      'isNew': true,
    },
    {
      'name': 'Ajaipravin S',
      'initial': 'A',
      'color': const Color(0xFF6D28D9),
      'service': 'Deep Foam Jet Servicing',
      'message': 'Please bring an extra water drainage pipe if possible.',
      'time': 'Yesterday',
      'isNew': false,
    },
    {
      'name': 'Cooperative Federation Dispatcher',
      'initial': 'C',
      'color': const Color(0xFF5B21B6),
      'service': 'Dispatch Notice',
      'message': 'Monthly cooperative dividend points credited to your account...',
      'time': '31 Aug',
      'isNew': false,
    },
  ];

  void _openChatThread(Map<String, dynamic> convo) {
    final textController = TextEditingController();
    final List<Map<String, String>> messages = [
      {'sender': 'customer', 'text': convo['message'] as String},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setChatState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SizedBox(
            height: 440,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: convo['color'] as Color,
                          child: Text(convo['initial'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(convo['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(convo['service'] as String, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6D28D9), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(color: Color(0xFFE2E8F0)),
                Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      final isMe = m['sender'] == 'me';
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF5B21B6) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            m['text'] ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white : const Color(0xFF1E293B),
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: 'Reply to ${convo['name']}...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFF5B21B6)),
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: () {
                        if (textController.text.trim().isNotEmpty) {
                          setChatState(() {
                            messages.add({'sender': 'me', 'text': textController.text.trim()});
                          });
                          textController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Worker Profile Header (Matching Screenshot)
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFF5B21B6),
                    child: Text('H', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Harijith M', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        SizedBox(height: 2),
                        Text('Senior Skilled Cooperative Specialist', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isAvailable ? const Color(0xFF10B981) : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isAvailable ? 'Available' : 'Offline',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _isAvailable ? const Color(0xFF1E293B) : Colors.grey),
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: _isAvailable,
                          activeThumbColor: const Color(0xFF5B21B6),
                          onChanged: (v) => setState(() => _isAvailable = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section Title: Customer Conversations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Customer Conversations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B21B6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('1 New', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Conversation Cards (Exact match to screenshot)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final c = _conversations[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: c['isNew'] == true ? const Color(0xFFDDD6FE) : const Color(0xFFE2E8F0),
                        width: c['isNew'] == true ? 1.5 : 1,
                      ),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: c['color'] as Color,
                        child: Text(c['initial'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                          Text(c['time'] as String, style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 3),
                          Text(c['service'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6D28D9))),
                          const SizedBox(height: 4),
                          Text(c['message'] as String, style: const TextStyle(fontSize: 13, color: Color(0xFF475569)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      onTap: () => _openChatThread(c),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        selectedItemColor: const Color(0xFF5B21B6),
        unselectedItemColor: const Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 0) Navigator.pop(context);
          setState(() => _navIndex = i);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Earnings'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
