import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import 'available_donations_screen.dart';
import 'request_status_screen.dart';

class NgoHomeScreen extends ConsumerStatefulWidget {
  const NgoHomeScreen({super.key});

  @override
  ConsumerState<NgoHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends ConsumerState<NgoHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.bodyText,
          tabs: const [
            Tab(text: 'Available', icon: Icon(Icons.inventory_2_outlined)),
            Tab(text: 'My Requests', icon: Icon(Icons.assignment_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AvailableDonationsScreen(),
          RequestStatusScreen(),
        ],
      ),
    );
  }
}
