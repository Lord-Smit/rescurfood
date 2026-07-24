import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/registration_request.dart';
import '../../../services/admin_service.dart';

class PendingApprovalsScreen extends ConsumerStatefulWidget {
  const PendingApprovalsScreen({super.key});

  @override
  ConsumerState<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends ConsumerState<PendingApprovalsScreen> {
  final AdminService _adminService = AdminService();
  List<RegistrationRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _adminService.getRequests(status: 'PENDING');
      if (mounted) setState(() => _requests = requests);
    } catch (e) {
      if (mounted) setState(() => _requests = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const AppLoader(message: 'Loading requests...');

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Approvals')),
      body: _requests.isEmpty
          ? const EmptyState(
              icon: Icons.checklist,
              title: 'No pending requests',
              subtitle: 'All registration requests have been reviewed',
            )
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: _requests.length,
                itemBuilder: (_, i) => _RequestCard(
                  request: _requests[i],
                  onTap: () async {
                    await context.push('/admin/approvals/${_requests[i].id}');
                    _loadRequests();
                  },
                ),
              ),
            ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RegistrationRequest request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: request.type == 'DONOR'
              ? AppColors.accentOrange.withOpacity(0.2)
              : AppColors.primaryGreen.withOpacity(0.2),
          child: Icon(
            request.type == 'DONOR' ? Icons.store : Icons.volunteer_activism,
            color: request.type == 'DONOR'
                ? AppColors.accentOrange
                : AppColors.primaryGreen,
          ),
        ),
        title: Text(request.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.email),
            Text('${request.type}  •  ${DateFormatters.relative(request.createdAt)}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
