import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Choose Account Type'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Cooperative Gig Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select how you would like to participate in our labour cooperative network:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildAccountCard(
                      context: context,
                      role: UserRole.customer,
                      title: '1. Customer (Household / Institution)',
                      subtitle: 'Book certified cooperative electricians, plumbers, cleaners & technicians at fair tariffs.',
                      icon: Icons.home_outlined,
                      badgeText: 'Customer / Institution',
                    ),
                    const SizedBox(height: 14),
                    _buildAccountCard(
                      context: context,
                      role: UserRole.cooperativeWorker,
                      title: '2. Cooperative Worker-Owner',
                      subtitle: 'Pre-verified by Labour Association • Guaranteed fair allocation and patronage dividends.',
                      icon: Icons.verified_user_outlined,
                      badgeText: 'Co-op Worker (Pre-Verified)',
                    ),
                    const SizedBox(height: 14),
                    _buildAccountCard(
                      context: context,
                      role: UserRole.independentWorker,
                      title: '3. Independent Worker',
                      subtitle: 'Direct service provider outside cooperative hierarchy with self-set pricing.',
                      icon: Icons.handyman_outlined,
                      badgeText: 'Independent Worker',
                    ),
                    const SizedBox(height: 14),
                    _buildAccountCard(
                      context: context,
                      role: UserRole.cooperativeAssociationHead,
                      title: '4. Cooperative Association Head',
                      subtitle: 'District Labour Society Head managing member rosters, local tariffs and dispute arbitration.',
                      icon: Icons.account_balance_outlined,
                      badgeText: 'District Society Head',
                    ),
                    const SizedBox(height: 14),
                    _buildAccountCard(
                      context: context,
                      role: UserRole.superAdmin,
                      title: '5. Super Admin (State Federation)',
                      subtitle: 'State/National Federation Registrar overseeing platform-wide capacity and governance.',
                      icon: Icons.admin_panel_settings_outlined,
                      badgeText: 'Federation Super Admin',
                    ),
                  ],
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already registered? ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1.2),
      ),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.signup,
            arguments: role,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
