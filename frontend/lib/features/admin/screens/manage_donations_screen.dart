import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/donation_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/donation_provider.dart';

class ManageDonationsScreen extends ConsumerStatefulWidget {
  const ManageDonationsScreen({super.key});

  @override
  ConsumerState<ManageDonationsScreen> createState() =>
      _ManageDonationsScreenState();
}

class _ManageDonationsScreenState
    extends ConsumerState<ManageDonationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(donationProvider.notifier).loadAllDonations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(donationProvider.notifier).loadAllDonations();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(donationProvider);
    final donations = state.allDonations;

    final filteredDonations = donations.where((d) {
      final matchesQuery = _query.isEmpty ||
          d.foodName.toLowerCase().contains(_query.toLowerCase()) ||
          d.donorName.toLowerCase().contains(_query.toLowerCase()) ||
          d.pickupAddress.toLowerCase().contains(_query.toLowerCase());

      bool matchesStatus = true;
      if (_selectedStatus == 'available') {
        matchesStatus = d.status == DonationStatus.available;
      } else if (_selectedStatus == 'reserved') {
        matchesStatus = d.status == DonationStatus.reserved;
      } else if (_selectedStatus == 'picked_up') {
        matchesStatus = d.status == DonationStatus.pickedUp;
      } else if (_selectedStatus == 'completed') {
        matchesStatus = d.status == DonationStatus.completed;
      } else if (_selectedStatus == 'expired') {
        matchesStatus = d.status == DonationStatus.expired;
      }

      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),
      appBar: AppBar(
        title: const Text(AppStrings.manageDonations),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            color: Colors.white,
            child: Column(
              children: [
                // Search TextField
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search food, donor, or address...',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip('all', 'All (${donations.length})'),
                      const SizedBox(width: 8),
                      _buildStatusChip('available', 'Available 🌿'),
                      const SizedBox(width: 8),
                      _buildStatusChip('reserved', 'Reserved ⏳'),
                      const SizedBox(width: 8),
                      _buildStatusChip('picked_up', 'Picked Up 🚚'),
                      const SizedBox(width: 8),
                      _buildStatusChip('completed', 'Completed ✅'),
                      const SizedBox(width: 8),
                      _buildStatusChip('expired', 'Expired 🚨'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Donations List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredDonations.isEmpty
                    ? const EmptyState(
                        icon: Icons.fastfood_outlined,
                        title: 'No matching donations',
                        subtitle:
                            'Try adjusting your search query or status filter',
                      )
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: filteredDonations.length,
                          itemBuilder: (_, i) => _DonationAdminCard(
                            donation: filteredDonations[i],
                            onTap: () =>
                                _showDonationDetailModal(filteredDonations[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String statusId, String label) {
    final isSelected = _selectedStatus == statusId;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: const Color(0xFFF0F4F0),
      onSelected: (selected) {
        if (selected) setState(() => _selectedStatus = statusId);
      },
    );
  }

  void _showDonationDetailModal(DonationModel d) {
    final statusColor = _statusColor(d.status);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.fastfood, color: statusColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.foodName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            d.status.displayName,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              _buildModalDetailRow(Icons.scale, 'Quantity',
                  '${d.quantity} ${d.unit}'),
              const SizedBox(height: 10),
              _buildModalDetailRow(Icons.storefront_outlined, 'Donor',
                  d.donorName.isNotEmpty ? d.donorName : 'Anonymous'),
              const SizedBox(height: 10),
              _buildModalDetailRow(Icons.location_on_outlined, 'Pickup Location',
                  d.pickupAddress),
              const SizedBox(height: 10),
              _buildModalDetailRow(Icons.schedule, 'Listed Date',
                  DateFormatters.display(d.createdAt)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Text('$label: ',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ),
      ],
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
        return Colors.purple;
      case DonationStatus.expired:
        return Colors.red;
    }
  }
}

class _DonationAdminCard extends StatelessWidget {
  final DonationModel donation;
  final VoidCallback onTap;

  const _DonationAdminCard({required this.donation, required this.onTap});

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
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(Icons.fastfood, color: color, size: 20),
          ),
          title: Text(donation.foodName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                'Donor: ${donation.donorName.isNotEmpty ? donation.donorName : "Anonymous"}',
                style: const TextStyle(fontSize: 12, color: AppColors.bodyText),
              ),
              const SizedBox(height: 2),
              Text(
                '${donation.quantity} ${donation.unit} • ${DateFormatters.display(donation.createdAt)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  donation.status.displayName,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: color),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
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

