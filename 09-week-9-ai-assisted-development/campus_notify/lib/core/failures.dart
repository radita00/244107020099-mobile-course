/// Kelas dasar untuk kegagalan domain (murni Dart).
/// Domain tidak boleh melempar Exception langsung ke presentation;
/// gunakan Failure agar bisa dibedakan jenis kegagalannya.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Kegagalan pada penyimpanan lokal (SecureStorage / Cache / SQLite).
class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

/// Kegagalan koneksi jaringan atau DNS.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Kegagalan respons server (HTTP 4xx / 5xx).
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Kegagalan autentikasi / sesi habis.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Kegagalan validasi input pengguna.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
