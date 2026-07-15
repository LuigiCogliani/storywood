import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import '../../screens/post_screen.dart';
import '../../screens/friends_screen.dart';
import '../../screens/single_playlist_screen.dart';
import '../../models/notification_class.dart';
import '../../providers/navigation_bar_provider.dart';
import '../../providers/users_provider_riverpod.dart';
import '../../data/theme_data.dart';

class NotificationItem extends riverpod.ConsumerWidget {
  const NotificationItem({super.key, required this.notificationObject});
  final NotificationObject notificationObject;

  ///Function redirects to Tip screen
  void _selectTipScreen({required BuildContext ctx, required String tipId}) {
    Navigator.of(ctx).pushNamed(
      PostScreen.routeName,
      arguments: [tipId, null],
    );
  }

  ///Function redirects to Collection screen
  void _selectPlaylistScreen(
      {required BuildContext ctx, required String playlistId}) {
    Navigator.of(ctx).pushNamed(
      SinglePlaylistScreen.routeName,
      arguments: [playlistId, null, true],
    );
  }

  ///Function redirects to Friends screen
  void _selectFriendsScreenYourFriendsTab(
      BuildContext ctx, riverpod.WidgetRef ref) {
    ref.invalidate(friendsFutureProvider);
    ref
        .read(bottomNavigationBarIndexProvider.notifier)
        .updatebottomNavigationBarIndexNotifier(
            constFriendsScreenBottomNavigationBarIndex);
    Navigator.of(ctx).pushNamed(
      FriendsScreen.routeNameYourFriendsTab,
    );
  }

  void _selectFriendsScreenRequestsTab(
      BuildContext ctx, riverpod.WidgetRef ref) {
    ref.invalidate(friendRequestsFutureProvider);
    ref
        .read(bottomNavigationBarIndexProvider.notifier)
        .updatebottomNavigationBarIndexNotifier(
            constFriendsScreenBottomNavigationBarIndex);
    Navigator.of(ctx).pushNamed(
      FriendsScreen.routeNameRequestsTab,
    );
  }

  Widget _buildNotificationMessage(
      double notificationMessageWidth,
      String sentByUsername,
      String typeSpecificText,
      String? displayedTimeString,
      BuildContext context) {
    return SizedBox(
      width: notificationMessageWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                sentByUsername,
                style: constTitleSmallLightBold,
                textAlign: TextAlign.left,
                overflow:
                    TextOverflow.ellipsis, //crops the text and adds three dots
                maxLines: 1,
              ),
              Expanded(
                child: Text(
                  typeSpecificText,
                  style: constLabelSmallLight,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow
                      .ellipsis, //crops the text and adds three dots
                  maxLines: 1,
                ),
              ),
            ],
          ),
          Text(
            '($displayedTimeString)',
            style: constBodySmallLight,
            textAlign: TextAlign.left,
            overflow:
                TextOverflow.ellipsis, //crops the text and adds three dots
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPoster(
      {required double notificationPosterWidth, required String imageUrl}) {
    return Container(
        width: notificationPosterWidth,
        margin: const EdgeInsets.all(3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        )));
  }

  /// Function to translate notification created date into time dependent notification message
  String? _translateNotificationTimeStamp(String inputTimeStamp) {
    var timestampAsUTC =
        DateFormat("yyyy-MM-dd HH:mm:ss").parse(inputTimeStamp, true);
    var timestampToLocal = timestampAsUTC.toLocal();
    var timestampConverted =
        inputTimeStamp == null ? null : DateUtils.dateOnly(timestampToLocal);

    var differenceInDaysFromNow = timestampConverted == null
        ? null
        : timestampConverted
                .difference(DateUtils.dateOnly(DateTime.now()))
                .inDays *
            (-1);

    var differenceInWeeksFromNow = differenceInDaysFromNow == null
        ? null
        : (differenceInDaysFromNow / 7).floor();

    var displayedTimeString = differenceInDaysFromNow == null
        ? null
        : differenceInDaysFromNow == 0
            ? 'today'
            : differenceInDaysFromNow == 1
                ? '1 day ago'
                : differenceInDaysFromNow < 7
                    ? '$differenceInDaysFromNow' ' days ago'
                    : differenceInWeeksFromNow == 1
                        ? '1 week ago'
                        : '$differenceInWeeksFromNow' ' weeks ago';

    return displayedTimeString;
  }

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);

    final notificationHeight =
        (mediaQuery.size.height - mediaQuery.padding.top) * 0.10;
    final notificationMessageWidth = mediaQuery.size.width * 0.75;
    final notificationPosterWidth = mediaQuery.size.width * 0.12;
    final notificationGapBetweenMessageAndPosterWidth =
        mediaQuery.size.width * 0.07;

    final String posterImageUrl = notificationObject.imageUrl;
    final String sentByUsername = notificationObject.sentByUsername;
    final String imageUrl = notificationObject.imageUrl;

    final NetworkImage storedImageFile = NetworkImage(imageUrl);
    final avatarRadius = mediaQuery.size.width * 0.07;

    final String typeSpecificText = notificationObject.notificationType ==
            constNotifTypeNewTip
        ? ConstStringNotificationsScreen.newTip
        : notificationObject.notificationType == constNotifTypeNewChatMessage
            ? ConstStringNotificationsScreen.newMessage
            : notificationObject.notificationType ==
                    constNotifTypeNewFriendRequestReceived
                ? ConstStringNotificationsScreen.newFriendRequestReceived
                : notificationObject.notificationType ==
                        constNotifTypeNewFriendRequestApproved
                    ? ConstStringNotificationsScreen.newFriendRequestApproved
                    : notificationObject.notificationType ==
                            constNotifTypeCollectionShared
                        ? ConstStringNotificationsScreen.newCollectionShared
                        : ConstStringNotificationsScreen.newVote;
    var displayedTimeString =
        _translateNotificationTimeStamp(notificationObject.timeStampCreated);

    return Column(
      children: [
        Container(
          height: 5, //defines gap size between notifications
          color: constTileBackground,
        ),
        InkWell(
          onTap: () {
            notificationObject.notificationType ==
                    constNotifTypeNewFriendRequestReceived
                ? _selectFriendsScreenRequestsTab(context, ref)
                : notificationObject.notificationType ==
                        constNotifTypeNewFriendRequestApproved
                    ? _selectFriendsScreenYourFriendsTab(context, ref)
                    : notificationObject.notificationType ==
                            constNotifTypeCollectionShared
                        ? _selectPlaylistScreen(
                            ctx: context, playlistId: notificationObject.tipId)
                        : _selectTipScreen(
                            ctx: context, tipId: notificationObject.tipId);
          },
          child: Container(
            color: constTileBackground,
            width: double.infinity,
            height: notificationHeight,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                _buildNotificationMessage(
                    notificationMessageWidth,
                    sentByUsername,
                    typeSpecificText,
                    displayedTimeString,
                    context),
                SizedBox(width: notificationGapBetweenMessageAndPosterWidth),
                notificationObject.notificationType ==
                            constNotifTypeNewFriendRequestReceived ||
                        notificationObject.notificationType ==
                            constNotifTypeNewFriendRequestApproved
                    ? CircleAvatar(
                        backgroundColor: constCircleAvatarBackgroundLight,
                        radius: avatarRadius,
                        foregroundImage: storedImageFile != null
                            ? storedImageFile as ImageProvider
                            : null,
                      )
                    : _buildNotificationPoster(
                        notificationPosterWidth: notificationPosterWidth,
                        imageUrl: posterImageUrl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
