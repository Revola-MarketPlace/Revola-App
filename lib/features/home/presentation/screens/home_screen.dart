import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/material_card.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../catalog/presentation/controllers/catalog_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredAsync = ref.watch(featuredProductsProvider);
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const BrandLogo(fontSize: 22),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
            ),
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryBlue,
        onRefresh: () async {
          ref.invalidate(featuredProductsProvider);
          ref.invalidate(categoriesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HERO SEARCH BANNER
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ADAMA MARKETPLACE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Row(
                          children: const [
                            Icon(Icons.shield_rounded, color: AppTheme.emeraldGreen, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '100% Escrow Protected',
                              style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Find Reusable & Secondary Materials in Adama',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.25,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connecting builders, recyclers, and craftsmen with surplus steel, timber, plastics, and salvage goods.',
                      style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                    ),
                    const SizedBox(height: 16),

                    // Interactive Search Bar (Tapping navigates to Catalog)
                    InkWell(
                      onTap: () => context.push('/catalog'),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: AppTheme.primaryBlue, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Search steel, timber, plastic barrels, rebar...',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                              ),
                            ),
                            Icon(Icons.tune, color: AppTheme.textSecondary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. CATEGORIES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Material Categories',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                    ),
                    TextButton(
                      onPressed: () => context.push('/catalog'),
                      child: const Text('See All', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: categoriesAsync.when(
                  data: (categories) => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = categories[idx];
                      return ActionChip(
                        label: Text(cat.name),
                        avatar: const Icon(Icons.category_outlined, size: 16, color: AppTheme.primaryBlue),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.borderColor),
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                        onPressed: () {
                          ref.read(catalogFilterProvider.notifier).state =
                              ref.read(catalogFilterProvider).copyWith(selectedCategoryId: cat.id);
                          context.push('/catalog');
                        },
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: 20),

              // 3. TODAY'S PICKS / FEATURED MATERIALS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today\'s Material Picks',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                    ),
                    TextButton(
                      onPressed: () => context.push('/catalog'),
                      child: const Text('View All', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              featuredAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: EmptyStateView(
                        icon: Icons.inventory_2_outlined,
                        title: 'No Materials Found',
                        message: 'Check back soon for freshly listed secondary items.',
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: products.length > 6 ? 6 : products.length,
                    itemBuilder: (context, idx) {
                      final product = products[idx];
                      return MaterialCard(
                        product: product,
                        onTap: () => context.push('/material/${product.id}'),
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: LoadingIndicator(message: 'Loading materials...'),
                ),
                error: (err, _) => ErrorView(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(featuredProductsProvider),
                ),
              ),

              const SizedBox(height: 16),

              // 4. NEARBY MARKETPLACE / MAP PREVIEW
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.map_outlined, color: AppTheme.primaryBlue, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Adama Depots & Seller Spots',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textPrimary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '17 collection points & verified seller yards across Kebele 01-14',
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/map'),
                        icon: const Icon(Icons.explore, size: 16),
                        label: const Text('Open Interactive Map', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 5. HOW REVOLA WORKS
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How Revola Works',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'End-to-end managed marketplace for reliable local transactions',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    _buildStepRow('1', 'Find Reusable Materials', 'Browse verified surplus listings from sellers across Adama with authentic condition photos.'),
                    const SizedBox(height: 14),
                    _buildStepRow('2', 'Safe Escrow Payment', 'Pay securely with Chapa, Telebirr, or Bank Transfer. Funds are locked until delivery is verified.'),
                    const SizedBox(height: 14),
                    _buildStepRow('3', 'Doorstep Local Delivery', 'Our logistics team picks up from the seller and delivers right to your project site or address.'),
                    const SizedBox(height: 14),
                    _buildStepRow('4', 'Guaranteed Payouts', 'Sellers receive prompt automated payouts once the buyer confirms delivery.'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 6. WHY REVOLA (TRUST & GUARANTEE)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.verified_user_rounded, color: AppTheme.emeraldGreen, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'The Revola Guarantee',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF166534)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildCheckPoint('Strictly verified listings with zero deceptive food or mock imagery.'),
                    _buildCheckPoint('Escrow protection holding payments safely until receipt.'),
                    _buildCheckPoint('Promoting sustainable circular economy and zero-waste building in Adama.'),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryBlue, fontSize: 12),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(description, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: AppTheme.emeraldGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Color(0xFF15803D), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
