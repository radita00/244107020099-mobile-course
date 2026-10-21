import '../../../../core/failures.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: Login pengguna.
/// Satu kelas = satu tanggung jawab bisnis.
class LoginUseCase {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<({AuthSessionEntity? session, Failure? failure})> call({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return (
        session: null,
        failure: const ValidationFailure('Email tidak valid.'),
      );
    }
    if (password.length < 6) {
      return (
        session: null,
        failure: const ValidationFailure('Password minimal 6 karakter.'),
      );
    }
    return _repository.login(email: cleanEmail, password: password);
  }
}
