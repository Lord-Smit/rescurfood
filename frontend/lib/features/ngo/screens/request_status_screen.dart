import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/request_model.dart';
import '../../../providers/donation_provider.dart';
import '../widgets/request_detail_modal.dart';

class RequestStatusScreen extends ConsumerStatefulWidget {
  const RequestStatusScreen({super.key});

  @override
  ConsumerState<RequestStatusScreen> createState() =>
      _RequestStatusScreenState();
}

class _RequestStatusScreenState extends ConsumerState<RequestStatusScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(donationProvider.notifier).loadMyRequests();
    });
  }

  Future<void> _refresh() async {
    await ref.read(donationProvider.notifier).loadMyRequests();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(donationProvider);
    final requests = state.myRequests;

    final pending =
        requests.where((r) => r.status == RequestStatus.pending).toList();
    final inProgress = requests
        .where((r) =>
            r.status == RequestStatus.accepted ||
            r.status == RequestStatus.pickedUp)
        .toList();
    final completed =
        requests.where((r) => r.status == RequestStatus.completed).toList();
    final cancelled =
        requests.where((r) => r.status == RequestStatus.cancelled).toList();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6FAF6),
        appBar: AppBar(
          title: const Text(AppStrings.myRequests),
          elevation: 0,
          backgroundColor: const Color(0xFF1B5E20),
          foregroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Column(
              children: [
                // Quick Summary Stats Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      _buildSummaryChip(
                        label: 'Active',
                        count: pending.length + inProgress.length,
                        color: Colors.lightGreenAccent,
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryChip(
                        label: 'Picked Up',
                        count: requests
                            .where((r) => r.status == RequestStatus.pickedUp)
                            .length,
                        color: Colors.amberAccent,
                      ),
                      const SizedBox(width: 8),
                      _buildSummaryChip(
                        label: 'Completed',
                        count: completed.length,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Filter TabBar
                TabBar(
                  isScrollable: true,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.normal),
                  tabs: [
                    Tab(text: 'All (${requests.length})'),
                    Tab(text: 'Pending (${pending.length})'),
                    Tab(text: 'In Progress (${inProgress.length})'),
                    Tab(text: 'Completed (${completed.length})'),
                    Tab(text: 'Cancelled (${cancelled.length})'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refresh,
                child: TabBarView(
                  children: [
                    _buildRequestList(requests, 'No requests found'),
                    _buildRequestList(pending, 'No pending requests'),
                    _buildRequestList(inProgress, 'No requests in progress'),
                    _buildRequestList(completed, 'No completed rescues yet'),
                    _buildRequestList(cancelled, 'No cancelled requests'),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList(List<RequestModel> list, String emptyTitle) {
    if (list.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: EmptyState(
              icon: Icons.assignment_outlined,
              title: emptyTitle,
              subtitle: 'Claim donations or refresh to see request updates',
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: list.length,
      itemBuilder: (_, i) => _EnhancedRequestCard(request: list[i]),
    );
  }
}

class _EnhancedRequestCard extends ConsumerStatefulWidget {
  final RequestModel request;
  const _EnhancedRequestCard({required this.request});

  @override
  ConsumerState<_EnhancedRequestCard> createState() =>
      __EnhancedRequestCardState();
}

class __EnhancedRequestCardState extends ConsumerState<_EnhancedRequestCard> {
  bool _isLoading = false;

  Future<void> _handleNextStatusAction() async {
    final nextStatus = widget.request.nextStatus;
    if (nextStatus == null) return;

    final message = widget.request.nextStatusConfirmationMessage ??
        'Are you sure you want to advance this request?';

    // Show Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(widget.request.nextStatusActionLabel ?? 'Confirm Action'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success = await ref
        .read(donationProvider.notifier)
        .updateRequestStatus(widget.request.id, nextStatus);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Status updated: ${nextStatus.replaceAll('_', ' ').toUpperCase()}'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final statusColor = _statusColor(req.status);
    final actionLabel = req.nextStatusActionLabel;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Donation name, Status Badge, Donor
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_statusIcon(req.status),
                      color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.donationName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.storefront_outlined,
                              size: 13, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              req.donorName != null && req.donorName!.isNotEmpty
                                  ? req.donorName!
                                  : 'Community Donor',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    req.status.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Horizontal Visual Stepper Widget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildHorizontalStepper(req.stepIndex),
          ),

          // Details bar: Date & Pickup info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  DateFormatters.display(req.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const Spacer(),
                if (req.quantity != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${req.quantity} ${req.unit ?? ''}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 16),

          // Action Buttons Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                // Secondary Action: View Details
                OutlinedButton.icon(
                  onPressed: () {
                    RequestDetailModal.show(
                      context,
                      request: req,
                      onStatusUpdated: () =>
                          ref.read(donationProvider.notifier).loadMyRequests(),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bodyText,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('View Details',
                      style: TextStyle(fontSize: 12)),
                ),

                const SizedBox(width: 8),

                // Secondary Action: Live Map (If Active)
                if (req.status == RequestStatus.accepted ||
                    req.status == RequestStatus.pickedUp)
                  IconButton(
                    onPressed: () => context.go('/tracking/${req.donationId}'),
                    icon: const Icon(Icons.navigation_outlined,
                        color: AppColors.primaryGreen),
                    tooltip: 'Live Map',
                  ),

                const Spacer(),

                // Primary Next Action Button
                if (actionLabel != null)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleNextStatusAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.arrow_forward, size: 16),
                    label: Text(
                      _isLoading ? 'Updating...' : actionLabel,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalStepper(int currentStep) {
    final steps = ['Requested', 'Accepted', 'Picked Up', 'Delivered'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8F0E8)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isDone = currentStep >= i;
          final isActive = currentStep == i;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isDone
                              ? AppColors.primaryGreen
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: isActive
                              ? Border.all(
                                  color: AppColors.primaryGreen, width: 2)
                              : null,
                        ),
                        child: Icon(
                          isDone ? Icons.check : Icons.circle,
                          size: isDone ? 12 : 6,
                          color: isDone ? Colors.white : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isActive || isDone
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive
                              ? AppColors.primaryGreen
                              : isDone
                                  ? Colors.black87
                                  : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Container(
                    width: 14,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 14),
                    color: currentStep > i
                        ? AppColors.primaryGreen
                        : Colors.grey.shade300,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Color _statusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return AppColors.accentOrange;
      case RequestStatus.accepted:
        return Colors.blue;
      case RequestStatus.pickedUp:
        return AppColors.primaryGreen;
      case RequestStatus.completed:
        return const Color(0xFF2E7D32);
      case RequestStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _statusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.hourglass_top;
      case RequestStatus.accepted:
        return Icons.verified;
      case RequestStatus.pickedUp:
        return Icons.local_shipping;
      case RequestStatus.completed:
        return Icons.check_circle;
      case RequestStatus.cancelled:
        return Icons.cancel;
    }
  }
}

