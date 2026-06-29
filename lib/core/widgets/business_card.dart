import 'package:flutter/material.dart';
import 'package:quex/core/widgets/quex_widgets.dart';
import 'package:quex/domain/entities/entities.dart';

class BusinessCard extends StatelessWidget {
  const BusinessCard({
    super.key,
    required this.business,
    required this.onTap,
    this.showJoinCta = false,
    this.onJoin,
  });

  final Business business;
  final VoidCallback onTap;
  final bool showJoinCta;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SalonListCard(
        business: business,
        onTap: onTap,
        showJoinCta: showJoinCta,
        onJoin: onJoin,
      ),
    );
  }
}
