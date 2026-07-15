import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:readmore/readmore.dart';

import './strip_html.dart';

import '../android_ios_picker.dart';
import '../app_bar_title_tile.dart';
import '../home_button.dart';
import '../three_share_buttons.dart';
import '../content_not_available_alert_dialog.dart';
import '../adaptive_text_button.dart';

import '../../providers/api_provider_riverpod.dart';
import '../../data/theme_data.dart';

class PodcastBody extends StatelessWidget {
  const PodcastBody({
    super.key,
    required this.snapshotData,
  });

  final Map snapshotData;
  final double podcastInfoFontSize = 18;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = (MediaQuery.of(context).size.width);
    final String year = snapshotData['year'];

    final String overview = stripHtmlIfNeeded(snapshotData['overview']);

    final String contentId = snapshotData['contentId'];
    final String iTunesLink = snapshotData['iTunesUrl'];
    final String hosts = snapshotData['host'];
    final String genre = snapshotData['genre'];
    final String artworkUrl = snapshotData['posterPath'].toString();
    final String title = snapshotData['title'];

    /// we can be arriving at this point from old tips that don't have the storywood content ID
    final String storywoodContentId = snapshotData['storywoodContentId'];
    return Container(
      color: constScaffoldBackground,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ThreeShareButtons(
                  year: year,
                  overview: overview,
                  contentId: contentId,
                  contentInfo: const {},
                  imageUrl: artworkUrl,
                  contentType: constContentTypePodcast,
                  title: title,
                  storywoodContentId: storywoodContentId),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  width: screenWidth * 0.75,
                  height: screenWidth * 0.75,
                  child: Image.network(artworkUrl, fit: BoxFit.fitWidth)),
              Container(
                alignment: Alignment.centerLeft,
                color: constScaffoldBackground,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: AutoSizeText(
                  '${ConstStringContentScreen.podcastHost} $hosts',
                  style: constBodyMediumLight,
                  maxLines: 2,
                  minFontSize: podcastInfoFontSize,
                  maxFontSize: podcastInfoFontSize,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                color: constScaffoldBackground,
                child: AutoSizeText(
                  '${ConstStringContentScreen.podcastGenre} $genre',
                  style: constBodyMediumLight,
                  maxLines: 2,
                  minFontSize: podcastInfoFontSize,
                  maxFontSize: podcastInfoFontSize,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              Container(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                color: constScaffoldBackground,
                child: ReadMoreText(
                  '${ConstStringContentScreen.podcastOverview} $overview',
                  style: constBodyMediumLight,
                  trimLines: 8,
                  colorClickableText: constClickableText,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ConstStringContentScreen.readMoreTextMore,
                  trimExpandedText: ConstStringContentScreen.readMoreTextLess,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                alignment: Alignment.center,
                child: AdaptiveUrlTextButton(
                    urlLink: iTunesLink,
                    text: ConstStringContentScreen.podcastItunesButton),
              ),
/**this is the snippet to build the individual episodes, we will keep it for now
 * in case we decide to do something with this in the future
 */
              // SizedBox(
              //   width: screenWidth,
              //   height: screenHeight * 0.58,
              //   child: ListView.builder(
              //     itemCount: snapshot.data!.episodes?.length,
              //     itemBuilder: (BuildContext context, int index) {
              //       return Container(
              //           margin: const EdgeInsets.symmetric(vertical: 1),
              //           color: constScaffoldBackground,
              //           child: ListTile(
              //             isThreeLine: true,
              //             leading: Container(
              //                 width: screenWidth * 0.16,
              //                 decoration: BoxDecoration(
              //                     image: DecorationImage(
              //                   image: NetworkImage(artworkUrl.toString()),
              //                   fit: BoxFit.fitHeight,
              //                 ))),
              //             title: AutoSizeText(
              //               '${snapshot.data!.episodes?[index].episode}. ${snapshot.data!.episodes?[index].title}',
              //               maxLines: 2,
              //               minFontSize: 14,
              //               maxFontSize: 14,
              //               overflow: TextOverflow.ellipsis,
              //               style: constBodySmallLight,
              //             ),
              //             subtitle: AutoSizeText(
              //               '${snapshot.data!.episodes?[index].duration!.inMinutes}min - ${snapshot.data!.episodes?[index].description}',
              //               maxLines: 2,
              //               minFontSize: 12,
              //               maxFontSize: 12,
              //               overflow: TextOverflow.ellipsis,
              //               style: constBodySmallLight,
              //             ),
              //           ));
              //     },
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

/// create the content screen for podcast
Widget podcastContentScaffold(
    {required context, required contentId, required ref, required podcastUrl}) {
  return FutureBuilder<Map>(
      future: ref.read(contentInfoProvider.notifier).checkForContentInFirebase(
          contentType: constContentTypePodcast,
          contentId: contentId,
          podcastUrl: podcastUrl),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ContentNotAvailableAlertDialog();
        } else if (snapshot.hasData) {
          final snapshotData = snapshot.data!;
          final String podcastYear = snapshotData['year'];
          final String title = snapshot.data!['title'];

          return Platform.isIOS
              ? CupertinoPageScaffold(
                  backgroundColor: constScaffoldBackground,
                  navigationBar: CupertinoNavigationBar(
                    trailing: HomeButton(ref: ref),
                    backgroundColor: constTopBarBackgroundColor,
                    middle: AppBarTitleTile(
                      title: title,
                      subtitle: podcastYear,
                      titleMinFontSize: 14,
                      subtitleFontSize: 14,
                      isClickable: false,
                      route: '',
                    ),
                  ),
                  child: Material(
                    child: Container(
                      color: constScaffoldBackground,
                      child: PodcastBody(
                        snapshotData: snapshot.data!,
                      ),
                    ),
                  ))
              : Scaffold(
                  backgroundColor: constScaffoldBackground,
                  appBar: AppBar(
                    actions: [HomeButton(ref: ref)],
                    centerTitle: constIsAppBarTitleNotCentered,
                    title: AppBarTitleTile(
                      title: title,
                      subtitle: podcastYear.toString(),
                      titleMinFontSize: 14,
                      subtitleFontSize: 14,
                      isClickable: false,
                      route: '',
                    ),
                    elevation: 0,
                    backgroundColor: constTopBarBackgroundColor,
                    toolbarHeight: (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top) *
                        0.12,
                  ),
                  body: PodcastBody(
                    snapshotData: snapshot.data!,
                  ));
        } else {
          return Center(
              child: androidIosPicker(
                  androidVersion: const CircularProgressIndicator(
                    color: constCircularProgressIndicatorWhite,
                  ),
                  iosVersion: const CupertinoActivityIndicator(
                    color: constCircularProgressIndicatorWhite,
                  )));
        }
      });
}
