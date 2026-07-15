import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../data/theme_data.dart';
import '../providers/users_provider_riverpod.dart';
import '../providers/in_app_tour_storage.dart';
import '../providers/new_tip_provider.dart';
import '../widgets/home_button.dart';
import '../widgets/app_bar_title_tile.dart';
import '../widgets/new_tip_screen/tag_friends.dart';
import '../widgets/new_tip_screen/comment_new_tip_form.dart';
import '../widgets/new_tip_screen/share_tip.dart';
import '../widgets/new_tip_screen/tip_privacy_status.dart';
import '../widgets/new_tip_screen/in_app_tour_new_tip_share.dart';
import '../widgets/choose_thumbs_icon.dart';

/// new tip screen body
Widget _body(
    {required isPoop,
    required title,
    required screenHeight,
    required screenWidth,
    required WidgetRef ref,
    required context,
    required overview,
    required imageUrl,
    required contentType,
    required contentInfo,
    required contentId,
    required storywoodContentId,
    required GlobalKey tipPrivacyStatusKey}) {
  final String contentTypeString = contentType;
  final IconData contentTypeIcon = constContentIcons[contentTypeString]!;

  final String tipTypeString = isPoop
      ? ConstNewTipScreen.tipTypeCondemnation
      : ConstNewTipScreen.tipTypeRecommendation;

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
      Platform.isIOS
          ? CupertinoBody(
              contentTypeIcon: contentTypeIcon,
              contentTypeString: contentTypeString,
              tipTypeString: tipTypeString,
              ref: ref,
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              tipPrivacyStatusKey: tipPrivacyStatusKey,
              contentId: contentId,
              contentInfo: contentInfo,
              contentType: contentType,
              imageUrl: imageUrl,
              overview: overview,
              storywoodContentId: storywoodContentId,
              title: title,
            )
          : MaterialBody(
              contentTypeIcon: contentTypeIcon,
              contentTypeString: contentTypeString,
              tipTypeString: tipTypeString,
              ref: ref,
              screenHeight: screenHeight,
              screenWidth: screenWidth,
              tipPrivacyStatusKey: tipPrivacyStatusKey,
              contentId: contentId,
              contentInfo: contentInfo,
              contentType: contentType,
              imageUrl: imageUrl,
              overview: overview,
              storywoodContentId: storywoodContentId,
              title: title,
            )
    ]),
  );
}

class CupertinoBody extends StatelessWidget {
  const CupertinoBody(
      {super.key,
      required this.contentTypeIcon,
      required this.contentTypeString,
      required this.tipTypeString,
      required this.screenHeight,
      required this.tipPrivacyStatusKey,
      required this.screenWidth,
      required this.ref,
      required this.contentId,
      required this.contentInfo,
      required this.contentType,
      required this.imageUrl,
      required this.overview,
      required this.storywoodContentId,
      required this.title});

  final IconData contentTypeIcon;
  final String contentTypeString;
  final String tipTypeString;
  final double screenHeight;
  final double screenWidth;
  final Key tipPrivacyStatusKey;
  final WidgetRef ref;
  final String contentId;
  final Map<dynamic, dynamic> contentInfo;
  final String contentType;
  final String imageUrl;
  final String overview;
  final String title;
  final String storywoodContentId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /**List tile that will recap what content type and tip type we are sharing,
           * with both text and icon+emoji
           */
        ListTile(
            leading: Icon(
              contentTypeIcon,
              color: constIconColorLight,
              size: screenHeight * 0.04,
            ),
            title: Text(
              '$contentTypeString ${tipTypeString.toLowerCase()}',
              style: constBodyMediumLight,
              textAlign: TextAlign.center,
            )),
        ListTile(
          key: tipPrivacyStatusKey,
          leading: Tooltip(
              message:
                  'Adjust post privacy by clicking the dropdown to the right',
              child: ChoosePrivacyIcon(
                iconSize: screenHeight * 0.04,
                tipPrivacy: ref.watch(tipPrivacyStatusNewTipProvider),
              )),
          title: const TipPrivacyStatusDropdown(),
        ),
        if (ref.watch(tipPrivacyStatusNewTipProvider) ==
            constTipPrivacyTaggedFriends)
          TagFriendsTile(
              //  key: tipPrivacyStatusKey,
              mediaQueryHeight: screenHeight,
              isFilterScreen: false,
              tipId: '',
              futureFunction: ref.watch(friendsFutureProvider)),
        // the label for the "comment" field
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
          child: const Text(
            ConstNewTipScreen.commentLabel,
            style: constBodyLargeLight,
            textAlign: TextAlign.left,
          ),
        ),
        const Expanded(child: CommentNewTipForm()),

        // share button
        Container(
          padding: EdgeInsets.fromLTRB(
              screenWidth * 0.025, 0, screenWidth * 0.025, screenHeight * 0.01),
          width: double.infinity,
          child: Platform.isIOS
              ? CupertinoButton(
                  color: constElevatedButtonBackgroundLight,
                  onPressed: () {
                    shareTipAndAlerts(
                        tipType: tipTypeString,
                        ref: ref,
                        context: context,
                        shareWithFriends: true,
                        contentId: contentId,
                        contentInfo: contentInfo,
                        contentType: contentType,
                        imageUrl: imageUrl,
                        overview: overview,
                        title: title,
                        storywoodContentId: storywoodContentId);
                  },
                  child: const Text(
                    ConstNewTipScreen.shareButton,
                    style: constCupertinoElevatedButtonDarkText,
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    shareTipAndAlerts(
                        tipType: tipTypeString,
                        ref: ref,
                        context: context,
                        shareWithFriends: true,
                        contentId: contentId,
                        contentInfo: contentInfo,
                        contentType: contentType,
                        imageUrl: imageUrl,
                        overview: overview,
                        title: title,
                        storywoodContentId: storywoodContentId);
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          constElevatedButtonBackgroundLight)),
                  child: const Text(
                    ConstNewTipScreen.shareButton,
                    style: constMaterialElevatedButtonDarkText,
                  ),
                ),
        )
      ],
    );
  }
}

class MaterialBody extends StatelessWidget {
  const MaterialBody(
      {super.key,
      required this.contentTypeIcon,
      required this.contentTypeString,
      required this.tipTypeString,
      required this.screenHeight,
      required this.tipPrivacyStatusKey,
      required this.screenWidth,
      required this.ref,
      required this.contentId,
      required this.contentInfo,
      required this.contentType,
      required this.imageUrl,
      required this.overview,
      required this.storywoodContentId,
      required this.title});

  final IconData contentTypeIcon;
  final String contentTypeString;
  final String tipTypeString;
  final double screenHeight;
  final double screenWidth;
  final Key tipPrivacyStatusKey;
  final WidgetRef ref;
  final String contentId;
  final Map<dynamic, dynamic> contentInfo;
  final String contentType;
  final String imageUrl;
  final String overview;
  final String title;
  final String storywoodContentId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /**List tile that will recap what content type and tip type we are sharing,
           * with both text and icon+emoji
           */
          ListTile(
              leading: Icon(
                contentTypeIcon,
                color: constIconColorLight,
                size: screenHeight * 0.04,
              ),
              title: Text(
                '$contentTypeString ${tipTypeString.toLowerCase()}',
                style: constBodyMediumLight,
                textAlign: TextAlign.center,
              )),
          ListTile(
            key: tipPrivacyStatusKey,
            leading: Tooltip(
                message:
                    'Adjust post privacy by clicking the dropdown to the right',
                child: ChoosePrivacyIcon(
                  iconSize: screenHeight * 0.04,
                  tipPrivacy: ref.watch(tipPrivacyStatusNewTipProvider),
                )),
            title: const TipPrivacyStatusDropdown(),
          ),
          if (ref.watch(tipPrivacyStatusNewTipProvider) ==
              constTipPrivacyTaggedFriends)
            TagFriendsTile(
                //  key: tipPrivacyStatusKey,
                mediaQueryHeight: screenHeight,
                isFilterScreen: false,
                tipId: '',
                futureFunction: ref.watch(friendsFutureProvider)),
          // the label for the "comment" field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025),
            child: const Text(
              ConstNewTipScreen.commentLabel,
              style: constBodyLargeLight,
              textAlign: TextAlign.left,
            ),
          ),
          Platform.isIOS
              ? const CommentNewTipForm()
              : SizedBox(
                  height: (screenHeight * 0.8) - 250,
                  child: const CommentNewTipForm()),
          // share button
          Container(
            padding: EdgeInsets.fromLTRB(screenWidth * 0.025, 0,
                screenWidth * 0.025, screenHeight * 0.01),
            width: double.infinity,
            child: Platform.isIOS
                ? CupertinoButton(
                    color: constElevatedButtonBackgroundLight,
                    onPressed: () {
                      shareTipAndAlerts(
                          tipType: tipTypeString,
                          ref: ref,
                          context: context,
                          shareWithFriends: true,
                          contentId: contentId,
                          contentInfo: contentInfo,
                          contentType: contentType,
                          imageUrl: imageUrl,
                          overview: overview,
                          title: title,
                          storywoodContentId: storywoodContentId);
                    },
                    child: const Text(
                      ConstNewTipScreen.shareButton,
                      style: constCupertinoElevatedButtonDarkText,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      shareTipAndAlerts(
                          tipType: tipTypeString,
                          ref: ref,
                          context: context,
                          shareWithFriends: true,
                          contentId: contentId,
                          contentInfo: contentInfo,
                          contentType: contentType,
                          imageUrl: imageUrl,
                          overview: overview,
                          title: title,
                          storywoodContentId: storywoodContentId);
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            constElevatedButtonBackgroundLight)),
                    child: const Text(
                      ConstNewTipScreen.shareButton,
                      style: constMaterialElevatedButtonDarkText,
                    ),
                  ),
          )
        ],
      ),
    );
  }
}

class NewTipShareScreen extends ConsumerStatefulWidget {
  const NewTipShareScreen({super.key});
  static const routeName = '/newtip-screen';

  @override
  ConsumerState<NewTipShareScreen> createState() => _NewTipShareScreenState();
}

class _NewTipShareScreenState extends ConsumerState<NewTipShareScreen> {
  //variables set up for in-app tour
  final tipPrivacyStatusKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  //bool isSaved = false; //controls the visibility of the in-app tutorial

  ///Function to call new tip share screen in-app tutorial
  void initInAppNewTipShareTour() {
    tutorialCoachMark = TutorialCoachMark(
      targets: newTipShareScreenTargets(
        tipPrivacyStatusKey: tipPrivacyStatusKey,
      ),
      colorShadow: Colors.black,
      paddingFocus: 10,
      hideSkip: true,
      opacityShadow: 0.9,
      onFinish: () {
        //save the flag that tutorial has been seen
        SaveInAppTour().saveNewTipShareScreenTourStatus();
        //print('Completed');
      },
    );
  }

  void showInAppNewTipShareTour() {
    Future.delayed(const Duration(seconds: 1), () {
      SaveInAppTour().getNewTipShareScreenTourStatus().then((value) {
        //only show tutorial if it has not been seen yet on this phone
        if (value == false) {
          tutorialCoachMark.show(context: context);
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    //initialise tutorial function
    initInAppNewTipShareTour();

    //show in-app tutorial
    showInAppNewTipShareTour();
  }

  @override
  Widget build(BuildContext context) {
    final modalRouteArguments =
        ModalRoute.of(context)!.settings.arguments as List;
    final bool isPoop = modalRouteArguments[0];
    final year = modalRouteArguments[1];
    final imagePath = modalRouteArguments[2];
    final String overview = modalRouteArguments[3];
    final String contentType = modalRouteArguments[4];
    final Map contentInfo = modalRouteArguments[5];
    final String contentId = modalRouteArguments[6];
    final String title = modalRouteArguments[7];
    final String storywoodContentId = modalRouteArguments[8];
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    /// empty providers
    void resetShareTipProviders() {
      // empty the list of tagged friends
      ref.read(tagFriendsProvider.notifier).resetProvider();

      // reset the comment to empty string
      ref.read(commentNewTipProvider.notifier).assignComment('');

      // reset the tip privacy status to default value
      ref
          .read(tipPrivacyStatusNewTipProvider.notifier)
          .assignPrivacyStatus(constTipPrivacyAllFriends);
    }

    return Platform.isIOS
        ? CupertinoPageScaffold(
            backgroundColor: constScaffoldBackground,
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoNavigationBarBackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  resetShareTipProviders();
                },
              ),
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
                        isPoop: isPoop,
                        title: title,
                        imageUrl: imagePath,
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        ref: ref,
                        context: context,
                        contentId: contentId,
                        contentInfo: contentInfo,
                        contentType: contentType,
                        overview: overview,
                        storywoodContentId: storywoodContentId,
                        tipPrivacyStatusKey: tipPrivacyStatusKey))),
          )
        : Scaffold(
            backgroundColor: constScaffoldBackground,
            appBar: AppBar(
                leading: BackButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetShareTipProviders();
                  },
                ),
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
                isPoop: isPoop,
                title: title,
                imageUrl: imagePath,
                screenHeight: screenHeight,
                screenWidth: screenWidth,
                ref: ref,
                context: context,
                contentId: contentId,
                contentInfo: contentInfo,
                contentType: contentType,
                overview: overview,
                storywoodContentId: storywoodContentId,
                tipPrivacyStatusKey: tipPrivacyStatusKey),
          );
  }
}
