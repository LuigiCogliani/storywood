import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter/cupertino.dart';

import './request_item.dart';
import '../../providers/users_provider_riverpod.dart';
import '../../models/user_class.dart' as storywood;
import '../../data/theme_data.dart';
import '../../widgets/android_ios_picker.dart';

class RequestsList extends ConsumerStatefulWidget {
  const RequestsList({super.key});

  @override
  ConsumerState<RequestsList> createState() => _RequestsListState();
}

class _RequestsListState extends ConsumerState<RequestsList> {
  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(friendRequestsFutureProvider);
    return requests.when(
      data: (item) {
        final List<storywood.User?> loadedFriendRequests = item.values.toList();
        return Platform.isIOS
            ? CustomScrollView(
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      ref.invalidate(friendRequestsFutureProvider);
                    },
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return CupertinoRequestsListItem(
                        friendRequest: loadedFriendRequests[index]!);
                  }, childCount: loadedFriendRequests.length))
                ],
              )
            : RefreshIndicator(
                color: constCircularProgressIndicatorBlack,
                onRefresh: () async {
                  // ignore: unused_result
                  ref.refresh(friendRequestsFutureProvider);
                },
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return provider.ChangeNotifierProvider.value(
                      value: loadedFriendRequests[index],
                      child: const RequestsListItem(),
                    );
                  },
                  itemCount: loadedFriendRequests.length,
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
