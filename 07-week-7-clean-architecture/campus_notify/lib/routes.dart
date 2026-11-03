abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const announcementPattern = '/pengumuman/:id';

  static String announcement(String id) => '/pengumuman/$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  final value = data['route'];
  if (value is! String || value.trim().isEmpty) return AppRoutes.home;

  final route = value.trim();
  final normalized = route.startsWith('/') ? route : '/$route';
  if (normalized == AppRoutes.home || normalized == AppRoutes.login) {
    return normalized;
  }

  final segments = Uri.tryParse(normalized)?.pathSegments;
  if (segments != null &&
      segments.length == 2 &&
      segments.first == 'pengumuman' &&
      segments.last.isNotEmpty) {
    return AppRoutes.announcement(Uri.encodeComponent(segments.last));
  }
  return AppRoutes.home;
}
