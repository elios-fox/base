import 'package:flutter/material.dart';

import '../../../core/models/attendance.dart';
import '../../../core/theme/app_colors.dart';

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
      AttendanceStatus.aanwezig => (Icons.check_circle, AppColors.aanwezig),
      AttendanceStatus.afwezig => (Icons.cancel, AppColors.afwezig),
      AttendanceStatus.onzeker => (Icons.help, AppColors.onzeker),
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