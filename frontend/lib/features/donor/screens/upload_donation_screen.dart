import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/donation_provider.dart';

class UploadDonationScreen extends ConsumerStatefulWidget {
  const UploadDonationScreen({super.key});

  @override
  ConsumerState<UploadDonationScreen> createState() => _UploadDonationScreenState();
}

class _UploadDonationScreenState extends ConsumerState<UploadDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'kg');
  final _addressCtrl = TextEditingController();
  DateTime _expiryTime = DateTime.now().add(const Duration(days: 1));
  String? _photoPath;

  @override
  void dispose() {
    _foodNameCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _photoPath = file.path);
  }

  Future<void> _pickExpiry() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_expiryTime),
      );
      if (time != null) {
        setState(() => _expiryTime =
            DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'food_name': _foodNameCtrl.text.trim(),
      'quantity': double.parse(_quantityCtrl.text.trim()),
      'unit': _unitCtrl.text.trim(),
      'expiry_time': _expiryTime.toIso8601String(),
      'pickup_address': _addressCtrl.text.trim(),
      'photo_url': _photoPath,
    };
    final success = await ref.read(donationProvider.notifier).createDonation(data);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation uploaded!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(donationProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Donation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _foodNameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Food Name', prefixIcon: Icon(Icons.fastfood)),
                validator: (v) => Validators.required(v, 'Food name'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Quantity', prefixIcon: Icon(Icons.scale)),
                      keyboardType: TextInputType.number,
                      validator: (v) => Validators.required(v, 'Quantity'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unitCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Unit', prefixIcon: Icon(Icons.square_foot)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickExpiry,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Best Before / Expiry',
                    prefixIcon: Icon(Icons.schedule),
                  ),
                  child: Text(
                    '${_expiryTime.day}/${_expiryTime.month}/${_expiryTime.year} '
                    '${_expiryTime.hour}:${_expiryTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                    labelText: 'Pickup Address',
                    prefixIcon: Icon(Icons.location_on_outlined)),
                maxLines: 2,
                validator: (v) => Validators.required(v, 'Address'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: Icon(_photoPath != null
                      ? Icons.check_circle
                      : Icons.camera_alt_outlined,
                      color: _photoPath != null
                          ? AppColors.primaryGreen
                          : null),
                  label: Text(_photoPath != null ? 'Photo Added' : 'Add Photo'),
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(state.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: 'Submit Donation',
                isLoading: state.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
