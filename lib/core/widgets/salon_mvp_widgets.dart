import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/domain/entities/entities.dart';

class WaitTimeBadge extends StatelessWidget {
  const WaitTimeBadge({super.key, required this.minutes, this.compact = false});

  final int minutes;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$minutes min',
        style: TextStyle(
          color: AppColors.accentDark,
          fontSize: compact ? 13 : 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.accent : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        isOpen ? 'Open' : 'Closed',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class SalonPrimaryButton extends StatelessWidget {
  const SalonPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon ?? Icons.arrow_forward_rounded),
        label: Text(label),
      ),
    );
  }
}

class ServiceChip extends StatelessWidget {
  const ServiceChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      showCheckmark: false,
      selectedColor: AppColors.accent,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: selected ? AppColors.accent : AppColors.divider),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accent),
        suffixIcon:
            const Icon(Icons.tune_rounded, color: AppColors.textSecondary),
      ),
    );
  }
}

class SalonCard extends StatelessWidget {
  const SalonCard({
    super.key,
    required this.business,
    required this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.showImage = true,
  });

  final Business business;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (showImage) ...[
                const SalonAvatar(size: 66),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            business.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        WaitTimeBadge(
                            minutes: business.waitMinutes, compact: true),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        StatusBadge(isOpen: business.isOpen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${business.distanceMiles.toStringAsFixed(1)} km away',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      business.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (onFavorite != null)
                IconButton(
                  onPressed: onFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color:
                        isFavorite ? AppColors.error : AppColors.textSecondary,
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class FeaturedSalonCard extends StatelessWidget {
  const FeaturedSalonCard({
    super.key,
    required this.business,
    required this.onJoinQueue,
    required this.onFavorite,
    this.onViewQueue,
    this.isFavorite = false,
    this.isCheckedIn = false,
  });

  final Business business;
  final VoidCallback onJoinQueue;
  final VoidCallback onFavorite;
  final VoidCallback? onViewQueue;
  final bool isFavorite;
  final bool isCheckedIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SalonAvatar(size: 74, dark: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Featured Salon',
                        style: TextStyle(
                          color: AppColors.secondaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        business.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color:
                        isFavorite ? AppColors.secondaryGreen : Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _HeroMetric(
                    label: 'Live wait', value: '${business.waitMinutes} min'),
                const SizedBox(width: 12),
                _HeroMetric(
                  label: 'Distance',
                  value: '${business.distanceMiles.toStringAsFixed(1)} km',
                ),
                const SizedBox(width: 12),
                _HeroMetric(
                    label: 'Status',
                    value: business.isOpen ? 'Open' : 'Closed'),
              ],
            ),
            const SizedBox(height: 18),
            SalonPrimaryButton(
              label: isCheckedIn ? 'View Queue' : 'Check In',
              icon: isCheckedIn
                  ? Icons.confirmation_number_outlined
                  : Icons.add_rounded,
              onPressed:
                  isCheckedIn ? (onViewQueue ?? onJoinQueue) : onJoinQueue,
            ),
          ],
        ),
      ),
    );
  }
}

class QueueProgressCard extends StatelessWidget {
  const QueueProgressCard({
    super.key,
    required this.entry,
    required this.peopleAhead,
    required this.nowServing,
    required this.totalInQueue,
  });

  final QueueEntry entry;
  final int peopleAhead;
  final int nowServing;
  final int totalInQueue;

  @override
  Widget build(BuildContext context) {
    final progress =
        (1 - (peopleAhead / math.max(totalInQueue, 1))).clamp(0.08, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Text(
              'LIVE QUEUE STATUS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 174,
              height: 174,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 13,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'TOKEN',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '#${entry.position}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _QueueMetric(
                        label: 'People Ahead', value: '$peopleAhead')),
                const SizedBox(width: 10),
                Expanded(
                  child: _QueueMetric(
                    label: 'Current Wait',
                    value: '${entry.estimatedWaitMinutes}m',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QueueMetric(
                    label: 'Now Serving',
                    value: nowServing == 0 ? '-' : '#$nowServing',
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

class SalonAvatar extends StatelessWidget {
  const SalonAvatar({super.key, required this.size, this.dark = false});

  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [AppColors.accent, AppColors.secondaryGreen]
              : [
                  AppColors.accent.withValues(alpha: 0.16),
                  AppColors.secondaryGreen.withValues(alpha: 0.28),
                ],
        ),
      ),
      child: Icon(
        Icons.content_cut_rounded,
        color: dark ? AppColors.textPrimary : AppColors.accentDark,
        size: size * 0.42,
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueMetric extends StatelessWidget {
  const _QueueMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
