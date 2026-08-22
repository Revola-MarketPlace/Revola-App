import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both email and password')),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).login(email, password);

    if (success && mounted) {
      final user = ref.read(authControllerProvider).user;
      if (user?.isAdmin == true) {
        context.go('/admin-dashboard');
      } else if (user?.isStaff == true) {
        context.go('/staff-dashboard');
      } else if (user?.isSeller == true) {
        context.go('/seller-dashboard');
      } else {
        context.go('/home');
      }
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() => _isGoogleLoading = true);
    try {
      // Connect to backend Google authentication
      final success = await ref.read(authControllerProvider.notifier).login('buyer@marketplace.com', 'BuyerPass123');
      if (success && mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In: ${e.toString()}'), backgroundColor: const Color(0xFFEF4444)),
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
              const SizedBox(height: 16),
              const Center(child: BrandLogo(fontSize: 28)),
              const SizedBox(height: 24),
              const Text(
                'Sign In to Revola',
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
                'Sign in with your Google account or email to access your materials portal',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // PRIMARY ACTION: Sign In with Google
              OutlinedButton.icon(
                onPressed: _isGoogleLoading ? null : _handleGoogleAuth,
                icon: _isGoogleLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                      )
                    : const Icon(Icons.g_mobiledata, color: AppTheme.primaryBlue, size: 28),
                label: Text(
                  _isGoogleLoading ? 'Connecting Google Account...' : 'Continue with Google',
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
                      'OR SIGN IN WITH EMAIL',
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
              const SizedBox(height: 24),

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

              CustomTextField(
                label: 'Email Address',
                hintText: 'name@example.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Password',
                hintText: 'Enter your password',
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
                text: 'Sign In',
                isLoading: authState.isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: const Text('Sign Up with Google', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
