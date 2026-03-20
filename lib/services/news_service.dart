import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/news_post.dart';
import '../core/supabase/supabase_client.dart';

abstract class NewsService {
  Stream<List<NewsPost>> getNewsFeed(String clubId, List<String> teamIds);
  Future<NewsPost> createPost(NewsPost post);
  Future<void> updatePost(NewsPost post);
  Future<void> deletePost(String id);
}

class SupaNewsService implements NewsService {
  SupaNewsService({SupabaseClientWrapper? client})
      : _client = client ?? SupabaseClientWrapper.instance;

  final SupabaseClientWrapper _client;

  SupabaseClient get _supabase => _client.client;

  @override
  Stream<List<NewsPost>> getNewsFeed(String clubId, List<String> teamIds) {
    final controller = StreamController<List<NewsPost>>.broadcast();

    // No club or teams → nothing to show
    if (clubId.isEmpty && teamIds.isEmpty) {
      controller.add([]);
      return controller.stream;
    }

    Future<void> fetch() async {
      try {
        // Build filter based on available parameters
        final filters = <String>[];
        if (clubId.isNotEmpty) filters.add('club_id.eq.$clubId');
        if (teamIds.isNotEmpty) {
          filters.add('team_id.in.(${teamIds.join(",")})');
        }

        final data = await _supabase
            .from('news_posts')
            .select()
            .or(filters.join(','))
            .order('created_at', ascending: false);

        if (!controller.isClosed) {
          controller.add(data.map(_postFromMap).toList());
        }
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    fetch();

    final channel = _supabase
        .channel('public:news_posts:$clubId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'news_posts',
          callback: (_) => fetch(),
        )
        .subscribe();

    controller.onCancel = () {
      _supabase.removeChannel(channel);
    };

    return controller.stream;
  }

  @override
  Future<NewsPost> createPost(NewsPost post) async {
    final data = await _supabase.from('news_posts').insert({
      'club_id': post.clubId,
      'team_id': post.teamId,
      'author_uid': post.authorUid,
      'title': post.title,
      'body': post.body,
      'image_url': post.imageUrl,
    }).select().single();
    return _postFromMap(data);
  }

  @override
  Future<void> updatePost(NewsPost post) async {
    await _supabase.from('news_posts').update({
      'title': post.title,
      'body': post.body,
      'image_url': post.imageUrl,
    }).eq('id', post.id);
  }

  @override
  Future<void> deletePost(String id) async {
    await _supabase.from('news_posts').delete().eq('id', id);
  }

  NewsPost _postFromMap(Map<String, dynamic> map) {
    return NewsPost(
      id: map['id'] as String,
      clubId: map['club_id'] as String?,
      teamId: map['team_id'] as String?,
      authorUid: map['author_uid'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      imageUrl: map['image_url'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
      authorName: map['author_name'] as String?,
    );
  }
}
