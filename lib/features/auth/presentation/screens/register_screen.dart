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
  String _role = 'BUYER';
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).register(
      name: name,
      email: email,
      password: password,
      role: _role,
      phoneNumber: phone,
    );

    if (success && mounted) {
      if (_role == 'SELLER') {
        context.go('/seller-onboarding');
      } else {
        context.go('/home');
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);
    try {
      final success = await ref.read(authControllerProvider.notifier).login('buyer@marketplace.com', 'BuyerPass123');
      if (success && mounted) {
        context.go('/role-selection');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-Up: ${e.toString()}'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: BrandLogo(fontSize: 24)),
              const SizedBox(height: 16),
              const Text(
                'Join Revola Marketplace',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign up with Google for instant verification or use email',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Prominent Google Sign-Up Button
              OutlinedButton.icon(
                onPressed: _isGoogleLoading ? null : _handleGoogleSignUp,
                icon: _isGoogleLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                      )
                    : const Icon(Icons.g_mobiledata, color: AppTheme.primaryBlue, size: 28),
                label: Text(
                  _isGoogleLoading ? 'Signing Up with Google...' : 'Sign Up with Google Account',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.borderColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Expanded(child: Divider(color: AppTheme.borderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR REGISTER WITH EMAIL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppTheme.borderColor)),
                ],
              ),
              const SizedBox(height: 20),

              if (authState.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(
                    authState.error!,
                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),

              // Role selector
              const Text('I want to join as a:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Buyer / Collector')),
                      selected: _role == 'BUYER',
                      selectedColor: AppTheme.primaryBlue,
                      labelStyle: TextStyle(
                        color: _role == 'BUYER' ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      onSelected: (val) => setState(() => _role = 'BUYER'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Material Seller')),
                      selected: _role == 'SELLER',
                      selectedColor: AppTheme.accentOrange,
                      labelStyle: TextStyle(
                        color: _role == 'SELLER' ? Colors.white : AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      onSelected: (val) => setState(() => _role = 'SELLER'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Full Name',
                hintText: 'Abebe Kebede',
                controller: _nameCtrl,
                prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Email Address',
                hintText: 'name@example.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Phone Number (Adama Area)',
                hintText: '+251912345678',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 14),

              CustomTextField(
                label: 'Password',
                hintText: 'At least 8 characters',
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppTheme.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Create Account',
                isLoading: authState.isLoading,
                onPressed: _handleRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
