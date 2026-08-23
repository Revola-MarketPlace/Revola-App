import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../controllers/auth_controller.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String _selectedRole = 'BUYER';
  final _phoneCtrl = TextEditingController(text: '+251911223344');

  // Buyer fields
  final _streetCtrl = TextEditingController(text: 'Kebele 04, Near Stadium');
  String _subCity = 'Bole';

  // Seller fields
  final _shopNameCtrl = TextEditingController(text: 'Adama Reclaimed Steel Depot');
  final _shopAddressCtrl = TextEditingController(text: 'Bole Subcity, Industry Zone, Adama');
  final _shopDescCtrl = TextEditingController(text: 'Specialized in reclaimed steel beams, structural timber, and scrap metals.');
  String _bankName = 'Commercial Bank of Ethiopia (CBE)';
  final _accountHolderCtrl = TextEditingController(text: 'Abebe Kebede');
  final _accountNumberCtrl = TextEditingController(text: '1000123456789');
  final List<String> _selectedCategories = ['Structural Metal', 'Timber & Wood', 'Scrap & Recycling'];

  bool _isSubmitting = false;

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

  final List<String> _bankNames = [
    'Commercial Bank of Ethiopia (CBE)',
    'Awash Bank',
    'Bank of Abyssinia',
    'Dashen Bank',
    'Cooperative Bank of Oromia',
    'Nib International Bank',
    'Zemen Bank',
    'Telebirr Merchant',
  ];

  final List<String> _availableCategories = [
    'Structural Metal',
    'Timber & Wood',
    'Electronics & Scrap',
    'Bricks & Blocks',
    'Scrap & Recycling',
    'Furniture & Fixtures',
    'Plumbing & Pipes',
    'Roofing Sheets',
  ];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _shopNameCtrl.dispose();
    _shopAddressCtrl.dispose();
    _shopDescCtrl.dispose();
    _accountHolderCtrl.dispose();
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  void _toggleCategory(String cat) {
    setState(() {
      if (_selectedCategories.contains(cat)) {
        _selectedCategories.remove(cat);
      } else {
        _selectedCategories.add(cat);
      }
    });
  }

  Future<void> _handleSubmit() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your mobile phone number.')),
      );
      return;
    }

    if (_selectedRole == 'SELLER') {
      if (_shopNameCtrl.text.trim().isEmpty || _shopAddressCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your shop name and address.')),
        );
        return;
      }
      if (_accountNumberCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your bank account number for payouts.')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final payload = <String, dynamic>{
        'role': _selectedRole,
        'phoneNumber': phone,
      };

      if (_selectedRole == 'SELLER') {
        payload['shopName'] = _shopNameCtrl.text.trim();
        payload['shopDescription'] = _shopDescCtrl.text.trim();
        payload['shopAddress'] = _shopAddressCtrl.text.trim();
        payload['categoriesSold'] = _selectedCategories;
        payload['bankName'] = _bankName;
        payload['bankAccountHolder'] = _accountHolderCtrl.text.trim();
        payload['bankAccountNumber'] = _accountNumberCtrl.text.trim();
        payload['latitude'] = 8.5420;
        payload['longitude'] = 39.2780;
      } else {
        payload['streetAddress'] = _streetCtrl.text.trim();
        payload['subCity'] = _subCity;
        payload['city'] = 'Adama';
        payload['latitude'] = 8.5400;
        payload['longitude'] = 39.2700;
      }

      final success = await ref.read(authControllerProvider.notifier).completeOnboarding(payload);

      if (success && mounted) {
        if (_selectedRole == 'SELLER') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Seller profile submitted! Welcome to AdaMaterials.'),
              backgroundColor: AppTheme.accentOrange,
            ),
          );
          context.go('/seller-dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome to AdaMaterials Marketplace!'),
              backgroundColor: AppTheme.primaryBlue,
            ),
          );
          context.go('/home');
        }
      } else if (mounted) {
        final err = ref.read(authControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err ?? 'Failed to complete profile onboarding.'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const BrandLogo(fontSize: 20),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ' + (user?.name ?? 'Friend') + '!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'How would you like to participate in AdaMaterials E-Commerce?',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Role Choice Cards
              const Text(
                'SELECT YOUR PRIMARY ROLE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Buyer Card
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedRole = 'BUYER'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'BUYER' ? const Color(0xFFEFF6FF) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedRole == 'BUYER' ? AppTheme.primaryBlue : AppTheme.borderColor,
                            width: _selectedRole == 'BUYER' ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryBlue, size: 24),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'I want to Buy',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Browse salvage materials & order delivery in Adama.',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Seller Card
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedRole = 'SELLER'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedRole == 'SELLER' ? const Color(0xFFFFF7ED) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedRole == 'SELLER' ? AppTheme.accentOrange : AppTheme.borderColor,
                            width: _selectedRole == 'SELLER' ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.accentOrange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.storefront_outlined, color: AppTheme.accentOrange, size: 24),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'I want to Sell',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Register depot & receive verified bank payouts.',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contact Phone Number
              const Text(
                'MOBILE PHONE NUMBER *',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+251 9XX XXX XXX',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                ),
              ),
              const SizedBox(height: 20),

              // BUYER SPECIFIC FIELDS
              if (_selectedRole == 'BUYER') ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: AppTheme.primaryBlue, size: 20),
                          SizedBox(width: 8),
                          Text('Primary Delivery Address (Adama City)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text('STREET / NEIGHBORHOOD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _streetCtrl,
                        decoration: InputDecoration(
                          hintText: 'e.g. Kebele 02, Near Post Office',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text('SUBCITY / ZONE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _subCity,
                        items: _subCities.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (v) => setState(() => _subCity = v ?? 'Bole'),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // SELLER SPECIFIC FIELDS
              if (_selectedRole == 'SELLER') ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.store_mall_directory_outlined, color: AppTheme.accentOrange, size: 20),
                          SizedBox(width: 8),
                          Text('Business & Depot Information', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text('SHOP / BUSINESS NAME *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _shopNameCtrl,
                        decoration: InputDecoration(
                          hintText: 'e.g. Adama Reclaimed Steel Depot',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text('PHYSICAL SHOP ADDRESS *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _shopAddressCtrl,
                        decoration: InputDecoration(
                          hintText: 'e.g. Bole Subcity, Industry Zone, Adama',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text('BUSINESS DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _shopDescCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Describe materials your shop specializes in...',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('MATERIAL CATEGORIES SOLD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _availableCategories.map((cat) {
                          final isSel = _selectedCategories.contains(cat);
                          return FilterChip(
                            label: Text(cat, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppTheme.textPrimary)),
                            selected: isSel,
                            selectedColor: AppTheme.accentOrange,
                            backgroundColor: const Color(0xFFF1F5F9),
                            onSelected: (_) => _toggleCategory(cat),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Banking Details for Seller
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: Color(0xFFFBBF24), size: 20),
                          SizedBox(width: 8),
                          Text('Private Bank Details for Payouts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Private & Secure. Used exclusively by platform finance for verified escrow payouts.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 14),

                      const Text('BANK NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _bankName,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        items: _bankNames.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (v) => setState(() => _bankName = v ?? _bankNames[0]),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text('ACCOUNT HOLDER NAME *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _accountHolderCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Account holder full name',
                          hintStyle: const TextStyle(color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text('ACCOUNT NUMBER *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFCBD5E1))),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _accountNumberCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: '1000XXXXXXXXX',
                          hintStyle: const TextStyle(color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFF1E293B),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedRole == 'SELLER' ? AppTheme.accentOrange : AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Complete Profile & Get Started', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
