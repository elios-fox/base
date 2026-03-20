import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/models/club_member.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../services/club_service.dart';
import '../bloc/club_bloc.dart';

class ClubDetailPage extends StatelessWidget {
  const ClubDetailPage({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClubBloc(
        clubService: locate<ClubService>(),
        userId: SupabaseClientWrapper.instance.userId,
      )
        ..add(ClubDetailLoadRequested(clubId: clubId))
        ..add(ClubMembersLoadRequested(clubId: clubId)),
      child: _ClubDetailView(clubId: clubId),
    );
  }
}

class _ClubDetailView extends StatelessWidget {
  const _ClubDetailView({required this.clubId});
  final String clubId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ClubBloc, ClubState>(
          buildWhen: (prev, curr) => prev.selectedClub != curr.selectedClub,
          builder: (context, state) =>
              Text(state.selectedClub?.name ?? 'Club'),
        ),
      ),
      body: BlocBuilder<ClubBloc, ClubState>(
        builder: (context, state) {
          if (state.members.isEmpty) return const LoadingIndicator();

          final bestuur = state.members
              .where((m) => m.role == ClubRole.bestuur)
              .toList();
          final captains = state.members
              .where((m) => m.role == ClubRole.teamcaptain)
              .toList();
          final spelers = state.members
              .where((m) => m.role == ClubRole.speler)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Teams section
              _SectionHeader(
                title: 'Teams',
                trailing: state.isBestuur
                    ? IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => context.goNamed(
                          RouteNames.attendance,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.groups),
                  title: const Text('Bekijk teams'),
                  subtitle: const Text('Beheer teams en leden'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goNamed(RouteNames.attendance),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Members section
              _SectionHeader(title: 'Leden (${state.members.length})'),
              const SizedBox(height: AppSpacing.sm),

              if (bestuur.isNotEmpty) ...[
                _RoleHeader(title: 'Bestuur', count: bestuur.length),
                ...bestuur.map((m) => _MemberTile(
                      member: m,
                      canEdit: state.isBestuur,
                      currentUserId: SupabaseClientWrapper.instance.userId,
                      onRoleChanged: (role) => context
                          .read<ClubBloc>()
                          .add(ClubMemberRoleChanged(
                            memberId: m.id,
                            newRole: role,
                          )),
                      onRemove: () => context
                          .read<ClubBloc>()
                          .add(ClubMemberRemoved(memberId: m.id)),
                    )),
              ],

              if (captains.isNotEmpty) ...[
                _RoleHeader(title: 'Teamcaptains', count: captains.length),
                ...captains.map((m) => _MemberTile(
                      member: m,
                      canEdit: state.isBestuur,
                      currentUserId: SupabaseClientWrapper.instance.userId,
                      onRoleChanged: (role) => context
                          .read<ClubBloc>()
                          .add(ClubMemberRoleChanged(
                            memberId: m.id,
                            newRole: role,
                          )),
                      onRemove: () => context
                          .read<ClubBloc>()
                          .add(ClubMemberRemoved(memberId: m.id)),
                    )),
              ],

              if (spelers.isNotEmpty) ...[
                _RoleHeader(title: 'Spelers', count: spelers.length),
                ...spelers.map((m) => _MemberTile(
                      member: m,
                      canEdit: state.isBestuur,
                      currentUserId: SupabaseClientWrapper.instance.userId,
                      onRoleChanged: (role) => context
                          .read<ClubBloc>()
                          .add(ClubMemberRoleChanged(
                            memberId: m.id,
                            newRole: role,
                          )),
                      onRemove: () => context
                          .read<ClubBloc>()
                          .add(ClubMemberRemoved(memberId: m.id)),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _RoleHeader extends StatelessWidget {
  const _RoleHeader({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      child: Text(
        '$title ($count)',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.canEdit,
    required this.currentUserId,
    required this.onRoleChanged,
    required this.onRemove,
  });

  final ClubMember member;
  final bool canEdit;
  final String currentUserId;
  final ValueChanged<ClubRole> onRoleChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = member.userUid == currentUserId;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            (member.displayName ?? member.email ?? '?')[0].toUpperCase(),
            style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(
          '${member.displayName ?? member.email ?? 'Onbekend'}${isMe ? ' (jij)' : ''}',
        ),
        subtitle: Text(_roleLabel(member.role)),
        trailing: canEdit && !isMe
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'remove') {
                    onRemove();
                  } else {
                    onRoleChanged(ClubRole.values.byName(value));
                  }
                },
                itemBuilder: (_) => [
                  for (final role in ClubRole.values)
                    PopupMenuItem(
                      value: role.name,
                      child: Text(_roleLabel(role)),
                    ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text(
                      'Verwijderen',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  String _roleLabel(ClubRole role) {
    return switch (role) {
      ClubRole.bestuur => 'Bestuur',
      ClubRole.teamcaptain => 'Teamcaptain',
      ClubRole.speler => 'Speler',
    };
  }
}
