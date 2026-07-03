import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

class AppSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AppSectionTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle!, style: AppTextStyles.caption),
          ],
        ],
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return _StateCard(title: title, message: message, icon: icon);
  }
}

class AppErrorState extends StatelessWidget {
  final String title;
  final String message;

  const AppErrorState({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      title: title,
      message: message,
      icon: Icons.error_outline,
      color: AppColors.error,
    );
  }
}

class AppLoading extends StatelessWidget {
  final String message;

  const AppLoading({super.key, this.message = 'Cargando informacion segura...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        color: AppColors.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(message, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const _StateCard({
    required this.title,
    required this.message,
    required this.icon,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: AppCard(
          color: AppColors.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 34, color: color),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title, textAlign: TextAlign.center, style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.sm),
              Text(message, textAlign: TextAlign.center, style: AppTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }
}
