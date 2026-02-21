import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../domain/auth_repository.dart';
import '../domain/models.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier({
    required AuthRepository authRepository,
    required StorageService storageService,
  })  : _authRepository = authRepository,
        super(AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getCurrentUser();
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final loginRequest = LoginRequest(email: email, password: password);
      final response = await _authRepository.login(loginRequest);
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: response.user,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authRepository.logout();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('AuthRepository must be provided in main.dart');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authRepository: ref.watch(authRepositoryProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});
