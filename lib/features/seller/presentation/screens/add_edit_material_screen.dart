import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../catalog/presentation/controllers/catalog_controller.dart';
import '../controllers/seller_controller.dart';

class AddEditMaterialScreen extends ConsumerStatefulWidget {
  const AddEditMaterialScreen({super.key});

  @override
  ConsumerState<AddEditMaterialScreen> createState() => _AddEditMaterialScreenState();
}

class _AddEditMaterialScreenState extends ConsumerState<AddEditMaterialScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _imageUrlCtrl = TextEditingController();

  String? _categoryId;
  String? _materialTypeId;
  String _condition = 'Good';
  String _subCity = 'Bole';
  bool _isSubmitting = false;

  final List<String> _pickedImagePaths = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _conditions = ['Good', 'Like New', 'Fair', 'Salvaged'];
  final List<String> _subCities = [
    'Bole',
    'Aba Geda',
    'Goro',
    'Boku',
    'Kebele 02',
    'Kebele 03',
    'Kebele 04',
    'Industry Zone',
    'Wonji Road',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1024);
      if (file != null) {
        setState(() {
          _pickedImagePaths.add(file.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not pick image: $e')));
      }
    }
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim());
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;

    if (name.isEmpty || price == null || _categoryId == null || _materialTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields (Name, Price, Category, Type).')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final sellerRepo = ref.read(sellerRepositoryProvider);
      List<String> images = [];

      // 1. Try uploading local images to backend /products/upload
      if (_pickedImagePaths.isNotEmpty) {
        final uploaded = await sellerRepo.uploadImages(_pickedImagePaths);
        if (uploaded.isNotEmpty) {
          images.addAll(uploaded);
        }
      }

      if (_imageUrlCtrl.text.trim().isNotEmpty) {
        images.add(_imageUrlCtrl.text.trim());
      }

      // Default high quality material imagery based on name if no images uploaded
      if (images.isEmpty) {
        final lower = name.toLowerCase();
        if (lower.contains('wood') || lower.contains('timber') || lower.contains('pallet')) {
          images.add('https://images.unsplash.com/photo-1513694203232-719a280e022f?w=600&auto=format&fit=crop&q=80');
        } else if (lower.contains('metal') || lower.contains('steel') || lower.contains('iron') || lower.contains('pipe')) {
          images.add('https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=600&auto=format&fit=crop&q=80');
        } else if (lower.contains('electric') || lower.contains('circuit') || lower.contains('wire') || lower.contains('device')) {
          images.add('https://images.unsplash.com/photo-1518770660439-4636190af475?w=600&auto=format&fit=crop&q=80');
        } else {
          images.add('https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=600&auto=format&fit=crop&q=80');
        }
      }

      await sellerRepo.createProduct({
        'name': name,
        'description': _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : 'Quality usable material in Adama.',
        'price': price,
        'quantity': qty,
        'condition': _condition,
        'category': _categoryId,
        'materialType': _materialTypeId,
        'images': images,
        'location': {'subCity': _subCity, 'city': 'Adama'},
      });

      ref.invalidate(sellerProductsProvider);
      ref.invalidate(catalogProductsProvider);

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material listing published successfully!'), backgroundColor: AppTheme.emeraldGreen),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final materialTypesAsync = ref.watch(materialTypesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Add Material Listing'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Material Images Section
            const Text(
              'MATERIAL PHOTOS & PROOF',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_pickedImagePaths.isNotEmpty) ...[
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _pickedImagePaths.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, idx) {
                          final p = _pickedImagePaths[idx];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: kIsWeb
                                    ? Image.network(p, width: 90, height: 90, fit: BoxFit.cover)
                                    : Image.file(File(p), width: 90, height: 90, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => setState(() => _pickedImagePaths.removeAt(idx)),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined, size: 18, color: AppTheme.primaryBlue),
                          label: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.textPrimary)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppTheme.borderColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined, size: 18, color: AppTheme.accentOrange),
                          label: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.textPrimary)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppTheme.borderColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Details Fields
            CustomTextField(label: 'MATERIAL NAME', hintText: 'e.g. Salvaged H-Beams (6m Length)', controller: _nameCtrl),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: CustomTextField(label: 'PRICE (ETB)', hintText: 'e.g. 2400', controller: _priceCtrl, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(label: 'QUANTITY', hintText: 'e.g. 10', controller: _qtyCtrl, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 14),

            // Condition & Subcity
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CONDITION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _condition,
                        items: _conditions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))).toList(),
                        onChanged: (val) => setState(() => _condition = val ?? 'Good'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('DEPOT SUBCITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _subCity,
                        items: _subCities.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))).toList(),
                        onChanged: (val) => setState(() => _subCity = val ?? 'Bole'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            CustomTextField(label: 'DESCRIPTION', hintText: 'Dimensions, source, reusability details...', controller: _descCtrl, maxLines: 3),
            const SizedBox(height: 14),

            // Category Selector
            const Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            categoriesAsync.when(
              data: (cats) => DropdownButtonFormField<String>(
                initialValue: _categoryId,
                items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))).toList(),
                onChanged: (val) => setState(() => _categoryId = val),
                decoration: InputDecoration(
                  hintText: 'Select Material Category',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 14),

            // Material Type Selector
            const Text('MATERIAL TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            materialTypesAsync.when(
              data: (mats) => DropdownButtonFormField<String>(
                initialValue: _materialTypeId,
                items: mats.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))).toList(),
                onChanged: (val) => setState(() => _materialTypeId = val),
                decoration: InputDecoration(
                  hintText: 'Select Specific Type',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 28),

            CustomButton(text: 'Publish Material Listing', isLoading: _isSubmitting, onPressed: _save),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
