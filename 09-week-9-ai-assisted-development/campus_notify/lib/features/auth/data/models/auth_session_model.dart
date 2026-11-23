import '../../domain/entities/auth_session_entity.dart';

/// Model untuk sesi autentikasi yang menangani serialisasi data (JSON/Map).
/// Hidup di Data Layer.
class AuthSessionModel extends AuthSessionEntity {
  const AuthSessionModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      accessToken:
          json['access_token'] as String? ?? json['access'] as String? ?? '',
      refreshToken:
          json['refresh_token'] as String? ?? json['refresh'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };

  AuthSessionEntity toEntity() =>
      AuthSessionEntity(accessToken: accessToken, refreshToken: refreshToken);
}
