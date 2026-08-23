import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/models/cart_model.dart';
import '../../data/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return CartRepository(client);
});

class CartState {
  final CartModel? cart;
  final bool isLoading;
  final String? error;

  CartState({this.cart, this.isLoading = false, this.error});

  int get totalItems => cart?.totalItemsCount ?? 0;
  double get subtotal => cart?.subtotal ?? 0.0;
  List<CartItemModel> get items => cart?.items ?? [];

  CartState copyWith({CartModel? cart, bool? isLoading, String? error}) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CartController extends StateNotifier<CartState> {
  final CartRepository _repo;

  CartController(this._repo) : super(CartState()) {
    fetchCart();
  }

  Future<void> fetchCart() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cart = await _repo.getCart();
      state = state.copyWith(cart: cart, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addToCart(String productId, {int quantity = 1}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cart = await _repo.addToCart(productId, quantity);
      state = state.copyWith(cart: cart, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      final cart = await _repo.updateQuantity(itemId, quantity);
      state = state.copyWith(cart: cart);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final cart = await _repo.removeFromCart(itemId);
      state = state.copyWith(cart: cart);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearCart() async {
    try {
      await _repo.clearCart();
      state = CartState(cart: null);
    } catch (_) {
      state = CartState(cart: null);
    }
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, CartState>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return CartController(repo);
});
