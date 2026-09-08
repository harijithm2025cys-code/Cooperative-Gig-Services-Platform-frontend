import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/language_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneOrEmailController = TextEditingController(text: '+919876543210');
  final _passwordController = TextEditingController(text: 'Demo@2024');
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String identifier, String password, UserRole role) async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.login(
      username: identifier.trim(),
      password: password,
      role: role,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged in as ${role.label} (${auth.currentUser?.name ?? "User"})'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );

      switch (role) {
        case UserRole.cooperativeWorker:
        case UserRole.independentWorker:
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.workerHome, (r) => false);
          break;
        case UserRole.cooperativeAssociationHead:
        case UserRole.superAdmin:
          Navigator.pushNamedAndRemoveUntil(context, '/admin_dashboard', (r) => false);
          break;
        case UserRole.customer:
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.householdHome, (r) => false);
          break;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Sign in failed. Check credentials.'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  void _submitForm() {
    final input = _phoneOrEmailController.text.trim();
    final pwd = _passwordController.text;

    // Detect target role based on input pattern or default to customer
    UserRole targetRole = UserRole.customer;
    if (input.contains('worker')) {
      targetRole = UserRole.cooperativeWorker;
    } else if (input.contains('admin') || input.contains('coop')) {
      targetRole = UserRole.superAdmin;
    }

    _handleLogin(input, pwd, targetRole);
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = Localizations.localeOf(context).languageCode == 'ta';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isTamil ? 'உள்நுழைவு' : 'Login',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A)),
        ),
        actions: [
          const LanguageSelector(compact: true),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                SizedBox(width: 5),
                Text(
                  'Supabase Live',
                  style: TextStyle(color: Color(0xFF065F46), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                isTamil ? 'மீண்டும் வருக!' : 'Welcome Back',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isTamil
                    ? 'உங்கள் தொலைபேசி எண் அல்லது மின்னஞ்சல் மூலம் உள்நுழைக'
                    : 'Login with your phone number or email',
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 28),

              // Phone / Email Field
              Text(
                isTamil ? 'தொலைபேசி / மின்னஞ்சல்' : 'Phone / Email',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneOrEmailController,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: isTamil ? 'தொலைபேசி அல்லது மின்னஞ்சல்' : 'Enter phone or email',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF4F46E5)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Password Field
              Text(
                isTamil ? 'கடவுச்சொல்' : 'Password',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: isTamil ? 'கடவுச்சொல்லை உள்ளிடவும்' : 'Enter password',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF4F46E5)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isTamil ? 'உள்நுழைய' : 'Login',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Register Link
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                  child: Text(
                    isTamil ? 'கணக்கு இல்லையா? பதிவு செய்க' : "Don't have an account? Register",
                    style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 12),

              // Demo Accounts Header
              Center(
                child: Text(
                  isTamil ? 'விரைவு டெமோ கணக்குகள் (ஒரே தட்டலில் உள்நுழைவு)' : 'Quick Demo Accounts (1-Tap Login)',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 1. Customer Demo Tile
              _DemoLoginTile(
                title: isTamil ? 'டெமோ வாடிக்கையாளர் (அனன்யா ஷர்மா)' : 'Demo Customer (Ananya Sharma)',
                subtitle: isTamil ? 'அனன்யா ஷர்மா - சேவை முன்பதிவு, வரைபடம், கட்டணம்' : 'Ananya Sharma - Book services, view map, checkout',
                icon: Icons.person_rounded,
                color: const Color(0xFF4F46E5),
                onTap: () => _handleLogin('ananya@example.com', 'Demo@2024', UserRole.customer),
              ),
              const SizedBox(height: 10),

              // 2. Worker Demo Tile
              _DemoLoginTile(
                title: isTamil ? 'டெமோ தொழிலாளர் (ரமேஷ் குமார்)' : 'Demo Worker (Ramesh Kumar)',
                subtitle: isTamil ? 'ரமேஷ் குமார் - வேலை ஏற்க, வருவாய் & பணப்பை விவரங்கள்' : 'Ramesh Kumar - Accept job requests, view wallet & earnings',
                icon: Icons.handyman_rounded,
                color: const Color(0xFF10B981),
                onTap: () => _handleLogin('ramesh.worker@coop.org', 'Demo@2024', UserRole.cooperativeWorker),
              ),
              const SizedBox(height: 10),

              // 3. Cooperative Demo Tile
              _DemoLoginTile(
                title: isTamil ? 'டெமோ கூட்டுறவு சங்கம் (பிரியா மேனன்)' : 'Demo Cooperative (Priya Menon)',
                subtitle: isTamil ? 'உறுப்பினர் பட்டியல், வேலை ஒதுக்கீடு' : 'Manage roster, assign member jobs',
                icon: Icons.groups_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () => _handleLogin('admin@abccoop.org', 'Demo@2024', UserRole.cooperativeAssociationHead),
              ),
              const SizedBox(height: 10),

              // 4. Platform Admin Demo Tile
              _DemoLoginTile(
                title: isTamil ? 'டெமோ பிளாட்ஃபார்ம் நிர்வாகி' : 'Demo Platform Admin',
                subtitle: isTamil ? 'KYC ஒப்புதல், பகுப்பாய்வு & புள்ளிவிவரங்கள்' : 'KYC approval queue, analytics & stats',
                icon: Icons.admin_panel_settings_rounded,
                color: const Color(0xFF7C3AED),
                onTap: () => _handleLogin('admin@coop.org', 'Demo@2024', UserRole.superAdmin),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoLoginTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DemoLoginTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
