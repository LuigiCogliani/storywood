import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/theme_data.dart';
import '../widgets/home_button.dart';
import '../widgets/app_bar_title_tile.dart';
import '../models/playlist_class.dart';
import '../providers/playlist_provider.dart';
import '../providers/tips_list_provider_riverpod.dart';
import '../providers/users_provider_riverpod.dart';
import '../providers/new_tip_provider.dart';
import '../widgets/content_not_available_alert_dialog.dart';
import '../widgets/adaptive_circular_loading.dart';
import '../widgets/new_tip_screen/comment_new_tip_form.dart';
import '../widgets/playlists_overview_screen/playlists_overview_no_playlists.dart';

//support widgets to build playlist lists with checkmarks
class CupertinoPlaylistSwitch extends ConsumerStatefulWidget {
  const CupertinoPlaylistSwitch({required this.playlistItem, super.key});
  final Playlist playlistItem;

  @override
  ConsumerState<CupertinoPlaylistSwitch> createState() =>
      _CupertinoPlaylistSwitchState();
}

class _CupertinoPlaylistSwitchState
    extends ConsumerState<CupertinoPlaylistSwitch> {
  bool _currentValue = false;

  @override
  Widget build(BuildContext context) {
    return Switch.adaptive(
      // This bool value toggles the switch.
      value: _currentValue,
      activeColor: constTipMenuScreenPlaylistCupertinoActiveSwitch,
      inactiveTrackColor: constTipMenuScreenPlaylistCupertinoInactiveSwitch,
      onChanged: (bool newValue) {
        ref.read(playlistNewTipProvider.notifier).updateListOfSelectedPlaylists(
              checkboxState: newValue,
              playlistId: widget.playlistItem.id,
            );
        setState(() {
          _currentValue = newValue;
        });
      },
    );
  }
}

class CupertinoPlaylistCheckboxTile extends StatelessWidget {
  const CupertinoPlaylistCheckboxTile({required this.playlistItem, super.key});
  final Playlist playlistItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      //  color: Colors.transparent,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          playlistItem.name,
          style: constBodyLargeLight,
          overflow: TextOverflow.ellipsis,
        ),
        CupertinoPlaylistSwitch(
          playlistItem: playlistItem,
        ),
      ]),
    );
  }
}

class MaterialPlaylistCheckboxTile extends ConsumerStatefulWidget {
  const MaterialPlaylistCheckboxTile({required this.playlistItem, super.key});
  final Playlist playlistItem;

  @override
  ConsumerState<MaterialPlaylistCheckboxTile> createState() =>
      _MaterialPlaylistCheckboxTileState();
}

class _MaterialPlaylistCheckboxTileState
    extends ConsumerState<MaterialPlaylistCheckboxTile> {
  // initialise the status of the playlist
  bool _checkPlaylist = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return CheckboxListTile(
      side: BorderSide(
        // color of the border of the checkbox
        color: constFilterScreenCheckboxBorder,
        width: screenHeight * 0.003,
      ),
      contentPadding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.045, vertical: 0),
      // color of the tick
      checkColor: constFilterScreenCheckboxMarkWhite,
      // fill color of the checkbox when the checkbox is checked
      activeColor: Colors.black,
      value: _checkPlaylist,
      onChanged: (bool? newValue) {
        ref.read(playlistNewTipProvider.notifier).updateListOfSelectedPlaylists(
              checkboxState: newValue!,
              playlistId: widget.playlistItem.id,
            );
        setState(() {
          _checkPlaylist = newValue;
        });
      },
      tileColor: constElevatedButtonBackgroundGrey,
      title: Text(
        widget.playlistItem.name,
        style: constBodyLargeLight,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class CupertinoPlaylistActions extends ConsumerStatefulWidget {
  const CupertinoPlaylistActions({
    super.key,
    required this.screenHeight,
  });

  final double screenHeight;

  @override
  ConsumerState<CupertinoPlaylistActions> createState() =>
      _CupertinoPlaylistActionsState();
}

class _CupertinoPlaylistActionsState
    extends ConsumerState<CupertinoPlaylistActions> {
  //Define future variable to be used for Future Builder
  var _isInit = true;
  List playlistList = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      playlistList = ref.watch(playlistProvider);
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final playlistList = ref.watch(playlistProvider);
    //sort playlists alphabetically by name
    playlistList
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    double height = playlistList.length * 100 > widget.screenHeight * 0.8
        ? widget.screenHeight * 0.8
        : playlistList.length * 90;
    return Container(
      // color: constElevatedButtonBackgroundGrey,
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: playlistList.length,
        itemBuilder: (BuildContext context, int index) {
          final Playlist playlistItem = playlistList[index];

          return CupertinoActionSheetAction(
            onPressed: () {},
            child: CupertinoPlaylistCheckboxTile(
              playlistItem: playlistItem,
            ),
          );
        },
      ),
    );
  }
}

class MaterialPlaylistsList extends ConsumerWidget {
  const MaterialPlaylistsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistList = ref.watch(playlistProvider);
    //sort playlists alphabetically by name
    playlistList
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return ListView.builder(
      itemCount: playlistList.length,
      itemBuilder: (BuildContext context, int index) {
        final Playlist playlistItem = playlistList[index];

        return MaterialPlaylistCheckboxTile(
          playlistItem: playlistItem,
        );
      },
    );
  }
}

///add new tip and assign it to playlist function
void addNewTipAndAssignToPlaylist({
  required String title,
  required WidgetRef ref,
  required BuildContext context,
  required String overview,
  required String imageUrl,
  required String contentType,
  required Map<dynamic, dynamic> contentInfo,
  required String contentId,
  required String storywoodContentId,
}) async {
  final List<String> playlistIds = ref.read(playlistNewTipProvider);

  // if (contentType == constContentTypePodcast) {
  //   overview = ref.read(contentOverviewNewTipProvider);
  // }
  final String comment = ref.read(commentNewTipProvider) == ''
      ? '${ConstNewTipScreen.commentOverwriteStartingWord}$overview'
      : ref.read(commentNewTipProvider);

  String tipId = await ref.read(tipListProvider.notifier).addNewTip(
      storywoodContentId: storywoodContentId,
      txTitle: title,
      comment: comment,
      sentTo: [ref.watch(userInfoProvider)!.userId.toString()],
      visibleTo: [ref.watch(userInfoProvider)!.userId.toString()],
      tipType: ConstNewTipScreen.tipTypeRecommendation,
      contentType: contentType,
      imageUrl: imageUrl,
      contentId: contentId,
      info: contentInfo,
      playlistIds:
          playlistIds, //had to add playlists here otherwise they were overwriting each other in the loop below
      tipPrivacy: constTipPrivacySelfTip,
      ref: ref);

  for (var playlistId in playlistIds) {
    ref.read(playlistProvider.notifier).updatePlaylistInFirebase(
        playlistId: playlistId,
        tipId: tipId,
        checkboxState: true,
        tipImageUrl: imageUrl,
        ref: ref,
        removeTipSinglePlaylistProvider: false);
  }
  resetProviders(ref);
}

///dialog alert for if no playlist was selected
class NoPlaylistSelectedAlert extends StatelessWidget {
  const NoPlaylistSelectedAlert({super.key});
  final title = ConstStringNewTipPlaylistScreen.noPlaylistSelectedAlertTitle;
  final message =
      ConstStringNewTipPlaylistScreen.noPlaylistSelectedAlertMessage;
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: const Text(ConstStringAlertDialog.closeButton),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          )
        : AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(ConstStringAlertDialog.closeButton))
            ],
          );
  }
}

/// new tip playlist screen body
Widget _body({
  required title,
  required screenHeight,
  required screenWidth,
  required ref,
  required context,
  required overview,
  required imageUrl,
  required contentType,
  required contentInfo,
  required contentId,
  required String storywoodContentId,
}) {
  final String contentTypeString = contentType;
  final IconData contentTypeIcon = constContentIcons[contentTypeString]!;
  final List<String> selectedPlaylistIds = ref.watch(playlistNewTipProvider);
  final List<Playlist> availablePlaylists = ref.watch(playlistProvider);

  return SafeArea(
    child: Stack(children: [
      // stack the poster in the BG
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),

      // overlay the poster in the BG with a fading gradient
      Container(
        foregroundDecoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              constContentScreenGradient1,
              constContentScreenGradient2,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.1, 0.6],
          ),
        ),
      ),
      // the actual body
      SingleChildScrollView(
        reverse: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
                leading: Icon(
                  contentTypeIcon,
                  color: constIconColorLight,
                  size: screenHeight * 0.04,
                ),
                title: const Text(
                  ConstStringNewTipPlaylistScreen.subtitle,
                  style: constTitleMediumLightBold,
                  textAlign: TextAlign.left,
                )),
            SizedBox(
              height: screenHeight * 0.45,
              child: availablePlaylists.isEmpty
                  ? const SingleChildScrollView(
                      child: PlaylistOverviewNoPlaylistsMessage())
                  : Platform.isIOS
                      ? CupertinoPlaylistActions(screenHeight: screenHeight)
                      : const MaterialPlaylistsList(),
            ),
            // the label for the "comment" field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
              child: const Text(
                ConstNewTipScreen.commentLabel,
                style: constBodyLargeLight,
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(
                height: screenHeight * 0.2, child: const CommentNewTipForm()),
            // share button
            Container(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.025, 0,
                  screenWidth * 0.025, screenHeight * 0.01),
              width: double.infinity,
              child: Platform.isIOS
                  ? CupertinoButton(
                      color: constElevatedButtonBackgroundLight,
                      onPressed: () {
                        if (selectedPlaylistIds.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return const NoPlaylistSelectedAlert();
                              });
                        } else {
                          addNewTipAndAssignToPlaylist(
                              title: title,
                              ref: ref,
                              context: context,
                              overview: overview,
                              imageUrl: imageUrl,
                              contentType: contentType,
                              contentInfo: contentInfo,
                              contentId: contentId,
                              storywoodContentId: storywoodContentId);
                          goToHomeScreen(context, ref);
                        }
                      },
                      child: const Text(
                        ConstStringNewTipPlaylistScreen.saveButtonText,
                        style: constCupertinoElevatedButtonDarkText,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        if (selectedPlaylistIds.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (ctx) {
                                return const NoPlaylistSelectedAlert();
                              });
                        } else {
                          addNewTipAndAssignToPlaylist(
                              title: title,
                              ref: ref,
                              context: context,
                              overview: overview,
                              imageUrl: imageUrl,
                              contentType: contentType,
                              contentInfo: contentInfo,
                              contentId: contentId,
                              storywoodContentId: storywoodContentId);
                          goToHomeScreen(context, ref);
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              constElevatedButtonBackgroundLight)),
                      child: const Text(
                        ConstStringNewTipPlaylistScreen.saveButtonText,
                        style: constMaterialElevatedButtonDarkText,
                      ),
                    ),
            )
          ],
        ),
      )
    ]),
  );
}

class NewTipSaveScreen extends ConsumerWidget {
  const NewTipSaveScreen({super.key});
  static const routeName = '/newtip-playlists-screen';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modalRouteArguments =
        ModalRoute.of(context)!.settings.arguments as List;

    final year = modalRouteArguments[1];
    final imageUrl = modalRouteArguments[2];
    final String overview = modalRouteArguments[3];
    final String contentType = modalRouteArguments[4];
    final Map contentInfo = modalRouteArguments[5];
    final String contentId = modalRouteArguments[6];
    final String title = modalRouteArguments[7];
    final String storywoodContentId = modalRouteArguments[8];
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final String? userId = ref.read(userInfoProvider)?.userId;

    return FutureBuilder(
        future: ref
            .read(playlistProvider.notifier)
            .fetchPlaylistsFromFirebase(userId),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return const ContentNotAvailableAlertDialog();
          } else if (snapshot.hasData) {
            return Platform.isIOS
                ? CupertinoPageScaffold(
                    backgroundColor: constScaffoldBackground,
                    navigationBar: CupertinoNavigationBar(
                      trailing: HomeButton(ref: ref),
                      middle: AppBarTitleTile(
                        title: title,
                        subtitle: year,
                        titleMinFontSize: 14,
                        subtitleFontSize: 14,
                        isClickable: false,
                        route: '',
                      ),
                      backgroundColor: constTopBarBackgroundColor,
                    ),
                    child: Material(
                        child: Container(
                      color: constScaffoldBackground,
                      child: _body(
                          title: title,
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          ref: ref,
                          context: context,
                          overview: overview,
                          imageUrl: imageUrl,
                          contentType: contentType,
                          contentInfo: contentInfo,
                          contentId: contentId,
                          storywoodContentId: storywoodContentId),
                    )),
                  )
                : Scaffold(
                    backgroundColor: constScaffoldBackground,
                    appBar: AppBar(
                        centerTitle: true,
                        actions: [HomeButton(ref: ref)],
                        title: AppBarTitleTile(
                          title: title,
                          subtitle: year,
                          titleMinFontSize: 14,
                          subtitleFontSize: 14,
                          isClickable: false,
                          route: '',
                        )),
                    body: _body(
                        title: title,
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        ref: ref,
                        context: context,
                        overview: overview,
                        imageUrl: imageUrl,
                        contentType: contentType,
                        contentInfo: contentInfo,
                        contentId: contentId,
                        storywoodContentId: storywoodContentId),
                  );
          } else {
            return adaptiveCircularLoading(
                color: constCircularProgressIndicatorWhite);
          }
        });
  }
}
