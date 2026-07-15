import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/home_button.dart';
import '../widgets/android_ios_picker.dart';
import '../widgets/new_tip_screen/content_type_field.dart';
import '../widgets/discover_screen/cupertino_drop_down.dart' as discover;
import '../widgets/new_tip_screen/title_search_field.dart';
import '../widgets/three_share_buttons.dart';
import '../widgets/bottom_navigation_bar.dart';

import '../data/theme_data.dart';

//TODO: Luigi to review

class NewTipSearchScreen extends ConsumerWidget {
  const NewTipSearchScreen({super.key});
  static const routeName = '/discover-screen';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final modalRouteArguments =
        ModalRoute.of(context)!.settings.arguments as List;
    final bool isNotDiscoverScreen = modalRouteArguments[0];
    final String screenTitle = isNotDiscoverScreen
        ? ConstNewTipScreen.screenTitleNewTip
        : ConstNewTipScreen.screenTitleDiscover;
    return Scaffold(
      appBar: AppBar(
          actions: isNotDiscoverScreen ? null : [HomeButton(ref: ref)],
          centerTitle: constIsAppBarTitleNotCentered,
          automaticallyImplyLeading: false,
          backgroundColor: constTopBarBackgroundColor,
          title: Text(
            screenTitle,
            style: constTopBar,
          )),
      backgroundColor: constScaffoldBackground,
      body: Material(
          child: Container(
        color: constScaffoldBackground,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.1,
                width: double.infinity,
                child: const discover.CupertinoContentType(),
              ),
              const TitleSearchAPI(),
            ],
          ),
        ),
      )),
      bottomNavigationBar:
          isNotDiscoverScreen ? const StorywoodBottomNavigationBar() : null,
    );
  }
}
