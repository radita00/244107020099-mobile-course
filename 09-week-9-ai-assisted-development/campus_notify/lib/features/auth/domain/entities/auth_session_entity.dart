/// Entity murni untuk sesi autentikasi.
/// Tidak ada toMap/fromMap/toJson — itu urusan data layer (model).
/// Hidup di domain, tidak bergantung pada package apa pun.
class AuthSessionEntity {
  const AuthSessionEntity({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSessionEntity &&
          other.accessToken == accessToken &&
          other.refreshToken == refreshToken;

  @override
  int get hashCode => accessToken.hashCode ^ refreshToken.hashCode;

  @override
  String toString() =>
      'AuthSessionEntity(access: ${accessToken.substring(0, accessToken.length < 8 ? accessToken.length : 8)}..., refresh: ***)';
}
