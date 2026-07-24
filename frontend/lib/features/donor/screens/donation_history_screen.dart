import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/donation_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/donation_provider.dart';

class DonationHistoryScreen extends ConsumerStatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  ConsumerState<DonationHistoryScreen> createState() =>
      _DonationHistoryScreenState();
}

class _DonationHistoryScreenState
    extends ConsumerState<DonationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(donationProvider.notifier).loadMyDonations();
    });
  }

  Future<void> _refresh() async {
    await ref.read(donationProvider.notifier).loadMyDonations();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(donationProvider);
    final donations = state.myDonations;

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
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : donations.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  title: 'No history yet',
                  subtitle: 'Donations uploaded will appear here',
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: donations.length,
                    itemBuilder: (_, i) => _HistoryCard(donation: donations[i]),
                  ),
                ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DonationModel donation;
  const _HistoryCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(donation.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(Icons.fastfood, color: color, size: 20),
          ),
          title: Text(donation.foodName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${donation.quantity} ${donation.unit}  •  '
            '${DateFormatters.display(donation.createdAt)}',
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              donation.status.displayName,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ),
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
        return Colors.green.shade700;
      case DonationStatus.expired:
        return Colors.red;
    }
  }
}
