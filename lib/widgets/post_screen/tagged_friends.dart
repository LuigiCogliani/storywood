import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';

import '../../data/theme_data.dart';
import '../../providers/users_provider_riverpod.dart';

class TaggedFriendsOutput extends ConsumerWidget {
  const TaggedFriendsOutput(
      {super.key, required this.sentTo, required this.sentBy});
  final List<String> sentTo;
  final String sentBy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List sentToUsernamesList = [];
    for (final user in sentTo) {
      sentToUsernamesList
          .add(ref.read(usernameProvider)[user]['username'].toString());
    }
    final sentToUsernamesDisplayed = sentToUsernamesList.join(', ');
    return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
        child: ReadMoreText(
          'Tagged friends: $sentToUsernamesDisplayed',
          style: constChatLight,
          trimLines: 1,
          colorClickableText: constClickableDarkGrey,
          trimMode: TrimMode.Line,
          trimCollapsedText: ConstStringContentScreen.readMoreEllipsisMore,
          trimExpandedText: ConstStringContentScreen.readMoreTextLess,
        ));
  }
}
