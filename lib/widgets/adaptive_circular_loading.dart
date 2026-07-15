import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'android_ios_picker.dart';

/// Adaptive circular loading wrapped inside a "Center" widget
adaptiveCircularLoading({required Color color}) {
  return Center(
    child: androidIosPicker(
        androidVersion: CircularProgressIndicator(color: color),
        iosVersion: CupertinoActivityIndicator(
          color: color,
        )),
  );
}
