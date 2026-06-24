import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/widgets/business_card.dart';
import 'package:quex/core/widgets/common_widgets.dart';
import 'package:quex/features/customer/presentation/widgets/customer_nav_bar.dart';
import 'package:quex/features/shared/providers/app_providers.dart';

class CustomerSearchScreen extends ConsumerStatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  ConsumerState<CustomerSearchScreen> createState() =>
      _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends ConsumerState<CustomerSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(businessSearchProvider(_query));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search salons, clinics...',
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: results.when(
        data: (list) {
          if (_query.isEmpty) {
            return const EmptyState(
              icon: Icons.search,
              title: 'Search for businesses',
              subtitle: 'Try "salon", "dental", or "haircut"',
            );
          }
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'No results found',
              subtitle: 'Try a different search term',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) => BusinessCard(
              business: list[index],
              onTap: () =>
                  context.push('/customer/check-in/${list[index].id}'),
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Search failed',
          subtitle: e.toString(),
        ),
      ),
    );
  }
}
