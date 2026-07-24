import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/request_model.dart';
import '../../../providers/donation_provider.dart';

class RequestStatusScreen extends ConsumerWidget {
  const RequestStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(donationProvider);
    final requests = state.myRequests;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myRequests)),
      body: requests.isEmpty
          ? const EmptyState(
              icon: Icons.assignment,
              title: 'No requests yet',
              subtitle: 'Claim available donations to see them here',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: requests.length,
              itemBuilder: (_, i) => _RequestCard(request: requests[i]),
            ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestModel request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(request.status).withOpacity(0.15),
          child: Icon(_statusIcon(request.status),
              color: _statusColor(request.status)),
        ),
        title: Text(request.donationName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(DateFormatters.display(request.createdAt)),
        trailing: Chip(
          label: Text(request.status.displayName,
              style: const TextStyle(fontSize: 11)),
          backgroundColor: _statusColor(request.status).withOpacity(0.15),
          side: BorderSide.none,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
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
        return Colors.grey;
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
