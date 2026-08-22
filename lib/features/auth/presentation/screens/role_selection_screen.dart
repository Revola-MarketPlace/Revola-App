import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../controllers/auth_controller.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const BrandLogo(fontSize: 20)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Your Active Portal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('Switch between discovering materials or selling inventory in Adama.', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 32),

              _buildRoleCard(
                context,
                title: 'Buyer Portal',
                desc: 'Browse timber, rebar, plastics, cart & checkout',
                icon: Icons.shopping_cart_outlined,
                color: AppTheme.primaryBlue,
                onTap: () {
                  ref.read(authControllerProvider.notifier).switchActiveRole('BUYER');
                  context.go('/home');
                },
              ),
              const SizedBox(height: 16),

              _buildRoleCard(
                context,
                title: 'Seller Portal',
                desc: 'List reusable materials, track sales & payouts',
                icon: Icons.storefront_outlined,
                color: AppTheme.accentOrange,
                onTap: () {
                  if (user?.isSellerApproved == true || user?.isSeller == true) {
                    ref.read(authControllerProvider.notifier).switchActiveRole('SELLER');
                    context.go('/seller-dashboard');
                  } else {
                    context.push('/seller-onboarding');
                  }
                },
              ),

              if (user?.isAdmin == true || user?.isStaff == true) ...[
                const SizedBox(height: 16),
                _buildRoleCard(
                  context,
                  title: user!.isAdmin ? 'Admin Console' : 'Staff Operations',
                  desc: 'Product approval, bank verification, deliveries',
                  icon: Icons.admin_panel_settings_outlined,
                  color: const Color(0xFF7C3AED),
                  onTap: () => context.push(user.isAdmin ? '/admin-dashboard' : '/staff-dashboard'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
