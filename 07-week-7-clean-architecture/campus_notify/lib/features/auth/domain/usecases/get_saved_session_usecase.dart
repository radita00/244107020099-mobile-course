import '../../../../core/failures.dart';
import '../entities/auth_session_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case: Memeriksa dan mengambil sesi yang tersimpan di perangkat.
class GetSavedSessionUseCase {
  const GetSavedSessionUseCase(this._repository);
  final AuthRepository _repository;

  Future<({AuthSessionEntity? session, Failure? failure})> call() {
    return _repository.getSavedSession();
  }
}
