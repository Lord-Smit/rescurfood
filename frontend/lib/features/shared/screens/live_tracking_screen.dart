import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/donation_model.dart';
import '../../../providers/donation_provider.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(donationProvider.notifier).loadMyDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final donations = ref.watch(donationProvider).myDonations;
    final activeDonations = donations
        .where((d) =>
            d.status == DonationStatus.reserved ||
            d.status == DonationStatus.pickedUp)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16),
              title: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Tracking',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text('Track your pickups in real time',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          if (activeDonations.isEmpty && donations.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.check_circle_outline,
                        size: 72,
                        color: AppColors.primaryGreen.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    const Text('All caught up!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                        'No active pickups right now.\nDonate food to start tracking.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.bodyText)),
                  ],
                ),
              ),
            )
          else if (donations.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.local_shipping_outlined,
                        size: 72,
                        color: AppColors.bodyText.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text('No donations yet',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Upload a donation to start tracking',
                        style: TextStyle(color: AppColors.bodyText)),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _TrackingCard(donation: activeDonations[i]),
                childCount: activeDonations.length,
              ),
            ),

          // All donations timeline below
          if (donations.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('All Donations',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _DonationTimelineCard(donation: donations[i]),
                childCount: donations.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  final DonationModel donation;
  const _TrackingCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(donation.foodName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(donation.status.displayName,
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Info row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _InfoChip(
                    icon: Icons.scale,
                    label: '${donation.quantity} ${donation.unit}'),
                const SizedBox(width: 8),
                _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: donation.pickupAddress.length > 20
                        ? '${donation.pickupAddress.substring(0, 20)}...'
                        : donation.pickupAddress),
              ],
            ),
          ),
          // Timeline
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _TrackingTimeline(status: donation.status),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAF6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.bodyText),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.bodyText)),
        ],
      ),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  final DonationStatus status;
  const _TrackingTimeline({required this.status});

  int get _step {
    switch (status) {
      case DonationStatus.available:
        return 0;
      case DonationStatus.reserved:
        return 1;
      case DonationStatus.pickedUp:
        return 2;
      case DonationStatus.completed:
        return 3;
      case DonationStatus.expired:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Donation Listed', Icons.check_circle_outline),
      ('NGO Accepted', Icons.people_alt_outlined),
      ('Picked Up', Icons.local_shipping_outlined),
      ('Delivered', Icons.verified_outlined),
    ];
    final currentStep = _step;

    return Row(
      children: List.generate(steps.length, (i) {
        final done = currentStep >= i;
        final active = currentStep == i;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.primaryGreen
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: active
                            ? Border.all(
                                color: AppColors.primaryGreen, width: 2)
                            : null,
                      ),
                      child: Icon(steps[i].$2,
                          size: 14,
                          color: done ? Colors.white : Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[i].$1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 9,
                            color: done
                                ? AppColors.primaryGreen
                                : Colors.grey,
                            fontWeight: done
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    color: currentStep > i
                        ? AppColors.primaryGreen
                        : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _DonationTimelineCard extends StatelessWidget {
  final DonationModel donation;
  const _DonationTimelineCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(donation.status);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.fastfood, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donation.foodName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text('${donation.quantity} ${donation.unit}',
                    style: const TextStyle(
                        color: AppColors.bodyText, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(donation.status.displayName,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ),
        ],
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
        return const Color(0xFF388E3C);
      case DonationStatus.expired:
        return Colors.red;
    }
  }
}
