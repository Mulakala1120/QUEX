import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/quex_map_layers.dart';
import 'package:quex/core/config/map_config.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/customer/presentation/providers/customer_session_provider.dart';
import 'package:quex/features/customer/presentation/widgets/customer_dark_widgets.dart';

class CustomerMapScreen extends ConsumerStatefulWidget {
  const CustomerMapScreen({super.key});

  @override
  ConsumerState<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends ConsumerState<CustomerMapScreen> {
  final _mapController = MapController();
  bool _mapView = true;
  bool _centeredOnUser = false;

  @override
  Widget build(BuildContext context) {
    final businesses = ref.watch(filteredBusinessesProvider);
    final activeCheckIn = ref.watch(activeCheckInProvider);
    final filters = ref.watch(businessFiltersProvider);
    final locationAsync = ref.watch(userLocationProvider);

    final userCenter = locationAsync.maybeWhen(
      data: (loc) => LatLng(loc.latitude, loc.longitude),
      orElse: () => LatLng(MapConfig.defaultLat, MapConfig.defaultLng),
    );

    if (!_centeredOnUser && locationAsync.hasValue) {
      _centeredOnUser = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(userCenter, 12);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: businesses.when(
        data: (list) {
          if (!_mapView) {
            return Column(
              children: [
                _Header(
                  filters: filters,
                  mapView: _mapView,
                  onToggle: (v) => setState(() => _mapView = v),
                  onSearch: () => context.push('/customer/search'),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: FilterChipRow(),
                ),
                Expanded(
                  child: _BusinessList(
                    businesses: list,
                    activeBusinessId: activeCheckIn?.businessId,
                  ),
                ),
              ],
            );
          }
          return Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    filters: filters,
                    mapView: _mapView,
                    onToggle: (v) => setState(() => _mapView = v),
                    onSearch: () => context.push('/customer/search'),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: userCenter,
                            initialZoom: 12,
                          ),
                          children: [
                            ...quexMapBaseLayers(),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: userCenter,
                                  width: 24,
                                  height: 24,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                                ...list.where((b) => b.isOpen).map(
                                      (b) => Marker(
                                        point: LatLng(b.latitude, b.longitude),
                                        width: 56,
                                        height: 64,
                                        child: _MapPin(
                                          minutes: b.waitMinutes,
                                          checkedIn:
                                              activeCheckIn?.businessId == b.id,
                                          onTap: () => context.push(
                                            '/customer/check-in/${b.id}',
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: 12,
                          right: 16,
                          child: FloatingActionButton.small(
                            backgroundColor: AppColors.surface,
                            onPressed: () => _mapController.move(userCenter, 12),
                            child: const Icon(
                              Icons.my_location,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.32,
                minChildSize: 0.22,
                maxChildSize: 0.75,
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: FilterChipRow(),
                        ),
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const Divider(
                              color: AppColors.divider,
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final b = list[index];
                              return SalonListTile(
                                business: b,
                                showCheckedIn:
                                    activeCheckIn?.businessId == b.id,
                                onTap: () => context.push(
                                  '/customer/check-in/${b.id}',
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: const CustomerNavBar(currentIndex: 1),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.filters,
    required this.mapView,
    required this.onToggle,
    required this.onSearch,
  });

  final BusinessFilters filters;
  final bool mapView;
  final ValueChanged<bool> onToggle;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final title = filters.category == 'Salon'
        ? 'Find a salon'
        : filters.category == 'Health'
            ? 'Find a clinic or hospital'
            : 'Find nearby';

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(onPressed: onSearch, icon: const Icon(Icons.search)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.accent, size: 18),
                const SizedBox(width: 4),
                        Text(
                          AppConstants.defaultCity,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MapListToggle(isMapView: mapView, onChanged: onToggle),
          ],
        ),
      ),
    );
  }
}

class _BusinessList extends StatelessWidget {
  const _BusinessList({
    required this.businesses,
    required this.activeBusinessId,
  });

  final List<Business> businesses;
  final String? activeBusinessId;

  @override
  Widget build(BuildContext context) {
    if (businesses.isEmpty) {
      return const Center(
        child: Text(
          'No locations match your filters',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: businesses.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.divider, height: 1),
      itemBuilder: (context, index) {
        final b = businesses[index];
        return SalonListTile(
          business: b,
          showCheckedIn: activeBusinessId == b.id,
          onTap: () => context.push('/customer/check-in/${b.id}'),
        );
      },
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.minutes,
    required this.onTap,
    this.checkedIn = false,
  });

  final int minutes;
  final VoidCallback onTap;
  final bool checkedIn;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$minutes min',
                  style: const TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              if (checkedIn)
                const Positioned(
                  right: -4,
                  top: -4,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
            ],
          ),
          CustomPaint(
            size: const Size(12, 8),
            painter: _PinTailPainter(),
          ),
        ],
      ),
    );
  }
}

class _PinTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.accent;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
