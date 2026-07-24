import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/donation_provider.dart';

class ManageDonationsScreen extends ConsumerWidget {
  const ManageDonationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(donationProvider);
    final donations = state.allDonations;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.manageDonations),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: donations.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fastfood_outlined,
                      size: 48, color: AppColors.bodyText.withOpacity(0.4)),
                  const SizedBox(height: 8),
                  Text('No donations found',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTableHeader(context),
                const Divider(height: 1),
                ...donations.map((d) => _buildRow(context, d)),
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
          Expanded(flex: 2, child: Text('Food', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text('Donor', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, dynamic donation) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(donation.foodName)),
          Expanded(child: Text(donation.donorName)),
          Expanded(
            child: Chip(
              label: Text(donation.status.displayName, style: const TextStyle(fontSize: 10)),
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
