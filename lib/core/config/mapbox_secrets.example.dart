/// Copy this file to `mapbox_secrets.dart` and paste your Mapbox public token.
///
/// Create a token at https://account.mapbox.com/access-tokens/ with these scopes:
///   - styles:tiles  (required — loads map tiles in flutter_map)
///   - styles:read   (required — reads style metadata)
///   - fonts:read    (recommended)
///
/// Do NOT add URL restrictions (breaks mobile tile requests).
/// Do NOT commit mapbox_secrets.dart — it is gitignored.
class MapboxSecrets {
  static const token = 'pk.YOUR_MAPBOX_PUBLIC_TOKEN';
}
