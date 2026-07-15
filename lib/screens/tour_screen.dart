import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//import 'package:irina_storywood_mockup/data/theme_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/tour_screen/tour_pages.dart';
import '../widgets/android_ios_picker.dart';
import '../data/theme_data.dart';

class TourScreen extends StatelessWidget {
  const TourScreen({super.key});
  static const routeName = '/tour-screen';

  Future<bool> _checkTourSeenStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool tourSeenStatus =
        prefs.getBool('tourSeen') == true ? true : false;
    return tourSeenStatus;
  }

  @override
  Widget build(BuildContext context) {
    final tourSeenStatus = _checkTourSeenStatus();
    return FutureBuilder(
        future: tourSeenStatus,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: androidIosPicker(
                  androidVersion: const CircularProgressIndicator(
                    color: constCircularProgressIndicatorWhite,
                  ),
                  iosVersion: const CupertinoActivityIndicator(
                    color: constCircularProgressIndicatorWhite,
                  )),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Center(
                  child: Text(ConstStringTourScreen.errorMessage,
                      style: constBodySmallLight));
            } else {
              return TourPages(
                tourSeenStatus: snapshot.data ?? false,
              );
            }
          } else {
            return Center(
              child: Text('State: ${snapshot.connectionState}',
                  style: constBodySmallLight),
            );
          }
        });
  }
}
