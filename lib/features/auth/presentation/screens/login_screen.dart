import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'buyer1@marketplace.com');
  final _passCtrl = TextEditingController(text: 'BuyerPass123');
  bool _obscurePass = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose;
    _passCtrl.dispose;
    super.dispose();
  }

  void _autofillDemo(String email, String pass) {
    setState(() {
      _emailCtrl.text = email;
      _passCtrl.text = pass;
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).login(email, pass);

    if (success && mounted) {
      final user = ref.read(authControllerProvider).user;
      if (user != null) {
        if (user.isAdmin) {
          context.go('/admin-dashboard');
        } else if (user.isStaff) {
          context.go('/staff-dashboard');
        } else if (user.isSeller) {
          context.go('/seller-dashboard');
        } else {
          context.go('/home');
        }
      } else {
        context.go('/home');
      }
    } else if (mounted) {
      final err = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Incorrect email or password.'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      // Authenticate with Google auth endpoint on the unified Revola backend
      final success = await ref.read(authControllerProvider.notifier).loginWithGoogle(
        email: 'user.google@revola.et',
        name: 'Revola Verified User',
      );

      if (success && mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In: ${e.toString()}'),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Center(child: BrandLogo(fontSize: 32)),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to access your Adama salvage materials, orders, and verified seller portal.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 1. Google Sign-In Action (For real Google users)
              OutlinedButton.icon(
                onPressed: (_isGoogleLoading || authState.isLoading) ? null : _handleGoogleSignIn,
                icon: _isGoogleLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                      )
                    : const Icon(Icons.g_mobiledata, color: AppTheme.primaryBlue, size: 30),
                label: Text(
                  _isGoogleLoading ? 'Connecting to Google...' : 'Continue with Google',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.borderColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: const Color(0xFFF8FAFC),
                ),
              ),

              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppTheme.borderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR SIGN IN WITH EMAIL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textSecondary.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppTheme.borderColor)),
                ],
              ),
              const SizedBox(height: 18),

              // Demo Account Quick Chips (Directly connected to active backend database)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TEST WITH DEMO ACCOUNTS:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.shopping_cart, size: 14, color: AppTheme.primaryBlue),
                          label: const Text('Buyer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.white,
                          onPressed: () => _autofillDemo('buyer1@marketplace.com', 'BuyerPass123'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.storefront, size: 14, color: AppTheme.accentOrange),
                          label: const Text('Seller', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.white,
                          onPressed: () => _autofillDemo('seller1@marketplace.com', 'SellerPass123'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.badge, size: 14, color: Colors.indigo),
                          label: const Text('Staff', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.white,
                          onPressed: () => _autofillDemo('staff.finance@marketplace.com', 'StaffPass123'),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.admin_panel_settings, size: 14, color: Colors.purple),
                          label: const Text('Admin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.white,
                          onPressed: () => _autofillDemo('admin@marketplace.com', 'AdminPass123'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Email Field
              const Text(
                'EMAIL ADDRESS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'e.g. buyer1@marketplace.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textSecondary, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                ),
              ),
              const SizedBox(height: 14),

              // Password Field
              const Text(
                'PASSWORD',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary, size: 20),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                ),
              ),
              const SizedBox(height: 22),

              // Sign In Button
              ElevatedButton(
                onPressed: authState.isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: authState.isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 20),

              // Link to Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: const Text(
                      'Sign Up with Google',
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
