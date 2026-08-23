import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_image_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _handleChangePhoto(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Update Profile Photo', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppTheme.primaryBlue),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.accentOrange),
                  title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
          ),
        ),
      );

      if (source == null) return;

      final pickedFile = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (pickedFile == null) return;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading profile photo...')),
        );
      }

      final success = await ref.read(authControllerProvider.notifier).uploadAvatar(pickedFile.path);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated successfully!'), backgroundColor: Color(0xFF10B981)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update photo.'), backgroundColor: Color(0xFFEF4444)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    }
  }

  void _showEditProfileModal(BuildContext context, WidgetRef ref) {
    final user = ref.read(authControllerProvider).user;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final usernameCtrl = TextEditingController(text: user?.username ?? user?.displayUsername ?? '');
    final phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Edit Profile Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('FULL NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Your display name',
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('USERNAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: usernameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. petros123',
                    prefixIcon: const Icon(Icons.alternate_email, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('PHONE NUMBER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+251 91 123 4567',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          final username = usernameCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter your full name.')),
                            );
                            return;
                          }

                          setModalState(() => isSaving = true);
                          final success = await ref.read(authControllerProvider.notifier).updateProfile(
                            name: name,
                            username: username.isNotEmpty ? username : null,
                            phoneNumber: phone,
                          );

                          if (context.mounted) {
                            Navigator.pop(ctx);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Color(0xFF10B981)),
                              );
                            } else {
                              final err = ref.read(authControllerProvider).error ?? 'Failed to update profile.';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(err), backgroundColor: const Color(0xFFEF4444)),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final curCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.password, color: AppTheme.primaryBlue),
              SizedBox(width: 8),
              Text('Change Password', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: curCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password (min 6 chars)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
              onPressed: isUpdating
                  ? null
                  : () async {
                      final cur = curCtrl.text;
                      final n = newCtrl.text;
                      final c = confirmCtrl.text;

                      if (cur.isEmpty || n.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all password fields.')),
                        );
                        return;
                      }
                      if (n.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New password must be at least 6 characters.')),
                        );
                        return;
                      }
                      if (n != c) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New passwords do not match.')),
                        );
                        return;
                      }

                      setDialogState(() => isUpdating = true);
                      final success = await ref.read(authControllerProvider.notifier).updatePassword(
                        currentPassword: cur,
                        newPassword: n,
                      );

                      if (context.mounted) {
                        Navigator.pop(ctx);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password changed successfully!'), backgroundColor: Color(0xFF10B981)),
                          );
                        } else {
                          final err = ref.read(authControllerProvider).error ?? 'Password update failed.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(err), backgroundColor: const Color(0xFFEF4444)),
                          );
                        }
                      }
                    },
              child: isUpdating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Update Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelectionDialog(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeControllerProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Appearance Mode', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 6),
              const Text(
                'Choose how Revola looks on your device.',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.wb_sunny_outlined, color: AppTheme.accentOrange),
                title: const Text('Light Mode', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: currentMode == ThemeMode.light
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
                    : null,
                onTap: () {
                  ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.light);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.nightlight_outlined, color: Color(0xFF6366F1)),
                title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: currentMode == ThemeMode.dark
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
                    : null,
                onTap: () {
                  ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.dark);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_suggest_outlined, color: AppTheme.emeraldGreen),
                title: const Text('System Default', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Matches your device theme setting', style: TextStyle(fontSize: 11)),
                trailing: currentMode == ThemeMode.system
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue)
                    : null,
                onTap: () {
                  ref.read(themeControllerProvider.notifier).setThemeMode(ThemeMode.system);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Revola • Every Good Thing Deserves a Second Life',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF166534)),
              ),
              SizedBox(height: 12),
              Text('🌿 Adama Circular Economy', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              SizedBox(height: 4),
              Text(
                'Revola is Adama City\'s dedicated marketplace for usable surplus materials, reclaimed timber, structural steel, scrap metals, plastics, and appliances.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
              SizedBox(height: 12),
              Text('🛡️ 100% Escrow Protection', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              SizedBox(height: 4),
              Text(
                'Buyer payments are held safely in escrow. Sellers receive payouts only after the buyer receives and verifies their materials.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
              SizedBox(height: 12),
              Text('🚚 Local Delivery Across Adama', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              SizedBox(height: 4),
              Text(
                'Serving all subcities in Adama with live driver tracking and prompt dispatch.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
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
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.storefront, size: 48, color: AppTheme.accentOrange),
              const SizedBox(height: 12),
              const Text('Become a Verified Seller', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
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
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
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
    final themeMode = ref.watch(themeControllerProvider);
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

    final hasAvatar = user?.avatar != null && user!.avatar!.trim().isNotEmpty;

    String themeLabel = 'System';
    IconData themeIcon = Icons.settings_suggest_outlined;
    if (themeMode == ThemeMode.light) {
      themeLabel = 'Light';
      themeIcon = Icons.wb_sunny_outlined;
    } else if (themeMode == ThemeMode.dark) {
      themeLabel = 'Dark';
      themeIcon = Icons.nightlight_outlined;
    }

    final cardColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppTheme.borderColorDark : AppTheme.borderColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(themeIcon),
            tooltip: 'Appearance Mode: $themeLabel',
            onPressed: () => _showThemeSelectionDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar & Role Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: roleColor.withOpacity(0.12),
                          border: Border.all(color: roleColor, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: hasAvatar
                            ? AppImageView(imageUrl: user.avatar!, fit: BoxFit.cover)
                            : Center(
                                child: Text(
                                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: roleColor),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _handleChangePhoto(context, ref),
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.primaryBlue,
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Revola Member',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user?.displayUsername ?? 'username'}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  if (user?.phoneNumber?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      user!.phoneNumber!,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                  const SizedBox(height: 16),

                  // Edit Profile & Change Password Quick Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          onPressed: () => _showEditProfileModal(context, ref),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlue,
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.lock_outline, size: 16),
                          label: const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          onPressed: () => _showChangePasswordDialog(context, ref),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                            side: BorderSide(color: borderCol),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Tiles
            _buildTile(
              context,
              Icons.storefront_outlined,
              isSeller ? 'Seller Portal (Active)' : 'Seller Portal (Requires Seller Account)',
              () => _handleSellerPortalTap(context, isSeller),
              subtitle: isSeller ? 'Manage materials & payouts' : 'Tap to register as seller',
              badgeColor: isSeller ? AppTheme.accentOrange : Colors.grey,
            ),
            if (isAdmin)
              _buildTile(
                context,
                Icons.admin_panel_settings_outlined,
                'Admin Management Console',
                () => context.push('/admin-dashboard'),
                subtitle: 'Platform oversight & approvals',
                badgeColor: const Color(0xFF7C3AED),
              ),
            if (isStaff)
              _buildTile(
                context,
                Icons.badge_outlined,
                'Staff Operations Hub',
                () => context.push('/staff-dashboard'),
                subtitle: 'Deliveries & verification queues',
                badgeColor: const Color(0xFF0284C7),
              ),
            _buildTile(
              context,
              Icons.receipt_long_outlined,
              'My Order History',
              () => context.push('/orders'),
              subtitle: 'Track live orders & deliveries',
            ),
            _buildTile(
              context,
              Icons.palette_outlined,
              'Appearance Mode ($themeLabel)',
              () => _showThemeSelectionDialog(context, ref),
              subtitle: 'Switch Light, Dark, or System mode',
              badgeColor: isDark ? const Color(0xFF60A5FA) : AppTheme.primaryBlue,
            ),
            _buildTile(
              context,
              Icons.notifications_outlined,
              'Notifications',
              () => context.push('/notifications'),
            ),
            _buildTile(
              context,
              Icons.info_outline,
              'About Revola',
              () => _showAboutRevolaDialog(context),
              subtitle: 'Mission, escrow protection & coverage',
            ),

            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                title: const Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w800)),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out of Revola?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  }
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
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? subtitle,
    Color? badgeColor,
  }) {
    final cardColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderCol = isDark ? AppTheme.borderColorDark : AppTheme.borderColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol),
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
