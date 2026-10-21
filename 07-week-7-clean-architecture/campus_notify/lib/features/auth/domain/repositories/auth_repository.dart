import '../../../../core/failures.dart';
import '../entities/auth_session_entity.dart';

/// Kontrak (interface) repository auth murni di Domain Layer.
/// Menggunakan Dart records `(result, failure)` agar hasil operasi eksplisit.
abstract interface class AuthRepository {
  /// Melakukan login dengan email dan password.
  Future<({AuthSessionEntity? session, Failure? failure})> login({
    required String email,
    required String password,
  });

  /// Mengambil sesi yang tersimpan di penyimpanan lokal.
  Future<({AuthSessionEntity? session, Failure? failure})> getSavedSession();

  /// Memperbarui token akses menggunakan refresh token.
  Future<({String? token, Failure? failure})> refresh(String refreshToken);

  /// Menghapus sesi / logout pengguna.
  Future<({bool success, Failure? failure})> logout();
}
