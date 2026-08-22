import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../controllers/catalog_controller.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late String? _categoryId;
  late String? _condition;
  late bool _inStockOnly;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(catalogFilterProvider);
    _categoryId = filter.selectedCategoryId;
    _condition = filter.selectedCondition;
    _inStockOnly = filter.inStockOnly;
    _sortBy = filter.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Materials',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _categoryId = null;
                      _condition = null;
                      _inStockOnly = false;
                      _sortBy = '-createdAt';
                    });
                  },
                  child: const Text('Reset All', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            // Category Selector
            const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (cats) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All Categories'),
                    selected: _categoryId == null,
                    onSelected: (val) => setState(() => _categoryId = null),
                  ),
                  ...cats.map((c) => ChoiceChip(
                    label: Text(c.name),
                    selected: _categoryId == c.id,
                    onSelected: (val) => setState(() => _categoryId = val ? c.id : null),
                  )),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Condition Selector
            const Text('Condition', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Like New', 'Good', 'Fair', 'Used'].map((cond) {
                return ChoiceChip(
                  label: Text(cond),
                  selected: _condition == cond,
                  onSelected: (val) => setState(() => _condition = val ? cond : null),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // In Stock Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('In Stock Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              value: _inStockOnly,
              activeColor: AppTheme.primaryBlue,
              onChanged: (val) => setState(() => _inStockOnly = val),
            ),
            const SizedBox(height: 20),

            CustomButton(
              text: 'Apply Filters',
              onPressed: () {
                ref.read(catalogFilterProvider.notifier).state = ref.read(catalogFilterProvider).copyWith(
                  selectedCategoryId: _categoryId,
                  selectedCondition: _condition,
                  inStockOnly: _inStockOnly,
                  sortBy: _sortBy,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
