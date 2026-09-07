import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'ananya@example.com');
  final _passwordController = TextEditingController(text: 'password123');

  UserRole _selectedRole = UserRole.household;
  bool _obscurePassword = true;
  bool _isAdminMode = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      _isAdminMode = (role == UserRole.admin);
      if (role == UserRole.worker) {
        _usernameController.text = 'ramesh.worker@coop.org';
        _passwordController.text = 'worker123';
      } else if (role == UserRole.admin) {
        _usernameController.text = 'admin@coop.org';
        _passwordController.text = 'admin123';
      } else {
        _usernameController.text = 'ananya@example.com';
        _passwordController.text = 'password123';
      }
    });
  }

  void _toggleAdminMode() {
    setState(() {
      _isAdminMode = !_isAdminMode;
      _onRoleChanged(_isAdminMode ? UserRole.admin : UserRole.household);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isAdminMode ? '🔐 Switched to Cooperative Admin Portal' : 'Switched to Public User Portal'),
        duration: const Duration(seconds: 1),
        backgroundColor: _isAdminMode ? const Color(0xFF0F766E) : AppColors.primary,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signed in as ${_selectedRole.label} (Connected to Supabase)'),
          backgroundColor: AppColors.statusCompleted,
        ),
      );

      if (_selectedRole == UserRole.worker) {
        Navigator.pushReplacementNamed(context, AppRoutes.workerHome);
      } else if (_selectedRole == UserRole.admin) {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.householdHome);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Sign in failed. Check credentials.'),
          backgroundColor: AppColors.statusCancelled,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Card(
              elevation: 0,
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.border, width: 1.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row with Discreet Admin Access
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.cloud_done_rounded, size: 12, color: AppColors.primaryDark),
                                SizedBox(width: 4),
                                Text(
                                  'Supabase Cloud DB',
                                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                          ),
                          // Hidden/discreet admin lock toggle
                          IconButton(
                            icon: Icon(
                              _isAdminMode ? Icons.admin_panel_settings : Icons.lock_outline_rounded,
                              size: 19,
                              color: _isAdminMode ? AppColors.primary : AppColors.textTertiary,
                            ),
                            tooltip: _isAdminMode ? 'Exit Admin Mode' : 'Admin Portal Access',
                            onPressed: _toggleAdminMode,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Header Icon
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _isAdminMode ? const Color(0xFFCCFBF1) : AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isAdminMode ? Icons.admin_panel_settings_rounded : Icons.handshake_outlined,
                            size: 34,
                            color: _isAdminMode ? const Color(0xFF0F766E) : AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          _isAdminMode ? 'Cooperative Admin Portal' : 'Cooperative Sign In',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          _isAdminMode ? 'Authorised Guild Staff & Auditors Only' : 'Member-Owned Labour Platform',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Role Selector Segmented Button (Only Household & Worker visible publicly)
                      if (!_isAdminMode) ...[
                        SegmentedButton<UserRole>(
                          segments: const [
                            ButtonSegment(
                              value: UserRole.customer,
                              label: Text('Customer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              icon: Icon(Icons.home_outlined, size: 18),
                            ),
                            ButtonSegment(
                              value: UserRole.cooperativeWorker,
                              label: Text('Worker-Owner', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              icon: Icon(Icons.handyman_outlined, size: 18),
                            ),
                          ],
                          selected: {_selectedRole},
                          onSelectionChanged: (set) => _onRoleChanged(set.first),
                          style: ButtonStyle(
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF99F6E4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shield_outlined, color: Color(0xFF0F766E), size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Admin Mode Active (Supervisory Access)',
                                  style: TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Username/Email Field
                      const Text('Email or Phone', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
                          hintText: 'Enter email or phone',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your username' : null,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          hintText: 'Enter password',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Please enter password' : null,
                      ),
                      const SizedBox(height: 8),

                      // Pre-filled Demo badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Supabase Test Account: ${_selectedRole.label}',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleLogin,
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  _isAdminMode ? 'Access Admin Dashboard' : 'Sign In',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Register Link
                      if (!_isAdminMode) ...[
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "New member? ",
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.signup, arguments: _selectedRole);
                                },
                                child: const Text(
                                  'Register Now',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Hidden/Discreet Admin Footer Link
                        Center(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textTertiary,
                              textStyle: const TextStyle(fontSize: 11),
                            ),
                            icon: const Icon(Icons.shield_outlined, size: 13),
                            label: const Text('Co-op Officer / Admin Access'),
                            onPressed: _toggleAdminMode,
                          ),
                        ),
                      ] else ...[
                        Center(
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            icon: const Icon(Icons.arrow_back_rounded, size: 14),
                            label: const Text('Back to Member Sign In'),
                            onPressed: _toggleAdminMode,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
