import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  final double fontSize;
  final bool showMotto;
  final bool isDark;

  const BrandLogo({
    super.key,
    this.fontSize = 24,
    this.showMotto = false,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(
                    text: 're',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.primaryBlue,
                    ),
                  ),
                  const TextSpan(
                    text: 'vola',
                    style: TextStyle(color: AppTheme.accentOrange),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showMotto) ...[
          const SizedBox(height: 3),
          Text(
            'Every Good Thing Deserves a Second Life',
            style: TextStyle(
              fontSize: fontSize * 0.42,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppTheme.textSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ],
    );
  }
}
