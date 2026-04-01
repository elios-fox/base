import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/auth_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../services/team_service.dart';
import '../../../core/supabase/supabase_storage.dart';

class TeamCreatePage extends StatefulWidget {
  const TeamCreatePage({super.key});
  @override
  State<TeamCreatePage> createState() => _TeamCreatePageState();
}

class _TeamCreatePageState extends State<TeamCreatePage> {
  final _nameC = TextEditingController();
  String _sport = 'Voetbal';
  File? _bannerImage;
  bool _saving = false;
  String? _error;

  static const _sports = ['Voetbal', 'Hockey', 'Handbal', 'Basketbal', 'Volleybal', 'Tennis', 'Atletiek', 'Zwemmen', 'Overig'];

  @override
  void dispose() { _nameC.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked != null) setState(() => _bannerImage = File(picked.path));
  }

  Future<void> _save() async {
    final name = _nameC.text.trim();
    if (name.isEmpty) { setState(() => _error = 'Geef je team een naam'); return; }

    setState(() { _saving = true; _error = null; });
    try {
      final uid = context.read<AuthBloc>().state.user!.uid;
      final team = await locate<TeamService>().createTeam(name, uid, _sport);

      if (_bannerImage != null) {
        final url = await locate<StorageService>().uploadImage('teams/${team.id}/banner.jpg', _bannerImage!);
        await locate<TeamService>().updateTeamPhoto(team.id, url, '');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team aangemaakt!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = 'Kon team niet aanmaken. Probeer opnieuw.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text('Team toevoegen'), actions: [
        TextButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Opslaan')),
      ]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Banner
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 160, 
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: AppSpacing.borderRadiusMd,
              image: _bannerImage != null ? DecorationImage(image: FileImage(_bannerImage!), fit: BoxFit.cover) : null,
            ),
            child: _bannerImage == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text('Tap voor teamfoto', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
            ]) : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        if (_error != null) ...[
          Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: AppSpacing.borderRadiusSm), child: Text(_error!, style: const TextStyle(color: AppColors.error))),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Naam
        TextField(controller: _nameC, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'Teamnaam', prefixIcon: Icon(Icons.groups_outlined))),
        const SizedBox(height: AppSpacing.lg),

        // Sport dropdown
        DropdownButtonFormField<String>(
          initialValue: _sport,
          decoration: const InputDecoration(hintText: 'Sport', prefixIcon: Icon(Icons.sports_soccer_outlined)),
          items: _sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) { if (v != null) setState(() => _sport = v); },
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Secties
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm), decoration: BoxDecoration(color: AppColors.training, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)), child: const Text('Evenement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
        Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl), child: Center(child: Text('Eerst opslaan, daarna evenementen toevoegen', style: TextStyle(color: AppColors.grey, fontSize: 13)))),

        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm), decoration: BoxDecoration(color: AppColors.tertiary, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)), child: const Text('Leden', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))),
        Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl), child: Center(child: Text('Eerst opslaan, daarna leden uitnodigen', style: TextStyle(color: AppColors.grey, fontSize: 13)))),
      ])),
    );
  }
}
