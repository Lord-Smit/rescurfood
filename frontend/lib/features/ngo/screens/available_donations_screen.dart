import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/donation_model.dart';
import '../../../providers/donation_provider.dart';

class AvailableDonationsScreen extends ConsumerWidget {
  const AvailableDonationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(donationProvider);
    final donations = state.availableDonations;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.availableDonations)),
      body: donations.isEmpty
          ? const EmptyState(
              icon: Icons.search_off,
              title: 'No donations available',
              subtitle: 'Check back later for new surplus food listings',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: donations.length,
              itemBuilder: (_, i) => _AvailableDonationCard(donation: donations[i]),
            ),
    );
  }
}

class _AvailableDonationCard extends StatelessWidget {
  final DonationModel donation;
  const _AvailableDonationCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.cream,
                  child: Icon(Icons.fastfood, color: AppColors.accentOrange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(donation.foodName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('by ${donation.donorName}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${donation.quantity} ${donation.unit}',
                      style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.bodyText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(donation.pickupAddress,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.bodyText),
                const SizedBox(width: 4),
                Text('Expires ${DateFormatters.relative(donation.expiryTime)}',
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: claim donation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Donation claimed (stub)')),
                    );
                  },
                  child: const Text('Claim'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
