import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthBloc>().state.user;
    final initial = (user?.displayName ?? '?').isNotEmpty ? (user?.displayName ?? '?')[0].toUpperCase() : '?';
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('ClubHub', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          GestureDetector(onTap: () => context.go('/profile'), child: CircleAvatar(radius: 20, backgroundColor: AppColors.primary, child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)))),
        ]),
        const SizedBox(height: AppSpacing.xl),
        Card(child: InkWell(borderRadius: AppSpacing.borderRadiusMd, onTap: () => context.push('/team/create'), child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Team toevoegen', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            Text('Maak een nieuw team aan', style: TextStyle(color: AppColors.grey)),
          ])),
          Container(width: 44, height: 44, decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: AppSpacing.borderRadiusSm), child: const Icon(Icons.add)),
        ])))),
        const SizedBox(height: AppSpacing.xl),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)), child: const Text('Evenement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
        const SizedBox(height: AppSpacing.lg),
        Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl), child: Column(children: [
          Icon(Icons.event_outlined, size: 48, color: AppColors.greyLight),
          const SizedBox(height: AppSpacing.sm),
          Text('Nog geen evenementen', style: TextStyle(color: AppColors.grey)),
        ]))),
      ]))),
    );
  }
}
