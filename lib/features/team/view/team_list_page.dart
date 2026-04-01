import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

class TeamListPage extends StatelessWidget {
  const TeamListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teams'), actions: [IconButton(icon: const Icon(Icons.group_add_outlined), onPressed: () => context.push('/teams/join'))]),
      body: Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.groups_outlined, size: 64, color: AppColors.greyLight),
        const SizedBox(height: AppSpacing.lg),
        Text('Nog geen teams', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Text('Maak een team aan of join er een.', style: TextStyle(color: AppColors.grey)),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(onPressed: () => context.push('/team/create'), icon: const Icon(Icons.add), label: const Text('Team aanmaken')),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(onPressed: () => context.push('/teams/join'), icon: const Icon(Icons.qr_code), label: const Text('Team joinen')),
      ]))),
    );
  }
}
