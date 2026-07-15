import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/users_provider_riverpod.dart';
import '../../data/theme_data.dart';

class SingleCommentOutput extends ConsumerWidget {
  final String message;
  final String userId;

  const SingleCommentOutput(this.message, this.userId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQueryWidth = (MediaQuery.of(context).size.width);
    final mediaQueryHeight = (MediaQuery.of(context).size.height);
    final String user = ref.read(usernameProvider)[userId]['username'] ??
        ConstStringTipScreen.userNotFound;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              mediaQueryWidth * 0.0293,
              mediaQueryHeight * 0.008,
              mediaQueryWidth * 0.0196,
              mediaQueryHeight * 0.008),
          child: CircleAvatar(
            backgroundColor: constCircleAvatarBackgroundDark,
            radius: 14,
            foregroundImage:
                NetworkImage(ref.read(usernameProvider)[userId]['imageUrl']),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: mediaQueryHeight * 0.008),
              child: Text(
                user,
                style: constChatLight,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: mediaQueryWidth * 0.8,
              child: TextWithHyperlink(
                  message: message, textStyle: constChatLight),
            )
          ],
        ),
      ],
    );
  }
}

/// a widget that detects hyperlinks in a text message
/// and makes them live
class TextWithHyperlink extends StatelessWidget {
  const TextWithHyperlink(
      {super.key, required this.message, required this.textStyle});
  final String message;
  final TextStyle textStyle;

  /// checks for hyperlink(s) in the message
  bool _hasHyperlink({required String message}) {
    return message.contains('://');
  }

  //final String url = 'https://www.youtube.com/watch?v=YZzbJb1Cuto';

  /// splits a message with hyperlinks into separate
  /// Textspan widgets
  List<InlineSpan> _splitMessage(
      {required String message, required TextStyle textStyle}) {
    // the item we will return at the end of this function
    final List<InlineSpan> listOfTextSpans = [];
    /** we will store the splitted string as a map to 
     * also store the isHyperlink information
    */
    final List<Map<String, dynamic>> strings = [];

    // split message using whitespace as separator
    final List<String> splittedMessage = message.split(' ');

    // we will use this to store subsequential non hyperlink strings
    String buffer = '';

    // for each splitted message
    for (var messageToCheck in splittedMessage) {
      bool isHyper = messageToCheck.contains('://');
      // if it's not hyperlink
      if (!isHyper) {
        // add to the buffer

        buffer = buffer.isEmpty ? messageToCheck : '$buffer $messageToCheck';
      }
      // if we stumble upon an hyperlink
      else {
        // if we already have some string in the buffer
        if (buffer.isNotEmpty) {
          // add the string in the buffer to "strings"
          strings.add({'isHyperLink': !isHyper, 'text': '$buffer '});
          // empty the buffer
          buffer = ' ';
        }
        // add the hyperlink to "strings"
        strings.add({'isHyperLink': isHyper, 'text': messageToCheck});
      }
    }
    // at the end of the loop if you still have something in the buffer
    if (buffer.isNotEmpty) {
      strings.add({'isHyperLink': false, 'text': buffer});
    }
// fill the list of text spans
    for (var snippet in strings) {
      // if we are looking at a hyperlink
      if (snippet['isHyperLink']) {
        String url = snippet['text'];
        listOfTextSpans.add(TextSpan(
          text: url,
          style: constHyperlink,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              launchUrl(Uri.parse(url));
            },
        ));
      } else {
        listOfTextSpans.add(TextSpan(text: snippet['text'], style: textStyle));
      }
    }

    return listOfTextSpans;
  }

  /// returns a text widget with selectable hyperlinks, if any
  Widget _commentWithHyperlinks(
      {required String message, required TextStyle textStyle}) {
    if (_hasHyperlink(message: message)) {
      return RichText(
          text: TextSpan(
              children: _splitMessage(message: message, textStyle: textStyle)));
    } else {
      return SelectableText(
        message,
        style: textStyle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _commentWithHyperlinks(message: message, textStyle: textStyle);
  }
}
