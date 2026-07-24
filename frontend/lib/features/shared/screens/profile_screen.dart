import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/donation_model.dart';
import '../../../models/request_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/donation_provider.dart';
import '../../../services/user_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final donationState = ref.watch(donationProvider);
    final user = authState.user;
    if (user == null) return const SizedBox.shrink();

    final isDonor = user.role == UserRole.donor;
    final isNgo = user.role == UserRole.ngo;

    final deliveredCount = isDonor
        ? donationState.myDonations
            .where((d) => d.status == DonationStatus.completed)
            .length
        : donationState.myRequests
            .where((r) => r.status == RequestStatus.completed)
            .length;

    final totalCount = isDonor
        ? donationState.myDonations.length
        : donationState.myRequests.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF6),
      body: CustomScrollView(
        slivers: [
          // ── Header ───────────────────────────────────────────────────────
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
                  20, MediaQuery.of(context).padding.top + 20, 20, 28),
              child: Column(
                children: [
                  const Text('My Profile',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  // Avatar
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white24,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _roleLabel(user.role),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Contact info
                  if (user.email.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.email_outlined,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Text(user.email,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  if (user.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone_outlined,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Text(user.phone,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Stats Row ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  _StatBox(
                    value: '$totalCount',
                    label: isDonor
                        ? 'Total\nDonations'
                        : isNgo
                            ? 'Total\nRequests'
                            : 'Platform\nUsers',
                    icon: isDonor ? Icons.fastfood : Icons.assignment,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 12),
                  _StatBox(
                    value: '$deliveredCount',
                    label: isDonor
                        ? 'Delivered\nMeals'
                        : isNgo
                            ? 'Claimed\nFood'
                            : 'Completed',
                    icon: Icons.check_circle_outline,
                    color: AppColors.accentOrange,
                  ),
                  const SizedBox(width: 12),
                  _StatBox(
                    value: totalCount > 0
                        ? '${((deliveredCount / totalCount) * 100).round()}%'
                        : '100%',
                    label: 'Success\nRate',
                    icon: Icons.trending_up,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),

          // ── Menu Items ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bodyText)),
                  const SizedBox(height: 8),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline,
                        label: 'Personal Information',
                        onTap: () => _editPersonalInfo(context, user),
                      ),
                      _MenuItem(
                        icon: isNgo
                            ? Icons.assignment_outlined
                            : Icons.fastfood_outlined,
                        label: isNgo
                            ? 'My Requests'
                            : isDonor
                                ? 'My Donations'
                                : 'Manage Donations',
                        onTap: () {
                          if (isDonor) {
                            context.go('/donor/history');
                          } else if (isNgo) {
                            context.go('/ngo/requests');
                          } else {
                            context.go('/admin/donations');
                          }
                        },
                      ),
                      _MenuItem(
                        icon: Icons.bar_chart_outlined,
                        label: 'My Impact',
                        onTap: () => _showMyImpact(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('App',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.bodyText)),
                  const SizedBox(height: 8),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () => _showSettings(context),
                      ),
                      _MenuItem(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        onTap: () => _showHelpSupport(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Logout ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _editPersonalInfo(BuildContext context, UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Personal Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                    labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                    labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          setModalState(() => saving = true);
                          try {
                            final updatedUser = await _userService.updateProfile({
                              'name': nameCtrl.text.trim(),
                              'email': emailCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                            });
                            ref.read(authProvider.notifier).checkAuth();
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Profile updated successfully!'),
                                    backgroundColor: AppColors.primaryGreen),
                              );
                            }
                          } catch (e) {
                            setModalState(() => saving = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                    content: Text('Error updating profile: $e'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save Changes',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMyImpact(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => FutureBuilder<Map<String, dynamic>>(
        future: _userService.getImpact(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final impact = snapshot.data ?? {};
          final meals = impact['meals_saved'] ?? 0;
          final co2 = impact['co2_saved_kg'] ?? 0.0;
          final rank = impact['rank'] ?? 'Food Saver';
          final deliveries = impact['deliveries_completed'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events,
                      color: AppColors.primaryGreen, size: 40),
                ),
                const SizedBox(height: 12),
                Text(rank,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen)),
                const Text('Your FoodLink Hero Rank 🌟',
                    style: TextStyle(color: AppColors.bodyText, fontSize: 13)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _ImpactMetric(
                        value: '$meals',
                        label: 'Meals Saved',
                        icon: Icons.fastfood,
                        color: AppColors.primaryGreen),
                    _ImpactMetric(
                        value: '$co2 kg',
                        label: 'CO2 Saved',
                        icon: Icons.eco,
                        color: Colors.teal),
                    _ImpactMetric(
                        value: '$deliveries',
                        label: 'Deliveries',
                        icon: Icons.local_shipping,
                        color: AppColors.accentOrange),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Push Notifications'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('App Language'),
              trailing: Text('English'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'Need help with FoodLink?\n\n'
          '📧 Email: support@foodlink.app\n'
          '📞 Phone: +91 98765 43210\n'
          '🌐 Web: www.foodlink.app',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.donor:
        return 'Donor';
      case UserRole.ngo:
        return 'NGO';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

class _ImpactMetric extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _ImpactMetric({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF6FAF6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: AppColors.bodyText)),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.bodyText, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon,
                        color: AppColors.primaryGreen, size: 18),
                  ),
                  title: Text(item.label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.bodyText, size: 20),
                  onTap: item.onTap,
                ),
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 68, endIndent: 16),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});
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
