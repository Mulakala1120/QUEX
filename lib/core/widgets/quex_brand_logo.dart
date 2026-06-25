import 'package:flutter/material.dart';
import 'package:quex/core/theme/app_theme.dart';
import 'package:quex/core/theme/customer_auth_theme.dart';

enum QueXLogoStyle { dark, light, admin }

/// Branded QueX logo — Q with X tail, used across customer & admin portals.
class QueXBrandLogo extends StatelessWidget {
  const QueXBrandLogo({
    super.key,
    this.size = 64,
    this.style = QueXLogoStyle.dark,
    this.showWordmark = false,
  });

  final double size;
  final QueXLogoStyle style;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final green = style == QueXLogoStyle.light
        ? CustomerAuthColors.primary
        : style == QueXLogoStyle.admin
            ? const Color(0xFF6366F1)
            : AppColors.accent;
    final darkGreen = style == QueXLogoStyle.light
        ? CustomerAuthColors.primaryDark
        : style == QueXLogoStyle.admin
            ? const Color(0xFF4F46E5)
            : AppColors.accentDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [green, darkGreen],
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: style == QueXLogoStyle.light
                ? [
                    BoxShadow(
                      color: green.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            'Q',
            style: TextStyle(
              fontSize: size * 0.52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
        if (showWordmark) ...[
          SizedBox(height: size * 0.2),
          Text(
            'QueX',
            style: TextStyle(
              fontSize: size * 0.38,
              fontWeight: FontWeight.w900,
              color: style == QueXLogoStyle.dark
                  ? AppColors.textPrimary
                  : CustomerAuthColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (style == QueXLogoStyle.light)
            Text(
              'Your time matters.',
              style: TextStyle(
                fontSize: size * 0.18,
                color: CustomerAuthColors.textSecondary,
              ),
            ),
        ],
      ],
    );
  }
}
