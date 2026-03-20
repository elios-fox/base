import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../services/finance_service.dart';
import '../bloc/finance_bloc.dart';

class ContributionCreatePage extends StatelessWidget {
  const ContributionCreatePage({super.key, required this.teamId});

  final String teamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinanceBloc(
        financeService: locate<FinanceService>(),
      ),
      child: _ContributionCreateView(teamId: teamId),
    );
  }
}

class _ContributionCreateView extends StatefulWidget {
  const _ContributionCreateView({required this.teamId});

  final String teamId;

  @override
  State<_ContributionCreateView> createState() =>
      _ContributionCreateViewState();
}

class _ContributionCreateViewState extends State<_ContributionCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _bedragController = TextEditingController();
  final _beschrijvingController = TextEditingController();
  DateTime? _deadline;
  int _seizoen = DateTime.now().year;

  @override
  void dispose() {
    _bedragController.dispose();
    _beschrijvingController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('nl', 'NL'),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kies een deadline')),
      );
      return;
    }

    // Bedrag in euro's omzetten naar centen
    final euroString = _bedragController.text.replaceAll(',', '.');
    final euros = double.tryParse(euroString);
    if (euros == null || euros <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul een geldig bedrag in')),
      );
      return;
    }
    final amountCents = (euros * 100).round();

    context.read<FinanceBloc>().add(ContributionCreateRequested(
          teamId: widget.teamId,
          seasonYear: _seizoen,
          amountCents: amountCents,
          description: _beschrijvingController.text.trim(),
          dueDate: _deadline!,
        ));

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contributie aanmaken')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bedrag
              TextFormField(
                controller: _bedragController,
                decoration: InputDecoration(
                  labelText: 'Bedrag (euro)',
                  prefixText: '\u20AC ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vul een bedrag in';
                  }
                  final parsed =
                      double.tryParse(value.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return 'Vul een geldig bedrag in';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Beschrijving
              TextFormField(
                controller: _beschrijvingController,
                decoration: InputDecoration(
                  labelText: 'Beschrijving',
                  hintText: 'bijv. Contributie voorjaar 2026',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vul een beschrijving in';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seizoen
              DropdownButtonFormField<int>(
                value: _seizoen,
                decoration: InputDecoration(
                  labelText: 'Seizoen',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: List.generate(5, (i) {
                  final year = DateTime.now().year + i - 1;
                  return DropdownMenuItem(
                    value: year,
                    child: Text('$year / ${year + 1}'),
                  );
                }),
                onChanged: (value) {
                  if (value != null) setState(() => _seizoen = value);
                },
              ),
              const SizedBox(height: 16),

              // Deadline picker
              InkWell(
                onTap: _pickDeadline,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Deadline',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _deadline != null
                        ? '${_deadline!.day}-${_deadline!.month}-${_deadline!.year}'
                        : 'Kies een datum',
                    style: TextStyle(
                      color: _deadline != null ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Contributie aanmaken'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
