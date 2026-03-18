import 'package:flutter/material.dart';

import '../../../core/models/attendance.dart';

class AttendanceTile extends StatelessWidget {
  const AttendanceTile({
    super.key,
    required this.attendance,
  });

  final Attendance attendance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (attendance.status) {
      AttendanceStatus.aanwezig => (Icons.check_circle, Colors.green),
      AttendanceStatus.afwezig => (Icons.cancel, Colors.red),
      AttendanceStatus.onzeker => (Icons.help, Colors.orange),
    };

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(attendance.userName),
      subtitle: attendance.reason.isNotEmpty ? Text(attendance.reason) : null,
      trailing: Text(
        switch (attendance.status) {
          AttendanceStatus.aanwezig => 'Aanwezig',
          AttendanceStatus.afwezig => 'Afwezig',
          AttendanceStatus.onzeker => 'Onzeker',
        },
        style: theme.textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}