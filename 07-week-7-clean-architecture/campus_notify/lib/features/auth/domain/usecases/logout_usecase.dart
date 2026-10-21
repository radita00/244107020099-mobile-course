import '../../../../core/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case: Logout pengguna.
class LogoutUseCase {
  const LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<({bool success, Failure? failure})> call() {
    return _repository.logout();
  }
}
