import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:quex/core/config/map_config.dart';

/// Shared map tile + attribution layers for QueX (Mapbox or Carto fallback).
List<Widget> quexMapBaseLayers() {
  if (MapConfig.useMapbox) {
    return [
      TileLayer(
        urlTemplate: MapConfig.mapboxTileUrl,
        userAgentPackageName: 'com.quex.app',
        tileSize: 512,
        zoomOffset: -1,
      ),
      RichAttributionWidget(
        alignment: AttributionAlignment.bottomLeft,
        attributions: [
          TextSourceAttribution(
            'Mapbox',
            textStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          TextSourceAttribution(
            'OpenStreetMap',
            textStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    ];
  }

  return [
    TileLayer(
      urlTemplate: MapConfig.cartoTileUrl,
      subdomains: MapConfig.cartoSubdomains,
      userAgentPackageName: 'com.quex.app',
    ),
  ];
}
