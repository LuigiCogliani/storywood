import 'package:flutter/material.dart';

import '../../data/theme_data.dart';
import '../../models/user_class.dart' as storywood;
import './posts_grid_view.dart';
import './playlists_grid_view.dart';

class UserProfileTabs extends StatelessWidget {
  const UserProfileTabs(
      {super.key, required this.profileUser, required this.isMyProfile});
  final storywood.User profileUser;
  final bool isMyProfile;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.05,
            child: const TabBar(
                indicatorColor: Colors.white,
                dividerColor: Colors.black,
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        ConstStringUserProfileScreen.tabNamePosts,
                        style: constBodySmallWhite,
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        ConstStringUserProfileScreen.tabNameCollections,
                        style: constBodySmallWhite,
                      ),
                    ),
                  ),
                ]),
          ),
          Expanded(
            child: TabBarView(children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: UserProfilePostsGrid(
                  profileUser: profileUser,
                  isMyProfile: isMyProfile,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: UserProfilePlaylistsGrid(
                  profileUser: profileUser,
                  isMyProfile: isMyProfile,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
