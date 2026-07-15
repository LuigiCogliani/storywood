import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavigationBarIndexNotifier extends StateNotifier<int> {
  // the init value of the index is zero
  BottomNavigationBarIndexNotifier() : super(0);

  /// update the index of the icon highlighted in the bottom navigation bar
  /// (i.e. the current page)
  void updatebottomNavigationBarIndexNotifier(int index) {
    state = index;
  }
}

final bottomNavigationBarIndexProvider =
    StateNotifierProvider<BottomNavigationBarIndexNotifier, int>((ref) {
  return BottomNavigationBarIndexNotifier();
});

class TourNotifier extends StateNotifier<bool> {
  // the init value provider is false (tour not seeen)
  TourNotifier() : super(false);

  /// set tour to seen
  void turnTourToSeen() {
    state = true;
  }
}

final tourProvider = StateNotifierProvider<TourNotifier, bool>((ref) {
  return TourNotifier();
});
