import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../shared/models/user_model.dart';
import '../../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthRepository(client);
});

class AuthState {
  final UserModel? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final String activeRole;
  final bool needsRoleSelection;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.activeRole = 'BUYER',
    this.needsRoleSelection = false,
  });

  bool get isAuthenticated => user != null && token != null && token!.isNotEmpty;

  AuthState copyWith({
    UserModel? user,
    String? token,
    bool? isLoading,
    String? error,
    String? activeRole,
    bool? needsRoleSelection,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeRole: activeRole ?? this.activeRole,
      needsRoleSelection: needsRoleSelection ?? this.needsRoleSelection,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final StorageService _storage;

  AuthController(this._repo, this._storage) : super(AuthState()) {
    init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true);
    final token = await _storage.getToken();
    final savedRole = _storage.getActiveRole() ?? 'BUYER';

    if (token != null && token.isNotEmpty) {
      try {
        state = state.copyWith(token: token, activeRole: savedRole);
        final user = await _repo.getMe();
        state = state.copyWith(user: user, activeRole: user.role, isLoading: false);
      } catch (e) {
        await _storage.clearToken();
        state = state.copyWith(token: null, user: null, isLoading: false);
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.login(email, password);
      final token = res['extractedToken']?.toString() ?? res['token']?.toString() ?? res['accessToken']?.toString() ?? '';
      
      final rawUser = res['user'] ?? res['data']?['user'];
      final user = rawUser is Map<String, dynamic>
          ? UserModel.fromJson(rawUser)
          : UserModel(id: '1', name: 'User', email: email, role: 'BUYER');

      if (token.isNotEmpty) {
        await _storage.saveToken(token);
      }
      await _storage.saveActiveRole(user.role);

      state = state.copyWith(
        token: token,
        user: user,
        activeRole: user.role,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> loginWithGoogle({
    String? credential,
    String? accessToken,
    String? email,
    String? name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.googleAuth(
        credential: credential,
        accessToken: accessToken,
        email: email,
        name: name,
      );

      final token = res['extractedToken']?.toString() ?? res['token']?.toString() ?? res['accessToken']?.toString() ?? '';
      final isNew = res['isNewUser'] == true;
      final needsRole = res['needsRoleSelection'] == true || isNew;

      final rawUser = res['user'] ?? res['data']?['user'];
      final user = rawUser is Map<String, dynamic>
          ? UserModel.fromJson(rawUser)
          : UserModel(id: '1', name: name ?? 'Google User', email: email ?? '', role: 'BUYER');

      if (token.isNotEmpty) {
        await _storage.saveToken(token);
      }
      await _storage.saveActiveRole(user.role);

      state = state.copyWith(
        token: token,
        user: user,
        activeRole: user.role,
        needsRoleSelection: needsRole,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> completeOnboarding(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.completeOnboarding(payload);
      await _storage.saveActiveRole(user.role);
      state = state.copyWith(
        user: user,
        activeRole: user.role,
        needsRoleSelection: false,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> switchActiveRole(String role) async {
    await switchRole(role);
  }

  Future<void> switchRole(String role) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _repo.selectRole(role);
      await _storage.saveActiveRole(role);
      state = state.copyWith(user: user, activeRole: role, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.clearToken();
    state = AuthState();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthController(repo, storage);
});
