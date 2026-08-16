import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../models/request_model.dart';
import '../../../providers/donation_provider.dart';

class RequestDetailModal extends ConsumerStatefulWidget {
  final RequestModel request;
  final VoidCallback? onStatusUpdated;

  const RequestDetailModal({
    super.key,
    required this.request,
    this.onStatusUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required RequestModel request,
    VoidCallback? onStatusUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RequestDetailModal(
        request: request,
        onStatusUpdated: onStatusUpdated,
      ),
    );
  }

  @override
  ConsumerState<RequestDetailModal> createState() => _RequestDetailModalState();
}

class _RequestDetailModalState extends ConsumerState<RequestDetailModal> {
  bool _isSubmitting = false;

  Future<void> _handleStatusUpdate(String newStatus) async {
    setState(() => _isSubmitting = true);
    final success = await ref
        .read(donationProvider.notifier)
        .updateRequestStatus(widget.request.id, newStatus);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        widget.onStatusUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Request updated to ${newStatus.replaceAll('_', ' ').toUpperCase()}'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update request status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmCancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text(
            'Are you sure you want to cancel this food rescue request? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Active'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _handleStatusUpdate('cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final statusColor = _getStatusColor(req.status);
    final nextStatus = req.nextStatus;
    final actionLabel = req.nextStatusActionLabel;

    final steps = [
      ('Requested', Icons.assignment_outlined),
      ('Accepted', Icons.check_circle_outline),
      ('Picked Up', Icons.local_shipping_outlined),
      ('Delivered', Icons.task_alt),
    ];
    final currentStep = req.stepIndex;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.donationName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Request ID: #${req.id.substring(0, req.id.length > 8 ? 8 : req.id.length)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(req.status),
                            size: 14, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          req.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content Scroll
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline Tracker Header
                    const Text(
                      'Request Lifecycle & Tracking',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Visual Progress Tracker
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2EFE2)),
                      ),
                      child: Row(
                        children: List.generate(steps.length, (i) {
                          final isDone = currentStep >= i;
                          final isActive = currentStep == i;
                          return Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    if (i > 0)
                                      Expanded(
                                        child: Container(
                                          height: 3,
                                          color: currentStep >= i
                                              ? AppColors.primaryGreen
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? AppColors.primaryGreen
                                            : Colors.grey.shade200,
                                        shape: BoxShape.circle,
                                        border: isActive
                                            ? Border.all(
                                                color: AppColors.primaryGreen,
                                                width: 3)
                                            : null,
                                      ),
                                      child: Icon(
                                        steps[i].$2,
                                        size: 16,
                                        color: isDone
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    if (i < steps.length - 1)
                                      Expanded(
                                        child: Container(
                                          height: 3,
                                          color: currentStep > i
                                              ? AppColors.primaryGreen
                                              : Colors.grey.shade300,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  steps[i].$1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
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
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Information Cards
                    _buildInfoTile(
                      icon: Icons.fastfood_outlined,
                      title: 'Donation Info',
                      subtitle: req.quantity != null
                          ? '${req.quantity} ${req.unit ?? ''}'
                          : 'Food Rescue Item',
                      detail:
                          'Requested on ${DateFormatters.display(req.createdAt)}',
                    ),

                    const SizedBox(height: 12),

                    _buildInfoTile(
                      icon: Icons.storefront_outlined,
                      title: 'Donor Information',
                      subtitle: req.donorName ?? 'Community Donor',
                      detail: 'Contact details provided upon pickup confirmation.',
                      trailingWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone_outlined,
                                color: AppColors.primaryGreen),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Calling donor: ${req.donorName ?? 'Donor'}...'),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline,
                                color: AppColors.primaryGreen),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Opening chat with ${req.donorName ?? 'Donor'}...'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildInfoTile(
                      icon: Icons.location_on_outlined,
                      title: 'Pickup Address',
                      subtitle: req.pickupAddress ?? 'Central Distribution Hub',
                      detail: 'Map directions available during pickup stage.',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (nextStatus != null && actionLabel != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _handleStatusUpdate(nextStatus),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Icon(_getActionIcon(nextStatus)),
                        label: Text(
                          _isSubmitting ? 'Updating...' : actionLabel,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      if (req.status == RequestStatus.accepted ||
                          req.status == RequestStatus.pickedUp)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              context.go('/tracking/${req.donationId}');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              side: const BorderSide(
                                  color: AppColors.primaryGreen),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.navigation_outlined,
                                size: 18),
                            label: const Text('Live Map'),
                          ),
                        ),
                      if (req.status == RequestStatus.accepted ||
                          req.status == RequestStatus.pickedUp)
                        const SizedBox(width: 8),
                      if (req.status == RequestStatus.pending ||
                          req.status == RequestStatus.accepted)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting ? null : _confirmCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text('Cancel Request'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String detail,
    Widget? trailingWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (trailingWidget != null) trailingWidget,
        ],
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
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

  IconData _getStatusIcon(RequestStatus status) {
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

  IconData _getActionIcon(String statusKey) {
    switch (statusKey) {
      case 'accepted':
        return Icons.check;
      case 'picked_up':
        return Icons.local_shipping;
      case 'completed':
        return Icons.task_alt;
      default:
        return Icons.arrow_forward;
    }
  }
}
