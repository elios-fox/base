import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
      const SizedBox(height: AppSpacing.lg),
      Text(message, textAlign: TextAlign.center),
      if (onRetry != null) ...[const SizedBox(height: AppSpacing.lg), FilledButton(onPressed: onRetry, child: const Text('Opnieuw proberen'))],
    ])));
  }
}
