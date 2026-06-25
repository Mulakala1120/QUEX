import 'dart:math';

/// Haversine distance in kilometres between two lat/lng points.
double distanceKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRad(lat2 - lat1);
  final dLon = _toRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

double _toRad(double deg) => deg * pi / 180;

/// Parse QueX join URLs: quex://q/biz_1 or https://quex.app/join/biz_1
String? parseQuexBusinessId(String raw) {
  final trimmed = raw.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return null;

  if (uri.scheme == 'quex' && uri.host == 'q' && uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.first;
  }
  if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'join') {
    return uri.pathSegments[1];
  }
  if (trimmed.startsWith('biz_')) return trimmed;
  return null;
}
