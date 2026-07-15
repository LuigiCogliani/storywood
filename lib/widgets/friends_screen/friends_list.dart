import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart' as provider;

import './friends_item.dart';
import '../../widgets/android_ios_picker.dart';
import '../../providers/users_provider_riverpod.dart';
import '../../models/user_class.dart' as storywood;
import '../../data/theme_data.dart';
import '../adaptive_circular_loading.dart';
import '../content_not_available_alert_dialog.dart';
import '../../data/environment.dart';

class FriendsList extends ConsumerStatefulWidget {
  const FriendsList({super.key});

  @override
  ConsumerState<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends ConsumerState<FriendsList> {
  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsFutureProvider);
    return friends.when(
      data: (item) {
        final List<storywood.User?> loadedFriends = item.values.toList();
        return Platform.isIOS
            ? CustomScrollView(
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      // ignore: unused_result
                      ref.refresh(friendsFutureProvider);
                    },
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return CupertinoFriendsListItem(
                        friend: loadedFriends[index]!,
                        isLast:
                            (index + 1) == loadedFriends.length ? true : false,
                      );
                    },
                    childCount: loadedFriends.length,
                  ))
                ],
              )
            : RefreshIndicator(
                color: constCircularProgressIndicatorBlack,
                onRefresh: () async {
                  // ignore: unused_result
                  ref.refresh(friendsFutureProvider);
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return provider.ChangeNotifierProvider.value(
                      value: loadedFriends[index],
                      child: FriendsListItem(
                        friend: loadedFriends[index]!,
                        isLast:
                            (index + 1) == loadedFriends.length ? true : false,
                      ),
                    );
                  },
                  itemCount: loadedFriends.length,
                ),
              );
      },
      loading: () => Center(
          child: androidIosPicker(
              androidVersion: const CircularProgressIndicator(
                color: constCircularProgressIndicatorWhite,
              ),
              iosVersion: const CupertinoActivityIndicator(
                color: constCircularProgressIndicatorWhite,
              ))),
      error: (e, st) => Center(child: Text(e.toString())),
    );
  }
}

// class FriendsList extends ConsumerWidget {
//   const FriendsList({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final future = fetchFriendsFromFirebiase();
//     return FutureBuilder(
//       future: future,
//       builder: (BuildContext context, AsyncSnapshot snapshot) {
//         if (snapshot.hasData) {
//           final List loadedFriends = snapshot.data;
//           return ListView.builder(
//             itemCount: loadedFriends.length,
//             itemBuilder: (BuildContext context, int index) {
//               return FriendsListItem(
//                 friend: loadedFriends[index],
//               );
//             },
//           );
//         } else if (snapshot.hasError) {
//           return const ContentNotAvailableAlertDialog();
//         } else {
//           return adaptiveCircularLoading(color: constCircularProgressIndicatorWhite);
//         }
//       },
//     );
//   }
// }

// class FriendsList extends ConsumerStatefulWidget {
//   const FriendsList({super.key});

//   @override
//   ConsumerState<FriendsList> createState() => FriendsListState();
// }

// class FriendsListState extends ConsumerState<FriendsList> {
//   @override
//   Widget build(BuildContext context) {
//     final friends = ref.watch(friendsFutureProvider);
//     return friends.when(
//       data: (item) {
//         final List<storywood.User?> loadedFriends = item.values.toList();
//         return RefreshIndicator(
//           color: constCircularProgressIndicatorBlack,
//           onRefresh: () async {
//             // ignore: unused_result
//             ref.refresh(friendsFutureProvider);
//           },
//           child: ListView.builder(
//             itemBuilder: (context, index) {
//               return provider.ChangeNotifierProvider.value(
//                 value: loadedFriends[index],
//                 child: const FriendsListItem(),
//               );
//             },
//             itemCount: loadedFriends.length,
//           ),
//         );
//       },
//       loading: () => Center(
//           child: androidIosPicker(
//               androidVersion: const CircularProgressIndicator(
//                 color: constCircularProgressIndicatorWhite,
//               ),
//               iosVersion: const CupertinoActivityIndicator(
//                 color: constCircularProgressIndicatorWhite,
//               ))),
//       error: (e, st) => Center(child: Text(e.toString())),
//     );
//   }
// }
