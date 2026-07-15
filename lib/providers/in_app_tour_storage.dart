import 'package:shared_preferences/shared_preferences.dart';

//store status variable for in-app tour views

class SaveInAppTour {
  Future<SharedPreferences> data = SharedPreferences.getInstance();

  void saveNewsfeedScreenTourStatus() async {
    final value = await data;

    value.setBool('seenNewsfeedScreen', true);
  }

  Future<bool> getNewsfeedScreenTourStatus() async {
    final value = await data;

    if (value.containsKey('seenNewsfeedScreen')) {
      bool? getData = value.getBool('seenNewsfeedScreen');
      return getData!;
    } else {
      return false;
    }
  }

  void saveNewTipShareScreenTourStatus() async {
    final value = await data;

    value.setBool('seenNewTipShareScreen', true);
  }

  Future<bool> getNewTipShareScreenTourStatus() async {
    final value = await data;

    if (value.containsKey('seenNewTipShareScreen')) {
      bool? getData = value.getBool('seenNewTipShareScreen');
      return getData!;
    } else {
      return false;
    }
  }
}
