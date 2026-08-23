import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class SellerOnboardingScreen extends ConsumerStatefulWidget {
  const SellerOnboardingScreen({super.key});

  @override
  ConsumerState<SellerOnboardingScreen> createState() => _SellerOnboardingScreenState();
}

class _SellerOnboardingScreenState extends ConsumerState<SellerOnboardingScreen> {
  final _shopNameCtrl = TextEditingController();
  final _shopDescCtrl = TextEditingController();
  final _shopAddressCtrl = TextEditingController(text: 'Industry Zone, Kebele 02, Adama');
  final _bankNameCtrl = TextEditingController(text: 'Commercial Bank of Ethiopia');
  final _accountHolderCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _shopDescCtrl.dispose();
    _shopAddressCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountHolderCtrl.dispose();
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_shopNameCtrl.text.isEmpty || _shopAddressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete shop information.')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authRepositoryProvider).submitSellerOnboarding({
        'shopName': _shopNameCtrl.text.trim(),
        'shopDescription': _shopDescCtrl.text.trim(),
        'shopAddress': _shopAddressCtrl.text.trim(),
        'shopLocation': {
          'type': 'Point',
          'coordinates': [AppConstants.adamaCenterLng, AppConstants.adamaCenterLat],
          'address': _shopAddressCtrl.text.trim(),
        },
        'bankName': _bankNameCtrl.text.trim(),
        'accountHolder': _accountHolderCtrl.text.trim(),
        'accountNumber': _accountNumberCtrl.text.trim(),
      });

      ref.read(authControllerProvider.notifier).init();

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seller application submitted for review!'), backgroundColor: AppTheme.emeraldGreen),
        );
        context.go('/home');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Onboarding')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shop & Depot Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            CustomTextField(label: 'Shop / Depot Name', hintText: 'e.g. Adama Reclaimed Timber & Metal Works', controller: _shopNameCtrl),
            const SizedBox(height: 12),
            CustomTextField(label: 'Shop Address in Adama', hintText: 'e.g. Bole Subcity, Kebele 02', controller: _shopAddressCtrl),
            const SizedBox(height: 12),
            CustomTextField(label: 'Description of Materials Sold', hintText: 'Specialized in wood pallets, rebar, steel beams...', controller: _shopDescCtrl, maxLines: 2),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Payout Banking Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            CustomTextField(label: 'Bank Name', hintText: 'CBE / Awash / Dashen', controller: _bankNameCtrl),
            const SizedBox(height: 12),
            CustomTextField(label: 'Account Holder Name', hintText: 'Full name on bank account', controller: _accountHolderCtrl),
            const SizedBox(height: 12),
            CustomTextField(label: 'Account Number', hintText: '1000...', controller: _accountNumberCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            CustomButton(text: 'Submit Seller Application', isLoading: _isSubmitting, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
