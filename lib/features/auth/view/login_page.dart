import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_repository.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _obscure = true, _loading = false;
  String? _error;

  @override
  void initState() { super.initState(); _emailC.addListener(_rebuild); _passC.addListener(_rebuild); }
  void _rebuild() => setState(() {});
  bool get _canSubmit => !_loading && _emailC.text.trim().isNotEmpty && _passC.text.isNotEmpty;

  @override
  void dispose() { _emailC.dispose(); _passC.dispose(); super.dispose(); }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await locate<AuthRepository>().signInWithEmailAndPassword(_emailC.text.trim(), _passC.text);
    } on AuthError catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: AppSpacing.xxxl),
        Text('ClubHub', textAlign: TextAlign.center, style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        Text('Log in om verder te gaan', textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.grey)),
        const SizedBox(height: AppSpacing.xxl),
        if (_error != null) ...[
          Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: AppSpacing.borderRadiusSm),
            child: Text(_error!, style: const TextStyle(color: AppColors.error))),
          const SizedBox(height: AppSpacing.lg),
        ],
        TextField(controller: _emailC, keyboardType: TextInputType.emailAddress, autocorrect: false, textInputAction: TextInputAction.next, decoration: const InputDecoration(hintText: 'E-mailadres', prefixIcon: Icon(Icons.email_outlined))),
        const SizedBox(height: AppSpacing.lg),
        TextField(controller: _passC, obscureText: _obscure, textInputAction: TextInputAction.done, onSubmitted: (_) => _canSubmit ? _login() : null,
          decoration: InputDecoration(hintText: 'Wachtwoord', prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: GestureDetector(onTap: () => setState(() => _obscure = !_obscure), child: Padding(padding: const EdgeInsets.only(right: 12), child: Text(_obscure ? 'Toon' : 'Verberg', style: const TextStyle(color: AppColors.grey, fontSize: 14, fontWeight: FontWeight.w500)))),
            suffixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0))),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.push('/forgot-password'), child: const Text('Wachtwoord vergeten?'))),
        const SizedBox(height: AppSpacing.sm),
        FilledButton(onPressed: _canSubmit ? _login : null, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Inloggen')),
        const SizedBox(height: AppSpacing.xl),
        Row(children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg), child: Text('of', style: TextStyle(color: AppColors.grey))), const Expanded(child: Divider())]),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton.icon(onPressed: () async { try { await locate<AuthRepository>().signInWithGoogle(); } on AuthError catch (e) { if (mounted) setState(() => _error = e.message); } }, icon: const Icon(Icons.g_mobiledata, size: 24), label: const Text('Doorgaan met Google')),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(onPressed: () async { try { await locate<AuthRepository>().signInWithApple(); } on AuthError catch (e) { if (mounted) setState(() => _error = e.message); } }, icon: const Icon(Icons.apple, size: 20), label: const Text('Doorgaan met Apple')),
        const SizedBox(height: AppSpacing.xxl),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Geen account? '),
          GestureDetector(onTap: () => context.push('/sign-up'), child: Text('Registreer je', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary, decoration: TextDecoration.underline))),
        ]),
      ]))),
    );
  }
}
