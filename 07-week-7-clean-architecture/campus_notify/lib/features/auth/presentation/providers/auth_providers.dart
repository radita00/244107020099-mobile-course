import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_saved_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

// DI: Data layer
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// DI: Domain layer (use cases)
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getSavedSessionUseCaseProvider = Provider<GetSavedSessionUseCase>((ref) {
  return GetSavedSessionUseCase(ref.watch(authRepositoryProvider));
});

// Presentation layer: State Notifier untuk Autentikasi
class AuthNotifier extends AsyncNotifier<AuthSessionEntity?> {
  @override
  Future<AuthSessionEntity?> build() async {
    final useCase = ref.watch(getSavedSessionUseCaseProvider);
    final result = await useCase();
    if (result.failure != null) {
      return null;
    }
    return result.session;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final useCase = ref.read(loginUseCaseProvider);
    final result = await useCase(email: email, password: password);

    if (result.failure != null) {
      state = AsyncValue.error(
        result.failure!.message,
        StackTrace.current,
      );
      return;
    }
    state = AsyncValue.data(result.session);
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final useCase = ref.read(logoutUseCaseProvider);
    final result = await useCase();

    if (result.failure != null) {
      state = AsyncValue.error(
        result.failure!.message,
        StackTrace.current,
      );
      return;
    }
    state = const AsyncValue.data(null);
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AuthSessionEntity?>(AuthNotifier.new);
