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
  final _identifierCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierCtrl.text.trim();
    final pass = _passCtrl.text;

    if (identifier.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your username/email and password.')),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).login(identifier, pass);

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
          content: Text(err ?? 'Incorrect username/email or password.'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final resetCtrl = TextEditingController(text: _identifierCtrl.text.trim());
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.lock_reset, color: AppTheme.primaryBlue),
              SizedBox(width: 8),
              Text('Reset Password', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your registered email address or username and we will send you account recovery instructions.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetCtrl,
                decoration: InputDecoration(
                  labelText: 'Email or Username',
                  hintText: 'e.g. petros@example.com',
                  prefixIcon: const Icon(Icons.alternate_email, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final input = resetCtrl.text.trim();
                      if (input.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter your email or username.')),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);
                      final msg = await ref.read(authControllerProvider.notifier).forgotPassword(input);
                      if (mounted) {
                        Navigator.pop(ctx);
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Check Your Inbox', style: TextStyle(fontWeight: FontWeight.w900)),
                            content: Text(msg, style: const TextStyle(fontSize: 14)),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                                onPressed: () => Navigator.pop(c),
                                child: const Text('OK', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send Recovery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final success = await ref.read(authControllerProvider.notifier).loginWithGoogle();
      if (success && mounted) {
        final user = ref.read(authControllerProvider).user;
        final needsRole = ref.read(authControllerProvider).needsRoleSelection;
        if (needsRole) {
          context.go('/role-selection');
        } else if (user?.isAdmin == true) {
          context.go('/admin-dashboard');
        } else if (user?.isStaff == true) {
          context.go('/staff-dashboard');
        } else if (user?.isSeller == true) {
          context.go('/seller-dashboard');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: ${e.toString()}'),
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: BrandLogo(fontSize: 34)),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to the Revola Adama Materials Marketplace.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Google Sign-In
              OutlinedButton.icon(
                onPressed: (authState.isLoading || _isGoogleLoading) ? null : _handleGoogleSignIn,
                icon: _isGoogleLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue))
                    : const Icon(Icons.g_mobiledata, color: AppTheme.primaryBlue, size: 32),
                label: Text(
                  _isGoogleLoading ? 'Connecting to Google...' : 'Continue with Google',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: const BorderSide(color: AppTheme.borderColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppTheme.borderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR SIGN IN WITH USERNAME / EMAIL',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textSecondary.withValues(alpha: 0.8), letterSpacing: 0.5),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppTheme.borderColor)),
                ],
              ),
              const SizedBox(height: 20),

              // Username / Email Field
              const Text('USERNAME OR EMAIL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _identifierCtrl,
                decoration: InputDecoration(
                  hintText: 'Enter your username or email',
                  prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                ),
              ),
              const SizedBox(height: 14),

              // Password Field
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PASSWORD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                  GestureDetector(
                    onTap: _showForgotPasswordDialog,
                    child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
                  ),
                ],
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
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                ),
              ),
              const SizedBox(height: 24),

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
              const SizedBox(height: 24),

              // Sign Up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: const Text('Create Account', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 13)),
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
