import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/donation_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/donation_provider.dart';

class DonorHomeScreen extends ConsumerWidget {
  const DonorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(donationProvider);
    final donations = state.myDonations;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.donorHome),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: donations.isEmpty
          ? const EmptyState(
              icon: Icons.restaurant_menu,
              title: 'No donations yet',
              subtitle: 'Tap + to upload your first food donation',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: donations.length,
              itemBuilder: (_, i) => _DonationCard(donation: donations[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/donor/upload'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final DonationModel donation;
  const _DonationCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.cream,
          child: Icon(Icons.fastfood, color: AppColors.accentOrange),
        ),
        title: Text(donation.foodName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${donation.quantity} ${donation.unit}  •  ${DateFormatters.relative(donation.expiryTime)}',
        ),
        trailing: Chip(
          label: Text(donation.status.displayName,
              style: const TextStyle(fontSize: 11)),
          backgroundColor: _statusColor(donation.status).withOpacity(0.15),
          side: BorderSide.none,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
        onTap: () {
          // TODO: donation detail
        },
      ),
    );
  }

  Color _statusColor(DonationStatus status) {
    switch (status) {
      case DonationStatus.available:
        return AppColors.primaryGreen;
      case DonationStatus.reserved:
        return AppColors.accentOrange;
      case DonationStatus.pickedUp:
        return Colors.blue;
      case DonationStatus.completed:
        return Colors.grey;
      case DonationStatus.expired:
        return Colors.red;
    }
  }
}
