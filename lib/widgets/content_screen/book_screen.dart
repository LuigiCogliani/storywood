import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:readmore/readmore.dart';

import './strip_html.dart';

import '../android_ios_picker.dart';
import '../app_bar_title_tile.dart';
import '../content_not_available_alert_dialog.dart';
import '../home_button.dart';
import '../three_share_buttons.dart';
import '../adaptive_text_button.dart';

import '../../providers/api_provider_riverpod.dart';
import '../../data/theme_data.dart';

/// create the content screen for books
Widget bookContentScaffold({
  required contentId,
  required context,
  required ref,
}) {
  return FutureBuilder<Map>(
      future: ref.read(contentInfoProvider.notifier).checkForContentInFirebase(
            contentType: constContentTypeBook,
            contentId: contentId,
          ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ContentNotAvailableAlertDialog();
        } else if (snapshot.hasData) {
          final snapshotData = snapshot.data!;
          // if the date is stored as date time extract the year
          // if the date is an empty string, return an empty string
          // else convert to date time and then extract the year
          final year = snapshotData['year'].runtimeType == DateTime
              ? snapshotData['year'].year
              : snapshotData['year'] == ''
                  ? snapshotData['year']
                  : snapshotData['year'].toDate().year;

          final String title = snapshotData['title'];

          return Platform.isIOS
              ? CupertinoPageScaffold(
                  backgroundColor: constScaffoldBackground,
                  navigationBar: CupertinoNavigationBar(
                    trailing: HomeButton(ref: ref),
                    middle: AppBarTitleTile(
                      title: title,
                      subtitle: year.toString(),
                      titleMinFontSize: 14,
                      subtitleFontSize: 14,
                      isClickable: false,
                      route: '',
                    ),
                    backgroundColor: constTopBarBackgroundColor,
                  ),
                  child: BookBody(
                    snapshotData: snapshotData,
                  ),
                )
              : Scaffold(
                  backgroundColor: constScaffoldBackground,
                  appBar: AppBar(
                    actions: [HomeButton(ref: ref)],
                    centerTitle: constIsAppBarTitleNotCentered,
                    title: AppBarTitleTile(
                      title: title,
                      subtitle: year.toString(),
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
                  body: BookBody(
                    snapshotData: snapshotData,
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

class BookBody extends StatelessWidget {
  const BookBody({
    super.key,
    required this.snapshotData,
  });

  final Map snapshotData;

  final double bookInfoFontSize = 14;

  /// spread a list using the comma as separator (but desn't put a comma after the last element)
  String _spreadListString({required listToSpread}) {
    String spreadlist = '';
    for (int i = 0; i < listToSpread.length; i++) {
      if (i == 0) {
        spreadlist = listToSpread[i];
      } else {
        spreadlist = '$spreadlist, ${listToSpread[i]}';
      }
    }

    return spreadlist;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = (MediaQuery.of(context).size.width);
    final List<String> listToSpreadAuthors = [];
    for (var author in snapshotData['author']) {
      listToSpreadAuthors.add(author);
    }
    final List<String> listToSpreadGenres = [];
    for (var genre in snapshotData['genre']) {
      listToSpreadGenres.add(genre);
    }
    final String spreadAuthors =
        _spreadListString(listToSpread: listToSpreadAuthors);

    final String spreadGenre =
        _spreadListString(listToSpread: listToSpreadGenres);
    final String imagePath = snapshotData['posterPath'];
    final String pages = snapshotData['numberOfPages'];

    final String publisher = snapshotData['publisher'];
    final String previewLink = snapshotData['previewLink'];
    final String purchaseLink = snapshotData['canonicalVolumeLink'];

    final String overview = stripHtmlIfNeeded(snapshotData['overview']);
    final String storywoodContentId = snapshotData['storywoodContentId'];
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ThreeShareButtons(
              year: '',
              overview: overview,
              contentId: snapshotData['contentId'],
              contentInfo: {},
              imageUrl: imagePath,
              contentType: constContentTypeBook,
              title: snapshotData['title'],
              storywoodContentId: storywoodContentId,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              height: screenHeight * 0.20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                      height: screenHeight * 0.2,
                      width: screenWidth * 0.3,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: NetworkImage(imagePath.toString()),
                        fit: BoxFit.cover,
                      ))),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                    height: screenHeight * 0.2,
                    width: (screenWidth * 0.7) - 10,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          spreadAuthors.isNotEmpty
                              ? AutoSizeText(
                                  '${ConstStringContentScreen.bookAuthor} $spreadAuthors',
                                  maxLines: 2,
                                  minFontSize: bookInfoFontSize,
                                  maxFontSize: bookInfoFontSize,
                                  overflow: TextOverflow.ellipsis,
                                  style: constBodySmallLight,
                                )
                              : const Text(''),
                          spreadGenre.isNotEmpty
                              ? AutoSizeText(
                                  '${ConstStringContentScreen.bookGenre} $spreadGenre',
                                  maxLines: 2,
                                  minFontSize: bookInfoFontSize,
                                  maxFontSize: bookInfoFontSize,
                                  overflow: TextOverflow.ellipsis,
                                  style: constBodySmallLight,
                                )
                              : const Text(''),
                          Text('${ConstStringContentScreen.bookPages} $pages',
                              style: constBodySmallLight),
                          publisher.toString().isNotEmpty
                              ? AutoSizeText(
                                  '${ConstStringContentScreen.bookPublisher} $publisher',
                                  maxLines: 2,
                                  minFontSize: bookInfoFontSize,
                                  maxFontSize: bookInfoFontSize,
                                  overflow: TextOverflow.ellipsis,
                                  style: constBodySmallLight,
                                )
                              : const Text('')
                        ]),
                  )
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.002),
                width: screenWidth * 0.96,
                child: const Text(
                  ConstStringContentScreen.overviewSectionTitle,
                  style: constTitleMediumLightBold,
                )),
            Container(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.007),
              width: screenWidth * 0.90,
              child: ReadMoreText(
                overview,
                style: constBodyMediumLight,
                trimLines: 15,
                colorClickableText: constClickableText,
                trimMode: TrimMode.Line,
                trimCollapsedText: ConstStringContentScreen.readMoreTextMore,
                trimExpandedText: ConstStringContentScreen.readMoreTextLess,
              ),
            ),
            Platform.isIOS
                ? const SizedBox(
                    height: 1,
                  )
                : Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    child: AdaptiveUrlTextButton(
                        urlLink: previewLink,
                        text: ConstStringContentScreen.previewBook),
                  ),
            Platform.isIOS
                ? const SizedBox(
                    height: 1,
                  )
                : AdaptiveUrlTextButton(
                    urlLink: purchaseLink,
                    text: ConstStringContentScreen.buyBook)
          ],
        ),
      ),
    );
  }
}
