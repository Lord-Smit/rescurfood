import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageUsers),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTableHeader(context),
          const Divider(height: 1),
          _buildEmptyRow(context),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cream.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 2, child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text('Role', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildEmptyRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 48, color: AppColors.bodyText.withOpacity(0.4)),
            const SizedBox(height: 8),
            Text('No users found', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
