import 'package:quex/core/config/mapbox_secrets.dart';

/// Map provider config for QueX India (Mapbox dark style).
class MapConfig {
  static const defaultCity = 'Hyderabad, India';
  static const defaultLat = 17.4401;
  static const defaultLng = 78.3489;

  /// Mapbox dark-v11 when a token is available; otherwise Carto fallback.
  static bool get useMapbox => mapboxAccessToken.isNotEmpty;

  static String get mapboxAccessToken {
    const fromEnv = String.fromEnvironment('MAPBOX_TOKEN');
    if (fromEnv.isNotEmpty) return fromEnv;
    return MapboxSecrets.token;
  }

  /// Raster tiles for [flutter_map].
  static String get mapboxTileUrl =>
      'https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}@2x'
      '?access_token=$mapboxAccessToken';

  static const cartoTileUrl =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

  static const cartoSubdomains = ['a', 'b', 'c', 'd'];
}
