import 'package:flutter/material.dart';

import '../../../core/models/standing_entry.dart';

class StandingsTable extends StatelessWidget {
  const StandingsTable({super.key, required this.standings});

  final List<StandingEntry> standings;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            const Color(0xFF2E7D32).withValues(alpha: 0.1),
          ),
          columnSpacing: 16,
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('Team')),
            DataColumn(label: Text('G'), numeric: true),
            DataColumn(label: Text('W'), numeric: true),
            DataColumn(label: Text('D'), numeric: true),
            DataColumn(label: Text('V'), numeric: true),
            DataColumn(label: Text('Pts'), numeric: true),
          ],
          rows: [
            for (var i = 0; i < standings.length; i++)
              _buildRow(context, i + 1, standings[i]),
          ],
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, int position, StandingEntry entry) {
    final isOwnTeam = entry.teamName == 'Eigen team';
    final textStyle = isOwnTeam
        ? const TextStyle(fontWeight: FontWeight.bold)
        : null;

    return DataRow(
      color: isOwnTeam
          ? WidgetStateProperty.all(
              const Color(0xFF2E7D32).withValues(alpha: 0.05),
            )
          : null,
      cells: [
        DataCell(Text('$position', style: textStyle)),
        DataCell(Text(entry.teamName, style: textStyle)),
        DataCell(Text('${entry.played}', style: textStyle)),
        DataCell(Text('${entry.won}', style: textStyle)),
        DataCell(Text('${entry.drawn}', style: textStyle)),
        DataCell(Text('${entry.lost}', style: textStyle)),
        DataCell(
          Text(
            '${entry.points}',
            style: (textStyle ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
