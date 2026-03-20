import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../bloc/news_bloc.dart';
import '../widgets/news_post_card.dart';

class NewsView extends StatelessWidget {
  const NewsView({
    super.key,
    required this.clubId,
    required this.teamIds,
    required this.canPost,
  });

  final String clubId;
  final List<String> teamIds;
  final bool canPost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nieuws')),
      body: BlocConsumer<NewsBloc, NewsState>(
        listenWhen: (prev, curr) =>
            prev.createStatus != curr.createStatus,
        listener: (context, state) {
          if (state.createStatus == NewsCreateStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bericht geplaatst!')),
            );
          } else if (state.createStatus == NewsCreateStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Er ging iets mis.')),
            );
          }
        },
        builder: (context, state) {
          return switch (state.status) {
            NewsStatus.initial ||
            NewsStatus.loading =>
              const LoadingIndicator(),
            NewsStatus.failure => ErrorView(
                message: 'Kon nieuws niet laden.',
                onRetry: () => context.read<NewsBloc>().add(
                      NewsLoadRequested(clubId: clubId, teamIds: teamIds),
                    ),
              ),
            NewsStatus.loaded => state.posts.isEmpty
                ? _EmptyState()
                : _NewsList(
                    posts: state.posts,
                    onDelete: (id) => context
                        .read<NewsBloc>()
                        .add(NewsDeleteRequested(postId: id)),
                  ),
          };
        },
      ),
      floatingActionButton: canPost
          ? FloatingActionButton(
              onPressed: () => context.goNamed(
                RouteNames.newsCreate,
                queryParameters: {'clubId': clubId},
              ),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.newspaper,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Geen nieuws',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Er zijn nog geen berichten geplaatst.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsList extends StatelessWidget {
  const _NewsList({required this.posts, required this.onDelete});
  final List posts;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: posts.length,
      itemBuilder: (context, index) => NewsPostCard(
        post: posts[index],
        onDelete: () => onDelete(posts[index].id),
      ),
    );
  }
}
