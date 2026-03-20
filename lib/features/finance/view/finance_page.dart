import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../services/finance_service.dart';
import '../bloc/finance_bloc.dart';
import 'finance_view.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinanceBloc(
        financeService: locate<FinanceService>(),
      )..add(FinanceLoadRequested(teamId: teamId)),
      child: FinanceView(teamId: teamId),
    );
  }
}
