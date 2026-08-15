import 'dart:io' as io;
import 'package:flutter/foundation.dart';
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
  final _addressCtrl = TextEditingController();

  final List<String> _availableUnits = [
    'kg',
    'g',
    'lbs',
    'l',
    'ml',
    'servings',
    'packets',
    'boxes',
    'plates',
    'items',
  ];
  String _selectedUnit = 'kg';

  final List<Map<String, String>> _foodCategories = [
    {'label': 'Cooked Meals 🍛', 'value': 'cooked'},
    {'label': 'Bakery & Bread 🥐', 'value': 'bakery'},
    {'label': 'Fresh Produce 🥦', 'value': 'produce'},
    {'label': 'Packaged Groceries 📦', 'value': 'groceries'},
    {'label': 'Raw Food 🥩', 'value': 'raw'},
    {'label': 'Beverages 🥤', 'value': 'beverages'},
    {'label': 'Other Food 🍲', 'value': 'other'},
  ];
  String _selectedCategory = 'cooked';
  String _foodType = 'veg'; // 'veg', 'non_veg'

  DateTime _expiryTime = DateTime.now().add(const Duration(days: 1));
  String? _photoPath;

  @override
  void dispose() {
    _foodNameCtrl.dispose();
    _quantityCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Upload Food Photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                    child: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                  ),
                  title: const Text('Take Photo with Camera',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Use your phone camera to capture food image'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accentOrange.withValues(alpha: 0.15),
                    child: const Icon(Icons.photo_library, color: AppColors.accentOrange),
                  ),
                  title: const Text('Choose from Gallery',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Select an existing photo from gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source != null) {
      try {
        final picker = ImagePicker();
        final file = await picker.pickImage(
          source: source,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        if (file != null) {
          setState(() => _photoPath = file.path);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to access photo source: $e')),
          );
        }
      }
    }
  }

  Future<void> _pickExpiry() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null && mounted) {
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
    String? uploadedPhotoUrl;
    if (_photoPath != null && !_photoPath!.startsWith('http')) {
      uploadedPhotoUrl = await ref
          .read(donationProvider.notifier)
          .uploadPhoto(_photoPath!);
    } else {
      uploadedPhotoUrl = _photoPath;
    }

    final data = {
      'food_name': _foodNameCtrl.text.trim(),
      'quantity': double.parse(_quantityCtrl.text.trim()),
      'unit': _selectedUnit,
      'food_type': _foodType,
      'category': _selectedCategory,
      'expiry_time': _expiryTime.toIso8601String(),
      'pickup_address': _addressCtrl.text.trim(),
      'photo_url': uploadedPhotoUrl,
    };
    final success = await ref.read(donationProvider.notifier).createDonation(data);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation uploaded successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(donationProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Food Donation'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _foodNameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Food Name', prefixIcon: Icon(Icons.restaurant)),
                validator: (v) => Validators.required(v, 'Food name'),
              ),
              const SizedBox(height: 16),

              // Category Selection (Full Width)
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Food Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _foodCategories.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['value'],
                    child: Text(cat['label']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 16),

              // Dietary Type Selection (Full Width InputDecorator)
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Dietary Type',
                  prefixIcon: Icon(Icons.eco_outlined),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        avatar: const Text('🥗'),
                        label: const Text('Vegetarian', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        selected: _foodType == 'veg',
                        selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                        onSelected: (selected) {
                          if (selected) setState(() => _foodType = 'veg');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ChoiceChip(
                        avatar: const Text('🍗'),
                        label: const Text('Non-Veg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        selected: _foodType == 'non_veg',
                        selectedColor: Colors.red.withValues(alpha: 0.2),
                        onSelected: (selected) {
                          if (selected) setState(() => _foodType = 'non_veg');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quantity & Unit Dropdown (Balanced 50/50 Row)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: _availableUnits.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedUnit = newValue);
                        }
                      },
                      validator: (v) => Validators.required(v, 'Unit'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Expiry Picker
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
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pickup Address
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                    labelText: 'Pickup Address',
                    prefixIcon: Icon(Icons.location_on_outlined)),
                maxLines: 2,
                validator: (v) => Validators.required(v, 'Address'),
              ),
              const SizedBox(height: 20),

              // Rich Photo Preview Container / Add Photo Action
              const Text(
                'Food Image',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),

              if (_photoPath != null) ...[
                // Upgraded Photo Preview Card with Crop/Retake Controls
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: (!kIsWeb && !_photoPath!.startsWith('http'))
                              ? Image.file(
                                  io.File(_photoPath!),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  _photoPath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.image, size: 48, color: Colors.grey),
                                    ),
                                  ),
                                ),
                        ),
                        // Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        // Photo label tag
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                                SizedBox(width: 4),
                                Text('Photo Ready',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                        // Retake / Change Button
                        Positioned(
                          right: 48,
                          top: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryGreen, size: 18),
                              tooltip: 'Retake Photo',
                              onPressed: _pickPhoto,
                            ),
                          ),
                        ),
                        // Remove Photo Button
                        Positioned(
                          right: 10,
                          top: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              tooltip: 'Remove Photo',
                              onPressed: () => setState(() => _photoPath = null),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                // Prominent Add Photo Upload Drop Area
                InkWell(
                  onTap: _pickPhoto,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                          child: const Icon(Icons.add_a_photo_outlined,
                              color: AppColors.primaryGreen, size: 28),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Add Photo of Surplus Food',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap to use phone camera or select from gallery',
                          style: TextStyle(color: AppColors.bodyText, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(state.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: 'Submit Food Donation',
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


