import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog voor het invoeren van een wedstrijduitslag.
/// Retourneert een Map met 'home_score', 'away_score', 'opponent_name'
/// of null bij annulering.
class SubmitResultDialog extends StatefulWidget {
  const SubmitResultDialog({
    super.key,
    this.initialHomeScore,
    this.initialAwayScore,
    this.initialOpponentName,
  });

  final int? initialHomeScore;
  final int? initialAwayScore;
  final String? initialOpponentName;

  @override
  State<SubmitResultDialog> createState() => _SubmitResultDialogState();
}

class _SubmitResultDialogState extends State<SubmitResultDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _homeScoreController;
  late final TextEditingController _awayScoreController;
  late final TextEditingController _opponentController;

  @override
  void initState() {
    super.initState();
    _homeScoreController = TextEditingController(
      text: widget.initialHomeScore?.toString() ?? '',
    );
    _awayScoreController = TextEditingController(
      text: widget.initialAwayScore?.toString() ?? '',
    );
    _opponentController = TextEditingController(
      text: widget.initialOpponentName ?? '',
    );
  }

  @override
  void dispose() {
    _homeScoreController.dispose();
    _awayScoreController.dispose();
    _opponentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Uitslag invoeren'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _opponentController,
              decoration: const InputDecoration(
                labelText: 'Tegenstander',
                hintText: 'Naam van de tegenstander',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vul de naam van de tegenstander in';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _homeScoreController,
                    decoration: const InputDecoration(
                      labelText: 'Thuis',
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Verplicht';
                      }
                      return null;
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '-',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _awayScoreController,
                    decoration: const InputDecoration(
                      labelText: 'Uit',
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Verplicht';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Opslaan'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop({
        'home_score': int.parse(_homeScoreController.text),
        'away_score': int.parse(_awayScoreController.text),
        'opponent_name': _opponentController.text.trim(),
      });
    }
  }
}
