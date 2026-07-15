import 'dart:io';

import 'package:flutter/material.dart';

Widget androidIosPicker({required androidVersion, required iosVersion}) {
  return Platform.isIOS ? iosVersion : androidVersion;
}
