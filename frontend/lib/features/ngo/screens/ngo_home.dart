import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
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
  String _selectedCategory = 'all';

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'All 🍱'},
    {'id': 'cooked', 'label': 'Cooked 🍛'},
    {'id': 'bakery', 'label': 'Bakery 🥐'},
    {'id': 'produce', 'label': 'Produce 🥦'},
    {'id': 'groceries', 'label': 'Groceries 📦'},
    {'id': 'non_veg', 'label': 'Non-Veg 🍗'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(donationProvider.notifier).loadAvailableDonations();
    });
  }

  Future<void> _refresh() async {
    await ref.read(donationProvider.notifier).loadAvailableDonations();
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

    final filtered = donations.where((d) {
      final matchesQuery = _query.isEmpty ||
          d.foodName.toLowerCase().contains(_query.toLowerCase()) ||
          d.donorName.toLowerCase().contains(_query.toLowerCase()) ||
          d.pickupAddress.toLowerCase().contains(_query.toLowerCase());

      bool matchesCategory = true;
      if (_selectedCategory == 'non_veg') {
        matchesCategory = d.foodName.toLowerCase().contains('non-veg') ||
            d.foodName.toLowerCase().contains('chicken') ||
            d.foodName.toLowerCase().contains('mutton') ||
            d.foodName.toLowerCase().contains('meat');
      } else if (_selectedCategory == 'cooked') {
        matchesCategory = !d.foodName.toLowerCase().contains('bread') &&
            !d.foodName.toLowerCase().contains('pastry');
      } else if (_selectedCategory == 'bakery') {
        matchesCategory = d.foodName.toLowerCase().contains('bread') ||
            d.foodName.toLowerCase().contains('pastry') ||
            d.foodName.toLowerCase().contains('cake');
      } else if (_selectedCategory == 'produce') {
        matchesCategory = d.foodName.toLowerCase().contains('fruit') ||
            d.foodName.toLowerCase().contains('veg');
      }

      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
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

            // ── Category Filter Bar ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 54,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: _categories.length,
                  itemBuilder: (ctx, i) {
                    final cat = _categories[i];
                    final isSelected = _selectedCategory == cat['id'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat['label']!),
                        selected: isSelected,
                        selectedColor: AppColors.primaryGreen,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.white,
                        elevation: isSelected ? 2 : 0,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat['id']!);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Count badge ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    Text(
                      filtered.isEmpty
                          ? 'No donations found'
                          : '${filtered.length} surplus donation${filtered.length == 1 ? '' : 's'} available',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Live Feed',
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
                        : 'No surplus food in this category',
                    subtitle: 'Try changing your filter or check back later',
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
    
    // Urgency Badging Logic
    Color badgeBg;
    Color badgeFg;
    String expiryText;

    if (expiresIn.inMinutes <= 0) {
      badgeBg = Colors.red.shade100;
      badgeFg = Colors.red.shade900;
      expiryText = '🚨 Expired';
    } else if (expiresIn.inHours < 3) {
      badgeBg = Colors.red.shade50;
      badgeFg = Colors.red.shade800;
      expiryText = '🔥 Urgent Rescue! (${expiresIn.inHours}h ${expiresIn.inMinutes % 60}m left)';
    } else if (expiresIn.inHours < 12) {
      badgeBg = Colors.amber.shade100;
      badgeFg = Colors.amber.shade900;
      expiryText = '⏳ Expiring Today (${expiresIn.inHours}h left)';
    } else {
      badgeBg = AppColors.primaryGreen.withValues(alpha: 0.12);
      badgeFg = AppColors.primaryGreen;
      expiryText = '🌿 Valid for ${expiresIn.inDays > 0 ? '${expiresIn.inDays}d ' : ''}${expiresIn.inHours % 24}h';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
                // Food Image / Icon Thumbnail Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: d.photoUrl != null && d.photoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            d.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.fastfood,
                                color: AppColors.primaryGreen,
                                size: 26),
                          ),
                        )
                      : const Icon(Icons.fastfood,
                          color: AppColors.primaryGreen, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.foodName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('by ${d.donorName.isNotEmpty ? d.donorName : 'Donor'}',
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
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${d.quantity} ${d.unit}',
                      style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Location
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 15, color: AppColors.bodyText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(d.pickupAddress,
                      style: const TextStyle(
                          color: AppColors.bodyText, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Expiry Urgency Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    expiryText,
                    style: TextStyle(
                      color: badgeFg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Accept / Claim button
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
                    : const Text('Accept & Claim Food',
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

