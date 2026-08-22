import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedRole = 'BUYER';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: _selectedRole,
      phoneNumber: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandLogo(fontSize: 26),
                const SizedBox(height: 24),
                const Text(
                  'Join Revola Marketplace',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create an account to start buying and selling materials.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 24),

                if (authState.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF991B1B)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Role Selector Radio Pills
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'BUYER'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'BUYER' ? AppTheme.primaryBlue.withOpacity(0.1) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedRole == 'BUYER' ? AppTheme.primaryBlue : AppTheme.borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.shopping_bag_outlined, color: _selectedRole == 'BUYER' ? AppTheme.primaryBlue : AppTheme.textSecondary, size: 20),
                              const SizedBox(height: 4),
                              Text('I am a Buyer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: _selectedRole == 'BUYER' ? AppTheme.primaryBlue : AppTheme.textPrimary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedRole = 'SELLER'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedRole == 'SELLER' ? AppTheme.accentOrange.withOpacity(0.1) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedRole == 'SELLER' ? AppTheme.accentOrange : AppTheme.borderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.storefront_outlined, color: _selectedRole == 'SELLER' ? AppTheme.accentOrange : AppTheme.textSecondary, size: 20),
                              const SizedBox(height: 4),
                              Text('I am a Seller', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: _selectedRole == 'SELLER' ? AppTheme.accentOrange : AppTheme.textPrimary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: 'Full Name',
                  hintText: 'e.g. Abebe Kebede',
                  controller: _nameCtrl,
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Email Address',
                  hintText: 'e.g. abebe@example.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => (val == null || !val.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Phone Number (Optional)',
                  hintText: 'e.g. +251911223344',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Password',
                  hintText: 'Min 6 characters',
                  controller: _passwordCtrl,
                  obscureText: true,
                  validator: (val) => (val == null || val.length < 6) ? 'Password must be at least 6 chars' : null,
                ),
                const SizedBox(height: 26),

                CustomButton(
                  text: 'Create Account',
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? ', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
