import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailC = TextEditingController();
  bool _loading = false, _sent = false;

  @override
  void initState() { super.initState(); _emailC.addListener(() => setState(() {})); }
  bool get _canSubmit => !_loading && _emailC.text.trim().isNotEmpty;
  @override
  void dispose() { _emailC.dispose(); super.dispose(); }

  Future<void> _send() async {
    setState(() => _loading = true);
    try { await Supabase.instance.client.auth.resetPasswordForEmail(_emailC.text.trim()); } catch (_) {}
    if (mounted) setState(() { _loading = false; _sent = true; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: _sent
        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: AppSpacing.xxxl),
            const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xl),
            Text('E-mail verstuurd', textAlign: TextAlign.center, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.lg),
            Text('We hebben een link gestuurd naar ${_emailC.text.trim()}.\nCheck je inbox.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(onPressed: () => context.go('/login'), child: const Text('Terug naar login')),
            TextButton(onPressed: _loading ? null : _send, child: const Text('Opnieuw versturen')),
          ])
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Wachtwoord vergeten', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.lg),
            Text('Voer je e-mailadres in en we sturen je een link om je wachtwoord te resetten.', style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: AppSpacing.xxl),
            TextField(controller: _emailC, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.done, onSubmitted: (_) => _canSubmit ? _send() : null, decoration: const InputDecoration(hintText: 'E-mailadres', prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(onPressed: _canSubmit ? _send : null, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Verstuur link')),
          ]))),
    );
  }
}
