import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/catalog/presentation/screens/catalog_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/checkout/presentation/screens/order_success_screen.dart';
import '../../features/checkout/presentation/screens/payment_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/map/presentation/screens/marketplace_map_screen.dart';
import '../../features/material_details/presentation/screens/material_details_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/orders/presentation/screens/buyer_orders_screen.dart';
import '../../features/orders/presentation/screens/dispute_form_screen.dart';
import '../../features/orders/presentation/screens/live_tracking_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/seller/presentation/screens/add_edit_material_screen.dart';
import '../../features/seller/presentation/screens/seller_dashboard_screen.dart';
import '../../features/seller/presentation/screens/seller_materials_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Stateful Shell with 5 bottom navigation tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Materials Catalog
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/catalog',
                builder: (context, state) => const CatalogScreen(),
              ),
            ],
          ),
          // Branch 2: Marketplace Map
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MarketplaceMapScreen(),
              ),
            ],
          ),
          // Branch 3: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Sub-screens & Detail screens
      GoRoute(
        path: '/material/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MaterialDetailsScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/payment/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          final method = state.uri.queryParameters['method'] ?? 'CHAPA';
          return PaymentScreen(orderId: orderId, method: method);
        },
      ),
      GoRoute(
        path: '/order-success/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderSuccessScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const BuyerOrdersScreen(),
      ),
      GoRoute(
        path: '/order-details/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/tracking/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return LiveTrackingScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/dispute-form/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return DisputeFormScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/seller-dashboard',
        builder: (context, state) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: '/seller-materials',
        builder: (context, state) => const SellerMaterialsScreen(),
      ),
      GoRoute(
        path: '/seller-add-material',
        builder: (context, state) => const AddEditMaterialScreen(),
      ),
      GoRoute(
        path: '/seller-orders',
        builder: (context, state) => const BuyerOrdersScreen(),
      ),
    ],
  );
});
