import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';

/// Composition root fitur auth.
///
/// Satu-satunya berkas di fitur ini yang boleh mengimpor `data/`.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});
