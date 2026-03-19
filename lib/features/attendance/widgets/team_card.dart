import 'package:flutter/material.dart';

import '../../../core/models/team.dart';
import '../../../core/utils/color_utils.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({
    super.key,
    required this.team,
    required this.onTap,
    this.onDelete,
  });

  final Team team;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = team.dominantColor != null
        ? ColorUtils.hexToColor(team.dominantColor!)
        : theme.colorScheme.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: accentColor, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo header
              if (team.photoUrl != null)
                Image.network(
                  team.photoUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      _buildColorPlaceholder(accentColor, theme),
                )
              else
                _buildColorPlaceholder(accentColor, theme),

              // Info row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.groups, color: accentColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team.name,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${team.memberUids.length} leden',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onDelete,
                      )
                    else
                      const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPlaceholder(Color accentColor, ThemeData theme) {
    return Container(
      height: 120,
      color: accentColor.withValues(alpha: 0.12),
      child: Center(
        child: Icon(
          Icons.groups,
          size: 48,
          color: accentColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
