class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const pengumuman = '/pengumuman/:id';

  static String pengumumanDetail(String id) => '/pengumuman/$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  final route = (data['route'] ?? '/').toString();
  return route.startsWith('/') ? route : '/$route';
}