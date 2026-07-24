import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/request_model.dart';
import '../../../providers/donation_provider.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myRequests)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const EmptyState(
                  icon: Icons.assignment,
                  title: 'No requests yet',
                  subtitle: 'Claim available donations to see them here',
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: requests.length,
                    itemBuilder: (_, i) => _RequestCard(request: requests[i]),
                  ),
                ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  final RequestModel request;
  const _RequestCard({required this.request});

  Future<void> _changeStatus(
      BuildContext context, WidgetRef ref, String newStatus) async {
    final success = await ref
        .read(donationProvider.notifier)
        .updateRequestStatus(request.id, newStatus);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Request status updated to ${newStatus.replaceAll('_', ' ')}'),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColor(request.status);
    final nextStatus = _nextStatus(request.status);

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
            backgroundColor: color.withOpacity(0.15),
            child: Icon(_statusIcon(request.status), color: color, size: 20),
          ),
          title: Text(request.donationName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(DateFormatters.display(request.createdAt)),
              if (request.donorName != null && request.donorName!.isNotEmpty)
                Text('Donor: ${request.donorName}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.bodyText)),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.status.displayName,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color),
                ),
              ),
              if (nextStatus != null) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _changeStatus(context, ref, nextStatus),
                  child: Text(
                    'Mark ${_labelForStatus(nextStatus)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _nextStatus(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'accepted';
      case RequestStatus.accepted:
        return 'picked_up';
      case RequestStatus.pickedUp:
        return 'completed';
      case RequestStatus.completed:
      case RequestStatus.cancelled:
        return null;
    }
  }

  String _labelForStatus(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'picked_up':
        return 'Picked Up';
      case 'completed':
        return 'Delivered';
      default:
        return status;
    }
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
        return Colors.grey.shade700;
      case RequestStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _statusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.hourglass_empty;
      case RequestStatus.accepted:
        return Icons.check_circle_outline;
      case RequestStatus.pickedUp:
        return Icons.local_shipping;
      case RequestStatus.completed:
        return Icons.task_alt;
      case RequestStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}
