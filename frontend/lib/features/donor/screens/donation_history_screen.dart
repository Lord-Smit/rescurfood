import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/donation_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/donation_provider.dart';

class DonationHistoryScreen extends ConsumerWidget {
  const DonationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(donationProvider);
    final completed = state.myDonations
        .where((d) =>
            d.status == DonationStatus.completed || d.status == DonationStatus.expired)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.donationHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: completed.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              title: 'No history yet',
              subtitle: 'Completed donations will appear here',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: completed.length,
              itemBuilder: (_, i) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.cream,
                    child: Icon(Icons.history, color: AppColors.bodyText),
                  ),
                  title: Text(completed[i].foodName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${completed[i].quantity} ${completed[i].unit}  •  '
                    '${DateFormatters.display(completed[i].createdAt)}',
                  ),
                  trailing: Chip(
                    label: Text(completed[i].status.displayName,
                        style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.grey.withOpacity(0.15),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ),
    );
  }
}
