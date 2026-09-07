import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  UserRole _selectedRole = UserRole.cooperativeWorker;
  final _nameController = TextEditingController(text: 'Harijith M');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _emailController = TextEditingController(text: 'harijith@gmail.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _locationController = TextEditingController(text: 'Coimbatore, Tamil Nadu');
  final _memberIdController = TextEditingController(text: 'ABC-COOP-1042');
  final _skillController = TextEditingController(text: 'Electrician & Diagnostic Tech');
  final _rateController = TextEditingController(text: '450');
  final _societyNameController = TextEditingController(text: 'ABC Skilled Workers Co-op');

  bool _obscurePassword = true;
  bool _agreeTerms = true;

  void _handleRegister() async {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Conditions.')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
      address: _locationController.text.trim(),
      skill: _skillController.text.trim(),
      memberRegId: _memberIdController.text.trim(),
      societyName: _societyNameController.text.trim(),
      hourlyRate: double.tryParse(_rateController.text.trim()),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_selectedRole == UserRole.cooperativeWorker
              ? '✓ Cooperative Member pre-verified and registered!'
              : '✓ Account created successfully!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );

      if (_selectedRole == UserRole.cooperativeWorker || _selectedRole == UserRole.independentWorker) {
        Navigator.pushReplacementNamed(context, AppRoutes.workerHome);
      } else if (_selectedRole == UserRole.cooperativeAssociationHead || _selectedRole == UserRole.superAdmin) {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.householdHome);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Choose Account Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select your platform persona (5 Roles Architecture):',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              const SizedBox(height: 14),

              // Role 1: Customer
              _buildRoleOption(
                role: UserRole.customer,
                title: '1. Customer (Household / Institution)',
                subtitle: 'Book verified skilled services at standard society rates',
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF7C3AED),
              ),
              const SizedBox(height: 10),

              // Role 2: Cooperative Worker-Owner
              _buildRoleOption(
                role: UserRole.cooperativeWorker,
                title: '2. Cooperative Worker-Owner',
                subtitle: 'Pre-verified by Labour Society • Fair allocation & dividends',
                icon: Icons.verified_user_rounded,
                iconColor: const Color(0xFF059669),
                isPreVerifiedBadge: true,
              ),
              const SizedBox(height: 10),

              // Role 3: Independent Worker
              _buildRoleOption(
                role: UserRole.independentWorker,
                title: '3. Independent Worker',
                subtitle: 'Works outside cooperative hierarchy • Self-set hourly pricing',
                icon: Icons.handyman_outlined,
                iconColor: const Color(0xFFD97706),
              ),
              const SizedBox(height: 10),

              // Role 4: Cooperative Association Head
              _buildRoleOption(
                role: UserRole.cooperativeAssociationHead,
                title: '4. Cooperative Association Head',
                subtitle: 'District Society Head • Manages members, tariffs & disputes',
                icon: Icons.account_balance_rounded,
                iconColor: const Color(0xFF5B21B6),
              ),
              const SizedBox(height: 10),

              // Role 5: Super Admin
              _buildRoleOption(
                role: UserRole.superAdmin,
                title: '5. Super Admin (State Federation)',
                subtitle: 'National/State Federation Registrar • Platform-wide oversight',
                icon: Icons.admin_panel_settings_rounded,
                iconColor: const Color(0xFF1E293B),
              ),
              const SizedBox(height: 20),

              // Sub-form details according to selected role
              Text(
                'Registration Details: ${_selectedRole.label}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 14),

              _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone_outlined),
              const SizedBox(height: 12),
              _buildTextField(controller: _emailController, label: 'Email Address', icon: Icons.mail_outline),
              const SizedBox(height: 12),

              if (_selectedRole == UserRole.cooperativeWorker) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pre-Verified by Cooperative Association. Zero duplicate onboarding verification required.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF065F46), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(controller: _societyNameController, label: 'Cooperative Society Name', icon: Icons.group_work_outlined),
                const SizedBox(height: 12),
                _buildTextField(controller: _memberIdController, label: 'Cooperative Member ID', icon: Icons.badge_outlined),
                const SizedBox(height: 12),
                _buildTextField(controller: _skillController, label: 'Primary Trade Skill', icon: Icons.build_outlined),
                const SizedBox(height: 12),
              ] else if (_selectedRole == UserRole.independentWorker) ...[
                _buildTextField(controller: _skillController, label: 'Trade Skill', icon: Icons.build_outlined),
                const SizedBox(height: 12),
                _buildTextField(controller: _rateController, label: 'Self-Set Hourly Rate (₹)', icon: Icons.currency_rupee_rounded),
                const SizedBox(height: 12),
              ] else if (_selectedRole == UserRole.cooperativeAssociationHead) ...[
                _buildTextField(controller: _societyNameController, label: 'Labour Society Name', icon: Icons.apartment_rounded),
                const SizedBox(height: 12),
              ],

              // Password input
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B), size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: const Color(0xFF64748B)),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 12),

              _buildTextField(controller: _locationController, label: 'Service Location / City', icon: Icons.location_on_outlined),
              const SizedBox(height: 16),

              // Terms checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    activeColor: const Color(0xFF5B21B6),
                    onChanged: (v) => setState(() => _agreeTerms = v!),
                  ),
                  const Text('I agree to the ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const Text('Cooperative Federation Charter', style: TextStyle(fontSize: 13, color: Color(0xFF5B21B6), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: App3D.button3D(backgroundColor: AppColors.primary, borderRadius: 14),
                  onPressed: _handleRegister,
                  child: Text('Register as ${_selectedRole.shortLabel}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    bool isPreVerifiedBadge = false,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF5B21B6) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? const [BoxShadow(color: Color(0x1A5B21B6), blurRadius: 6, offset: Offset(0, 2))] : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      ),
                      if (isPreVerifiedBadge)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Pre-Verified', style: TextStyle(fontSize: 10, color: Color(0xFF047857), fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF5B21B6) : const Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
    );
  }
}
