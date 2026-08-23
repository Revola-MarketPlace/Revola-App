import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showAboutRevolaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFFFEDD5),
              radius: 18,
              child: Icon(Icons.recycling, color: AppTheme.accentOrange, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'About Revola',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Text(
                  'Revola • Every Good Thing Deserves a Second Life',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '🌿 Adama Circular Economy',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Revola is Adama City\'s dedicated marketplace for usable surplus materials, reclaimed timber, structural steel, scrap metals, plastics, and appliances.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              const Text(
                '🛡️ 100% Escrow Protection',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Buyer payments are held safely in escrow. Sellers receive payouts only after the buyer receives and verifies their materials.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              const Text(
                '🚚 Local Delivery Across Adama',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Serving all 9 subcities: Bole, Aba Geda, Goro, Boku, Kebele 02, Kebele 03, Kebele 04, Industry Zone, and Wonji Road with live GPS driver tracking.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSellerPortalTap(BuildContext context, bool isSeller) {
    if (isSeller) {
      context.push('/seller-dashboard');
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.storefront, size: 48, color: AppTheme.accentOrange),
              const SizedBox(height: 12),
              const Text(
                'Become a Verified Seller',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You are currently signed in as a Buyer. Upgrade your account to sell usable construction materials, timber, steel, and salvage items in Adama.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push('/role-selection');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Set Up Seller Shop Now', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final isSeller = user?.isSeller == true || user?.role == 'SELLER';
    final isAdmin = user?.isAdmin == true;
    final isStaff = user?.isStaff == true;

    String roleLabel = 'BUYER';
    Color roleColor = AppTheme.primaryBlue;
    if (isAdmin) {
      roleLabel = 'ADMIN';
      roleColor = const Color(0xFF7C3AED);
    } else if (isStaff) {
      roleLabel = 'STAFF';
      roleColor = const Color(0xFF0284C7);
    } else if (isSeller) {
      roleLabel = 'SELLER';
      roleColor = AppTheme.accentOrange;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar & Role Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: roleColor.withOpacity(0.12),
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: roleColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Guest User',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? 'Sign in to sync your data',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: roleColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      'ROLE: $roleLabel',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: roleColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Tiles
            _buildTile(
              Icons.storefront_outlined,
              isSeller ? 'Seller Portal (Active)' : 'Seller Portal (Requires Seller Account)',
              () => _handleSellerPortalTap(context, isSeller),
              subtitle: isSeller ? 'Manage materials & payouts' : 'Tap to register as seller',
              badgeColor: isSeller ? AppTheme.accentOrange : Colors.grey,
            ),
            if (isAdmin)
              _buildTile(
                Icons.admin_panel_settings_outlined,
                'Admin Management Console',
                () => context.push('/admin-dashboard'),
                subtitle: 'Platform oversight & approvals',
                badgeColor: const Color(0xFF7C3AED),
              ),
            if (isStaff)
              _buildTile(
                Icons.badge_outlined,
                'Staff Operations Hub',
                () => context.push('/staff-dashboard'),
                subtitle: 'Deliveries & verification queues',
                badgeColor: const Color(0xFF0284C7),
              ),
            _buildTile(
              Icons.receipt_long_outlined,
              'My Order History',
              () => context.push('/orders'),
              subtitle: 'Track live orders & deliveries',
            ),
            _buildTile(
              Icons.notifications_outlined,
              'Notifications',
              () => context.push('/notifications'),
            ),
            _buildTile(
              Icons.info_outline,
              'About Revola',
              () => _showAboutRevolaDialog(context),
              subtitle: 'Mission, escrow protection & coverage',
            ),

            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                title: const Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w800)),
                onTap: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? subtitle,
    Color? badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: badgeColor ?? AppTheme.primaryBlue, size: 22),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 13, color: AppTheme.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
