import 'package:flutter/material.dart';
import '../ui/theme/app_colors.dart';
import '../ui/theme/app_radius.dart';
import '../ui/theme/app_spacing.dart';
import '../ui/theme/app_text_styles.dart';

class Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onLogout;

  const Header(
      {super.key, required this.title, required this.subtitle, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 78,
              height: 48,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: AppColors.bankingGradient,
                borderRadius: AppRadius.input,
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Image.asset('assets/banbif.png', fit: BoxFit.contain),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: Colors.white.withValues(alpha: 0.92)),
                  ),
                ],
              ),
            ),
            if (onLogout != null)
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
