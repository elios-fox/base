import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../services/news_service.dart';
import '../bloc/news_bloc.dart';
import 'news_view.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({
    super.key,
    required this.clubId,
    required this.teamIds,
    this.canPost = false,
  });

  final String clubId;
  final List<String> teamIds;
  final bool canPost;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsBloc(newsService: locate<NewsService>())
        ..add(NewsLoadRequested(clubId: clubId, teamIds: teamIds)),
      child: NewsView(
        clubId: clubId,
        teamIds: teamIds,
        canPost: canPost,
      ),
    );
  }
}
