import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/constants/app_constants.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/theme/customer_auth_theme.dart';
import 'package:quex/domain/entities/entities.dart';
import 'package:quex/features/customer/presentation/providers/customer_session_provider.dart';
import 'package:quex/features/customer/presentation/widgets/customer_dark_widgets.dart';

/// Salon / hospital listing with filters (mockup screens 3–4).
class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  String _filterChip = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isHealth {
    final cat = ref.read(businessFiltersProvider).category;
    return cat == 'Health';
  }

  Color get _accent =>
      _isHealth ? AppColors.clinicBlue : AppColors.accent;

  String get _title => _isHealth ? 'Hospitals & Clinics' : 'Salons';

  List<String> get _chips {
    if (_isHealth) return ['All', 'Hospitals', 'Clinics'];
    return ['All', 'Haircut', 'Spa', 'Styling'];
  }

  @override
  Widget build(BuildContext context) {
    final businesses = ref.watch(filteredBusinessesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: businesses.when(
          data: (list) {
            final query = _searchController.text.toLowerCase();
            var filtered = list.where((b) {
              if (query.isNotEmpty &&
                  !b.name.toLowerCase().contains(query) &&
                  !b.address.toLowerCase().contains(query)) {
                return false;
              }
              if (_filterChip == 'All') return true;
              if (_isHealth) {
                if (_filterChip == 'Hospitals') return b.category == 'Hospital';
                if (_filterChip == 'Clinics') return b.category == 'Clinic';
              }
              return b.services.any(
                (s) => s.toLowerCase().contains(_filterChip.toLowerCase()),
              );
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: _accent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        AppConstants.defaultCity,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search $_title',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _chips.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final chip = _chips[i];
                      final selected = _filterChip == chip;
                      return FilterChip(
                        label: Text(chip),
                        selected: selected,
                        onSelected: (_) => setState(() => _filterChip = chip),
                        selectedColor: _accent.withValues(alpha: 0.2),
                        checkmarkColor: _accent,
                        labelStyle: TextStyle(
                          color: selected ? _accent : AppColors.textSecondary,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: selected ? _accent : AppColors.divider,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No locations match your search',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: AppColors.divider, height: 1),
                          itemBuilder: (context, index) {
                            return _BusinessListRow(
                              business: filtered[index],
                              accent: _accent,
                              onTap: () => context.push(
                                '/customer/business/${filtered[index].id}',
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (e, _) => Center(child: Text('$e')),
        ),
      ),
      bottomNavigationBar: const CustomerNavBar(currentIndex: 1),
    );
  }
}

class _BusinessListRow extends StatelessWidget {
  const _BusinessListRow({
    required this.business,
    required this.accent,
    required this.onTap,
  });

  final Business business;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isHealth =
        business.category == 'Clinic' || business.category == 'Hospital';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isHealth
                    ? CustomerAuthColors.clinicTint.withValues(alpha: 0.3)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isHealth ? Icons.local_hospital_outlined : Icons.content_cut,
                color: accent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    business.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    business.isOpen ? 'Open' : 'Closed',
                    style: TextStyle(
                      color: business.isOpen ? accent : AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (business.isOpen)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${business.waitMinutes} min',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const Text(
                    'EST WAIT',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
