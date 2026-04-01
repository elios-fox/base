import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/di/injection.dart';
import '../../../core/models/team.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../services/team_service.dart';

class TeamInvitePage extends StatefulWidget {
  const TeamInvitePage({super.key, required this.teamId});
  final String teamId;
  @override
  State<TeamInvitePage> createState() => _TeamInvitePageState();
}

class _TeamInvitePageState extends State<TeamInvitePage> {
  Team? _team;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final team = await locate<TeamService>().getTeam(widget.teamId);
    if (mounted) setState(() { _team = team; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(title: const Text('Leden uitnodigen')), body: const Center(child: CircularProgressIndicator()));

    final code = _team?.inviteCode ?? '????????';
    return Scaffold(
      appBar: AppBar(title: const Text('Leden uitnodigen')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Deel deze code met je teamleden:', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
        const SizedBox(height: AppSpacing.xl),
        Center(child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: Colors.white, borderRadius: AppSpacing.borderRadiusMd, border: Border.all(color: AppColors.divider)),
          child: QrImageView(data: code, version: QrVersions.auto, size: 180),
        )),
        const SizedBox(height: AppSpacing.xl),
        Text('Of deel de teamcode:', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey, fontSize: 13)),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code gekopieerd!')));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
            decoration: BoxDecoration(border: Border.all(color: AppColors.divider), borderRadius: AppSpacing.borderRadiusMd),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(code, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 4)),
              const SizedBox(width: AppSpacing.lg),
              Icon(Icons.copy_outlined, color: AppColors.grey),
            ]),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton.icon(
          onPressed: () {
            final msg = 'Join mijn team "${_team!.name}" op ClubHub!\nGebruik code: $code';
            SharePlus.instance.share(ShareParams(text: msg));
          },
          icon: const Icon(Icons.share_outlined),
          label: const Text('Deel uitnodiging'),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text('Leden (${_team?.memberUids.length ?? 0})', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        ...(_team?.memberUids ?? []).map((uid) => ListTile(
          dense: true,
          leading: CircleAvatar(radius: 14, backgroundColor: AppColors.aanwezig, child: const Icon(Icons.check, size: 14, color: Colors.white)),
          title: Text(uid == _team?.ownerUid ? 'Captain' : 'Lid', style: const TextStyle(fontSize: 13)),
          subtitle: Text(uid.substring(0, 8), style: TextStyle(fontSize: 11, color: AppColors.grey)),
        )),
      ])),
    );
  }
}
