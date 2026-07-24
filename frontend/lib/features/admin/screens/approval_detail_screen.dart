import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../models/registration_request.dart';
import '../../../services/admin_service.dart';

class ApprovalDetailScreen extends StatefulWidget {
  final String requestId;

  const ApprovalDetailScreen({super.key, required this.requestId});

  @override
  State<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends State<ApprovalDetailScreen> {
  final AdminService _adminService = AdminService();
  RegistrationRequest? _request;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final request = await _adminService.getRequestById(widget.requestId);
      if (mounted) setState(() { _request = request; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Request'),
        content: const Text('This will create a user account and notify the applicant.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await _adminService.approveRequest(widget.requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration approved')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _reject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Request'),
        content: const Text('Are you sure you want to reject this registration?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      await _adminService.rejectRequest(widget.requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration rejected')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _request == null
              ? const Center(child: Text('Request not found'))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final r = _request!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Type'),
                  Row(
                    children: [
                      Icon(
                        r.type == 'DONOR' ? Icons.store : Icons.volunteer_activism,
                        size: 20,
                        color: r.type == 'DONOR' ? AppColors.accentOrange : AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(r.type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _label('Submitted'),
                  Text(DateFormatters.displayWithTime(r.createdAt)),
                  const SizedBox(height: 8),
                  _label('Status'),
                  Chip(
                    label: Text(r.status, style: const TextStyle(fontSize: 12, color: Colors.white)),
                    backgroundColor: AppColors.accentOrange,
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Applicant Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _label('Name'),
                  Text(r.name, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  _label('Email'),
                  Text(r.email, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  _label('Phone'),
                  Text(r.phone, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  _label('Address'),
                  Text(r.address, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          if (r.status == 'PENDING') ...[
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _reject,
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _approve,
                    icon: const Icon(Icons.check),
                    label: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.bodyText,
            ));
  }
}
