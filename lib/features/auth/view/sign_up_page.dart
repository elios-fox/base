import 'package:flutter/material.dart';

import '../../../core/auth/auth_repository.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();
  bool _obs1 = true, _obs2 = true, _loading = false;
  String? _error;

  @override
  void initState() { super.initState(); _passC.addListener(_rebuild); }
  void _rebuild() => setState(() {});
  @override
  void dispose() { _nameC.dispose(); _emailC.dispose(); _passC.dispose(); _confirmC.dispose(); super.dispose(); }

  double _strengthVal(String pw) {
    if (pw.isEmpty) return 0;
    if (pw.length < 6) return 0.25;
    final v = [pw.contains(RegExp(r'[A-Z]')), pw.contains(RegExp(r'[a-z]')), pw.contains(RegExp(r'\d')), pw.contains(RegExp(r'[^A-Za-z0-9]'))].where((b) => b).length;
    return v >= 3 ? 1.0 : v >= 2 ? 0.66 : 0.4;
  }
  Color _strengthColor(double v) => v >= 1.0 ? AppColors.aanwezig : v >= 0.5 ? AppColors.onzeker : AppColors.afwezig;

  String? _validate() {
    if (_nameC.text.trim().length < 2) return 'Vul je naam in (minimaal 2 tekens)';
    if (!_emailC.text.contains('@')) return 'Voer een geldig e-mailadres in';
    if (_passC.text.length < 6) return 'Wachtwoord moet minimaal 6 tekens zijn';
    if (_passC.text != _confirmC.text) return 'Wachtwoorden komen niet overeen';
    return null;
  }

  Future<void> _register() async {
    final err = _validate();
    if (err != null) { setState(() => _error = err); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await locate<AuthRepository>().createUserWithEmailAndPassword(_emailC.text.trim(), _passC.text, name: _nameC.text.trim());
      if (result == SignUpResult.needsEmailConfirmation && mounted) {
        setState(() => _error = 'Bevestig je e-mailadres via de link in je inbox.');
      }
    } on AuthError catch (e) { if (mounted) setState(() => _error = e.message); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Widget _toggleText(bool obs, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Padding(padding: const EdgeInsets.only(right: 12), child: Text(obs ? 'Toon' : 'Verberg', style: const TextStyle(color: AppColors.grey, fontSize: 14, fontWeight: FontWeight.w500))));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sv = _strengthVal(_passC.text);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Account aanmaken', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.xxl),
        if (_error != null) ...[Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: AppSpacing.borderRadiusSm), child: Text(_error!, style: const TextStyle(color: AppColors.error))), const SizedBox(height: AppSpacing.lg)],
        TextField(controller: _nameC, textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next, decoration: const InputDecoration(hintText: 'Volledige naam', prefixIcon: Icon(Icons.person_outlined))),
        const SizedBox(height: AppSpacing.lg),
        TextField(controller: _emailC, keyboardType: TextInputType.emailAddress, autocorrect: false, textInputAction: TextInputAction.next, decoration: const InputDecoration(hintText: 'E-mailadres', prefixIcon: Icon(Icons.email_outlined))),
        const SizedBox(height: AppSpacing.lg),
        TextField(controller: _passC, obscureText: _obs1, textInputAction: TextInputAction.next, decoration: InputDecoration(hintText: 'Wachtwoord', prefixIcon: const Icon(Icons.lock_outlined), suffixIcon: _toggleText(_obs1, () => setState(() => _obs1 = !_obs1)), suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0))),
        if (_passC.text.isNotEmpty) Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: LinearProgressIndicator(value: sv, backgroundColor: AppColors.divider, color: _strengthColor(sv), minHeight: 4, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: AppSpacing.lg),
        TextField(controller: _confirmC, obscureText: _obs2, textInputAction: TextInputAction.done, onSubmitted: (_) => _register(), decoration: InputDecoration(hintText: 'Herhaal wachtwoord', prefixIcon: const Icon(Icons.lock_outlined), suffixIcon: _toggleText(_obs2, () => setState(() => _obs2 = !_obs2)), suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0))),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(onPressed: _loading ? null : _register, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Registreren')),
        const SizedBox(height: AppSpacing.xl),
        Row(children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg), child: Text('of', style: TextStyle(color: AppColors.grey))), const Expanded(child: Divider())]),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton.icon(onPressed: () async { try { await locate<AuthRepository>().signInWithGoogle(); } on AuthError catch (e) { if (mounted) setState(() => _error = e.message); } }, icon: const Icon(Icons.g_mobiledata, size: 24), label: const Text('Doorgaan met Google')),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(onPressed: () async { try { await locate<AuthRepository>().signInWithApple(); } on AuthError catch (e) { if (mounted) setState(() => _error = e.message); } }, icon: const Icon(Icons.apple, size: 20), label: const Text('Doorgaan met Apple')),
      ]))),
    );
  }
}
