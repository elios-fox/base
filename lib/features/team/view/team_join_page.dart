import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../services/team_service.dart';

class TeamJoinPage extends StatefulWidget {
  const TeamJoinPage({super.key});
  @override
  State<TeamJoinPage> createState() => _TeamJoinPageState();
}

class _TeamJoinPageState extends State<TeamJoinPage> {
  final List<TextEditingController> _controllers = List.generate(8, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(8, (_) => FocusNode());
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();
  bool get _canSubmit => !_loading && _code.length == 8;

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < 7) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() => _error = null);
  }

  void _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace && _controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _join() async {
    setState(() { _loading = true; _error = null; });
    try {
      final team = await locate<TeamService>().joinTeam(_code.toUpperCase());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Je bent lid geworden van ${team.name}!')));
        context.pop();
      }
    } catch (e) {
      final msg = e.toString();
      if (mounted) setState(() {
        _loading = false;
        _error = msg.contains('niet gevonden') ? 'Team niet gevonden met deze code.' : msg.contains('al lid') ? 'Je bent al lid van dit team.' : 'Kon niet joinen. Probeer opnieuw.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Team joinen')),
      body: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: AppSpacing.lg),
        Text('Voer de teamcode in die je van je captain hebt gekregen.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
        const SizedBox(height: AppSpacing.xxl),

        // PIN invoer
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(8, (i) {
          return Container(
            width: 36, height: 48,
            margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (e) => _onKey(i, e),
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                maxLength: 1,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                decoration: InputDecoration(counterText: '', contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2))),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
                onChanged: (v) => _onChanged(i, v),
              ),
            ),
          );
        })),
        const SizedBox(height: AppSpacing.xl),

        if (_error != null) ...[
          Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: AppSpacing.borderRadiusSm), child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error))),
          const SizedBox(height: AppSpacing.lg),
        ],

        FilledButton(onPressed: _canSubmit ? _join : null, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Zoek team')),
      ])),
    );
  }
}
