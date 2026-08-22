import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _imageUrlCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=600&auto=format&fit=crop&q=80');

  String? _categoryId;
  String? _materialTypeId;
  final String _condition = 'Good';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _categoryId == null || _materialTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete all required fields.')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(sellerRepositoryProvider).createProduct({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text) ?? 100.0,
        'quantity': int.tryParse(_qtyCtrl.text) ?? 1,
        'condition': _condition,
        'category': _categoryId,
        'materialType': _materialTypeId,
        'images': [_imageUrlCtrl.text.trim()],
        'location': {'subCity': 'Bole', 'city': 'Adama'},
      });

      ref.invalidate(sellerProductsProvider);
      ref.invalidate(catalogProductsProvider);

      if (mounted) {
        setState(() => _isSubmitting = false);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFEF4444)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final materialTypesAsync = ref.watch(materialTypesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Material Listing')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(label: 'Material Name', hintText: 'e.g. Pine Wood Pallets (Set of 10)', controller: _nameCtrl),
            const SizedBox(height: 14),
            CustomTextField(label: 'Price in ETB', hintText: 'e.g. 1500', controller: _priceCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 14),
            CustomTextField(label: 'Quantity Available', hintText: 'e.g. 5', controller: _qtyCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 14),
            CustomTextField(label: 'Description', hintText: 'Condition, dimensions, specs...', controller: _descCtrl, maxLines: 3),
            const SizedBox(height: 14),

            const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            categoriesAsync.when(
              data: (cats) => DropdownButtonFormField<String>(
                value: _categoryId,
                items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) => setState(() => _categoryId = val),
                decoration: const InputDecoration(hintText: 'Select Category'),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 14),

            const Text('Material Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            materialTypesAsync.when(
              data: (mats) => DropdownButtonFormField<String>(
                value: _materialTypeId,
                items: mats.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                onChanged: (val) => setState(() => _materialTypeId = val),
                decoration: const InputDecoration(hintText: 'Select Material Type'),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            CustomButton(text: 'Publish Material Listing', isLoading: _isSubmitting, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
