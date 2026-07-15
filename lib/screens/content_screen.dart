import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import '../data/theme_data.dart';
import '../widgets/content_screen/movie_or_tv_screen.dart';
import '../widgets/content_screen/book_screen.dart';
import '../widgets/content_screen/podcast_screen.dart';

//TODO: Luigi to review

class ContentScreen extends riverpod.ConsumerWidget {
  const ContentScreen({super.key});
  static const routeName = '/content-screen';
  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final modalRouteArguments =
        ModalRoute.of(context)!.settings.arguments as List;
    final contentType = modalRouteArguments[0].toString();

    final String contentId = modalRouteArguments[1].toString();

    if (contentType == constContentTypeBook) {
      return bookContentScaffold(
          contentId: contentId, context: context, ref: ref);
    } else if (contentType == constContentTypePodcast) {
      final String podcastUrl = modalRouteArguments[2].toString();
      return podcastContentScaffold(
          contentId: contentId,
          context: context,
          ref: ref,
          podcastUrl: podcastUrl);
    } else {
      return movieOrTvseriesContentScaffold(
        context: context,
        contentId: contentId,
        contentType: contentType,
        ref: ref,
      );
    }
  }
}
