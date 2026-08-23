import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  String _selectedRole = 'BUYER';
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match. Please re-enter.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).register(
      username: username,
      email: email,
      password: pass,
      role: _selectedRole,
    );

    if (success && mounted) {
      final user = ref.read(authControllerProvider).user;
      if (_selectedRole == 'SELLER' || user?.isSeller == true) {
        context.go('/seller-dashboard');
      } else {
        context.go('/home');
      }
    } else if (mounted) {
      final err = ref.read(authControllerProvider).error ?? 'Registration failed.';
      final isExisting = err.toLowerCase().contains('already exists') || err.toLowerCase().contains('in use');

      if (isExisting) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text('Account Exists', style: TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
            content: Text(
              err.contains('email')
                  ? 'An account already exists with this email address. Please sign in instead.'
                  : err,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Edit Details'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/login');
                },
                child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);
    try {
      final success = await ref.read(authControllerProvider.notifier).loginWithGoogle(role: _selectedRole);

      if (success && mounted) {
        final user = ref.read(authControllerProvider).user;
        final needsRole = ref.read(authControllerProvider).needsRoleSelection;

        if (_selectedRole == 'SELLER' || user?.isSeller == true) {
          if (needsRole) {
            context.go('/role-selection');
          } else {
            context.go('/seller-dashboard');
          }
        } else {
          if (needsRole) {
            context.go('/role-selection');
          } else {
            context.go('/home');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-Up: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isBusy = _isGoogleLoading || authState.isLoading;
    final isSeller = _selectedRole == 'SELLER';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: BrandLogo(fontSize: 32)),
                const SizedBox(height: 12),
                const Text(
                  'Join Revola Marketplace',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Create your account to buy or sell secondary materials in Adama.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Role Toggle Cards
                const Text(
                  'REGISTER AS:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    // Buyer Option
                    Expanded(
                      child: InkWell(
                        onTap: isBusy ? null : () => setState(() => _selectedRole = 'BUYER'),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: !isSeller ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: !isSeller ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
                              width: !isSeller ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                color: !isSeller ? AppTheme.primaryBlue : AppTheme.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Buyer / Builder',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: !isSeller ? AppTheme.primaryBlue : AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text('Order materials', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Seller Option
                    Expanded(
                      child: InkWell(
                        onTap: isBusy ? null : () => setState(() => _selectedRole = 'SELLER'),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSeller ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSeller ? AppTheme.accentOrange : const Color(0xFFE2E8F0),
                              width: isSeller ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.storefront,
                                color: isSeller ? AppTheme.accentOrange : AppTheme.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Seller / Merchant',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: isSeller ? AppTheme.accentOrange : AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text('List & sell items', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Username Field
                const Text('USERNAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. petros123',
                    prefixIcon: const Icon(Icons.alternate_email, color: AppTheme.textSecondary, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter a username';
                    if (val.trim().length < 3) return 'Username must be at least 3 characters';
                    if (val.contains(' ')) return 'Username cannot contain spaces';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Email Field
                const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textSecondary, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter your email';
                    if (!val.contains('@') || !val.contains('.')) return 'Please enter a valid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Password Field
                const Text('PASSWORD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary, size: 20),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                  ),
                  validator: (val) {
                    if (val == null || val.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Confirm Password Field
                const Text('CONFIRM PASSWORD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmPassCtrl,
                  obscureText: _obscureConfirmPass,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_clock_outlined, color: AppTheme.textSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPass ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary, size: 20),
                      onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please confirm your password';
                    if (val != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Create Account Button
                ElevatedButton(
                  onPressed: isBusy ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSeller ? AppTheme.accentOrange : AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: isBusy
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(
                          isSeller ? 'Create Seller Account' : 'Create Buyer Account',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                ),
                const SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppTheme.borderColor)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary.withValues(alpha: 0.8), letterSpacing: 0.5),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppTheme.borderColor)),
                  ],
                ),
                const SizedBox(height: 16),

                // Google Sign-Up Option
                OutlinedButton.icon(
                  onPressed: isBusy ? null : _handleGoogleSignUp,
                  icon: _isGoogleLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue))
                      : const Icon(Icons.g_mobiledata, color: AppTheme.primaryBlue, size: 30),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppTheme.borderColor, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    GestureDetector(
                      onTap: isBusy ? null : () => context.go('/login'),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
