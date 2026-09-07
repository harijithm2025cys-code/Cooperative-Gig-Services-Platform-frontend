import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  UserRole _selectedRole = UserRole.worker;
  final _nameController = TextEditingController(text: 'Harijith M');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _emailController = TextEditingController(text: 'harijith@gmail.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _locationController = TextEditingController(text: 'Coimbatore, Tamil Nadu');
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
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account registered with National Cooperative Database!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      if (_selectedRole == UserRole.worker) {
        Navigator.pushReplacementNamed(context, AppRoutes.workerHome);
      } else if (_selectedRole == UserRole.admin) {
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
        title: const Text('Choose Account Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              const Text('Select how you want to continue', style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B))),
              const SizedBox(height: 16),

              // Role Card 1: Customer
              _buildRoleOption(
                role: UserRole.household,
                title: 'Customer',
                subtitle: 'I need a service',
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF7C3AED),
              ),
              const SizedBox(height: 12),

              // Role Card 2: Independent Worker
              _buildRoleOption(
                role: UserRole.worker,
                title: 'Independent Worker',
                subtitle: 'I provide services',
                icon: Icons.handyman_outlined,
                iconColor: const Color(0xFFD97706),
              ),
              const SizedBox(height: 12),

              // Role Card 3: Cooperative Federation
              _buildRoleOption(
                role: UserRole.admin,
                title: 'Cooperative Federation',
                subtitle: 'We manage skilled workers',
                icon: Icons.group_work_outlined,
                iconColor: const Color(0xFF0D9488),
              ),
              const SizedBox(height: 16),

              const Center(
                child: Text('You can change this later in settings', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ),
              const SizedBox(height: 24),

              // Form Title
              Text(
                'Create Your Account (${_selectedRole == UserRole.worker ? "Worker" : _selectedRole == UserRole.admin ? "Federation" : "Customer"})',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 14),

              // Input: Name
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),

              // Input: Phone
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 12),

              // Input: Email
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.mail_outline,
              ),
              const SizedBox(height: 12),

              // Input: Password
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
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

              // Input: Location
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 20),
                  suffixIcon: const Icon(Icons.map_outlined, color: Color(0xFF6D28D9), size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 16),

              // Checkbox: Terms
              Row(
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    activeColor: const Color(0xFF5B21B6),
                    onChanged: (v) => setState(() => _agreeTerms = v!),
                  ),
                  const Text('I agree to ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const Text('Terms & Conditions', style: TextStyle(fontSize: 13, color: Color(0xFF5B21B6), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              // Button: Create Account (Purple)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B21B6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _handleRegister,
                  child: const Text('Create Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
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
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFF5B21B6) : const Color(0xFFCBD5E1), width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF5B21B6)),
                      ),
                    )
                  : null,
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
        hintText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
    );
  }
}
