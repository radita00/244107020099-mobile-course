import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session_entity.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/usecases/login_usecase.dart';
import 'package:campus_notify/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.fail = false, this.savedSession});

  final bool fail;
  AuthSessionEntity? savedSession;

  @override
  Future<({AuthSessionEntity? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    if (fail) {
      return (
        session: null,
        failure: const AuthFailure('Email atau password salah (simulasi)'),
      );
    }
    final session = AuthSessionEntity(
      accessToken: 'token-access-$email',
      refreshToken: 'token-refresh-$email',
    );
    savedSession = session;
    return (session: session, failure: null);
  }

  @override
  Future<({AuthSessionEntity? session, Failure? failure})>
  getSavedSession() async {
    return (session: savedSession, failure: null);
  }

  @override
  Future<({bool success, Failure? failure})> logout() async {
    savedSession = null;
    return (success: true, failure: null);
  }

  @override
  Future<({String? token, Failure? failure})> refresh(
    String refreshToken,
  ) async {
    return (token: 'refreshed-token', failure: null);
  }
}

void main() {
  group('Auth Domain Use Cases', () {
    test(
      'LoginUseCase memvalidasi format email sebelum memanggil repository',
      () async {
        final repo = FakeAuthRepository();
        final useCase = LoginUseCase(repo);

        final result = await useCase(
          email: 'invalid-email',
          password: 'password123',
        );

        expect(result.session, isNull);
        expect(result.failure, isA<ValidationFailure>());
        expect(result.failure?.message, contains('Email tidak valid'));
      },
    );

    test('LoginUseCase memvalidasi panjang minimal kata sandi', () async {
      final repo = FakeAuthRepository();
      final useCase = LoginUseCase(repo);

      final result = await useCase(email: 'user@campus.ac.id', password: '123');

      expect(result.session, isNull);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure?.message, contains('minimal 6'));
    });

    test('LoginUseCase berhasil dan mengembalikan AuthSessionEntity', () async {
      final repo = FakeAuthRepository();
      final useCase = LoginUseCase(repo);

      final result = await useCase(
        email: 'mhs@campus.ac.id',
        password: 'password123',
      );

      expect(result.failure, isNull);
      expect(result.session, isNotNull);
      expect(result.session?.accessToken, contains('mhs@campus.ac.id'));
    });

    test('LogoutUseCase berhasil membersihkan sesi', () async {
      final repo = FakeAuthRepository(
        savedSession: const AuthSessionEntity(
          accessToken: 'a',
          refreshToken: 'r',
        ),
      );
      final useCase = LogoutUseCase(repo);

      final result = await useCase();

      expect(result.failure, isNull);
      expect(result.success, isTrue);
      expect(repo.savedSession, isNull);
    });
  });
}
