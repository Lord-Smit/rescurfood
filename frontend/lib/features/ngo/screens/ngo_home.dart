import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/donation_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/donation_provider.dart';

class NgoHomeScreen extends ConsumerStatefulWidget {
  const NgoHomeScreen({super.key});

  @override
  ConsumerState<NgoHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends ConsumerState<NgoHomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(donationProvider.notifier).loadAvailableDonations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donations = ref.watch(donationProvider).availableDonations;
    final user = ref.watch(authProvider).user;

    final filtered = _query.isEmpty
        ? donations
        : donations
            .where((d) =>
                d.foodName.toLowerCase().contains(_query.toLowerCase()) ||
                d.donorName.toLowerCase().contains(_query.toLowerCase()) ||
                d.pickupAddress.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Welcome,',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(
                              user?.name.split(' ').first ?? 'NGO',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white24,
                        child: Text(
                          (user?.name.isNotEmpty == true)
                              ? user!.name[0].toUpperCase()
                              : 'N',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _confirmLogout(context, ref),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search food or location...',
                        hintStyle:
                            const TextStyle(color: AppColors.bodyText),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.bodyText),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                })
                            : const Icon(Icons.tune_outlined,
                                color: AppColors.bodyText),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        fillColor: Colors.transparent,
                        filled: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Count badge ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Text(
                    filtered.isEmpty
                        ? 'No donations found'
                        : '${filtered.length} donation${filtered.length == 1 ? '' : 's'} nearby',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Available',
                        style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),

          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: EmptyState(
                  icon: Icons.search_off,
                  title: _query.isNotEmpty
                      ? 'No results for "$_query"'
                      : 'No donations available',
                  subtitle: 'Check back later for new surplus food listings',
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _NearbyDonationCard(donation: filtered[i]),
                childCount: filtered.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _NearbyDonationCard extends ConsumerStatefulWidget {
  final DonationModel donation;
  const _NearbyDonationCard({required this.donation});

  @override
  ConsumerState<_NearbyDonationCard> createState() =>
      _NearbyDonationCardState();
}

class _NearbyDonationCardState extends ConsumerState<_NearbyDonationCard> {
  bool _loading = false;

  Future<void> _claim() async {
    setState(() => _loading = true);
    final success = await ref
        .read(donationProvider.notifier)
        .claimDonation(widget.donation.id);

    if (mounted) {
      setState(() => _loading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.donation.foodName} claimed successfully!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        final err = ref.read(donationProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err ?? 'Could not claim donation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.donation;
    final expiresIn = d.expiryTime.difference(DateTime.now());
    final urgentExpiry = expiresIn.inHours < 4;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Food icon container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.fastfood,
                      color: AppColors.primaryGreen, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.foodName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text('by ${d.donorName}',
                          style: const TextStyle(
                              color: AppColors.bodyText, fontSize: 12)),
                    ],
                  ),
                ),
                // Quantity badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${d.quantity} ${d.unit}',
                      style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Location
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.bodyText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(d.pickupAddress,
                      style: const TextStyle(
                          color: AppColors.bodyText, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Expiry
            Row(
              children: [
                Icon(Icons.schedule,
                    size: 14,
                    color: urgentExpiry
                        ? Colors.red
                        : AppColors.bodyText),
                const SizedBox(width: 4),
                Text(
                  urgentExpiry
                      ? 'Expires in ${expiresIn.inHours}h — Act fast!'
                      : 'Expires ${DateFormatters.relative(d.expiryTime)}',
                  style: TextStyle(
                      color: urgentExpiry ? Colors.red : AppColors.bodyText,
                      fontSize: 12,
                      fontWeight: urgentExpiry
                          ? FontWeight.w600
                          : FontWeight.normal),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Accept button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _claim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Accept',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _confirmLogout(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to log out of FoodLink?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(ctx);
            ref.read(authProvider.notifier).logout();
          },
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}

