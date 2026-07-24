import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/user_model.dart';

class RoleSelectScreen extends StatelessWidget {
  final void Function(UserRole role) onRoleSelected;

  const RoleSelectScreen({super.key, required this.onRoleSelected});

  @override
  Widget build(BuildContext context) {
    final roles = UserRole.values;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Icon(Icons.eco, size: 80, color: AppColors.primaryGreen),
              const SizedBox(height: 16),
              Text(AppStrings.appName,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      )),
              Text(AppStrings.tagline,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.bodyText,
                      )),
              const Spacer(),
              Text('I am a...',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              ...roles.map((role) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => onRoleSelected(role),
                        icon: _roleIcon(role),
                        label: Text(role.displayName),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  )),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.donor:
        return const Icon(Icons.store, color: AppColors.accentOrange);
      case UserRole.ngo:
        return const Icon(Icons.volunteer_activism, color: AppColors.primaryGreen);
      case UserRole.admin:
        return const Icon(Icons.shield, color: AppColors.bodyText);
    }
  }
}
