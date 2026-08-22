import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 12),
            Text(user?.name ?? 'Guest User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Text(user?.email ?? 'Sign in to sync your data', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),

            _buildTile(Icons.storefront_outlined, 'Seller Portal', () => context.push('/seller-dashboard')),
            _buildTile(Icons.receipt_long_outlined, 'My Order History', () => context.push('/orders')),
            _buildTile(Icons.notifications_outlined, 'Notifications', () => context.push('/notifications')),
            _buildTile(Icons.gavel_outlined, 'Dispute Resolution', () => context.push('/orders')),
            _buildTile(Icons.info_outline, 'About Revola', () {}),

            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
              title: const Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w800)),
              onTap: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
