import '../../../../core/failures.dart';
import '../../../../data/token_store.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_session_model.dart';

/// Implementasi konkret dari [AuthRepository].
/// Bertanggung jawab atas komunikasi ke penyimpanan lokal (TokenStore) dan simulasi API backend.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    TokenStore? tokenStore,
  }) : _tokenStore = tokenStore ?? TokenStore();

  final TokenStore _tokenStore;

  @override
  Future<({AuthSessionEntity? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      // Simulasi panggilan jaringan / auth backend
      await Future.delayed(const Duration(milliseconds: 400));

      if (!email.contains('@') || password.length < 6) {
        return (
          session: null,
          failure: const ValidationFailure('Email atau password tidak valid.'),
        );
      }

      final model = AuthSessionModel(
        accessToken: 'mock-access-for-$email',
        refreshToken: 'mock-refresh-for-$email',
      );

      // Simpan ke secure storage
      await _tokenStore.save(
        access: model.accessToken,
        refresh: model.refreshToken,
      );

      return (session: model.toEntity(), failure: null);
    } catch (e) {
      return (
        session: null,
        failure: LocalFailure('Gagal menyimpan sesi login: $e'),
      );
    }
  }

  @override
  Future<({AuthSessionEntity? session, Failure? failure})> getSavedSession() async {
    try {
      final access = await _tokenStore.readAccess();
      final refresh = await _tokenStore.readRefresh();

      if (access != null && access.isNotEmpty && refresh != null && refresh.isNotEmpty) {
        final model = AuthSessionModel(accessToken: access, refreshToken: refresh);
        return (session: model.toEntity(), failure: null);
      }
      return (session: null, failure: null);
    } catch (e) {
      return (
        session: null,
        failure: LocalFailure('Gagal membaca sesi lokal: $e'),
      );
    }
  }

  @override
  Future<({String? token, Failure? failure})> refresh(String refreshToken) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      if (refreshToken.isEmpty) {
        return (
          token: null,
          failure: const AuthFailure('Refresh token tidak ditemukan atau sudah kadaluwarsa.'),
        );
      }
      final newAccess = 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
      await _tokenStore.save(access: newAccess, refresh: refreshToken);
      return (token: newAccess, failure: null);
    } catch (e) {
      return (
        token: null,
        failure: NetworkFailure('Gagal memperbarui token: $e'),
      );
    }
  }

  @override
  Future<({bool success, Failure? failure})> logout() async {
    try {
      await _tokenStore.clear();
      return (success: true, failure: null);
    } catch (e) {
      return (
        success: false,
        failure: LocalFailure('Gagal menghapus sesi: $e'),
      );
    }
  }
}
