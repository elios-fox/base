import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/models/news_post.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../services/news_service.dart';
import '../bloc/news_bloc.dart';

class NewsCreatePage extends StatefulWidget {
  const NewsCreatePage({
    super.key,
    required this.clubId,
    this.teamId,
  });

  final String clubId;
  final String? teamId;

  @override
  State<NewsCreatePage> createState() => _NewsCreatePageState();
}

class _NewsCreatePageState extends State<NewsCreatePage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isClubWide = true;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsBloc(newsService: locate<NewsService>()),
      child: BlocConsumer<NewsBloc, NewsState>(
        listenWhen: (prev, curr) =>
            prev.createStatus != curr.createStatus,
        listener: (context, state) {
          if (state.createStatus == NewsCreateStatus.success) {
            context.pop();
          } else if (state.createStatus == NewsCreateStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Er ging iets mis.'),
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting =
              state.createStatus == NewsCreateStatus.submitting;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Nieuw bericht'),
              actions: [
                FilledButton(
                  onPressed: isSubmitting ? null : () => _submit(context),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Plaatsen'),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (widget.teamId != null)
                  SwitchListTile(
                    title: const Text('Clubbreed bericht'),
                    subtitle: const Text(
                      'Zichtbaar voor alle leden van de club',
                    ),
                    value: _isClubWide,
                    onChanged: (v) => setState(() => _isClubWide = v),
                  ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titel',
                    hintText: 'Bijv. Trainingswijziging',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Bericht',
                    hintText: 'Schrijf je bericht...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext context) {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul titel en bericht in.')),
      );
      return;
    }

    final post = NewsPost(
      id: '',
      authorUid: SupabaseClientWrapper.instance.userId,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      clubId: _isClubWide ? widget.clubId : null,
      teamId: !_isClubWide ? widget.teamId : null,
    );

    context.read<NewsBloc>().add(NewsCreateRequested(post: post));
  }
}
