import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/theme_data.dart';
import '../../providers/user_image_functions.dart';
import '../../models/user_class.dart' as storywood;

class UserProfileImageSection extends ConsumerWidget {
  const UserProfileImageSection(
      {super.key, required this.profileUser, required this.isMyProfile});
  final storywood.User profileUser;
  final bool isMyProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final String userId = profileUser.userId!;
    final String userImageUrl =
        profileUser.imageUrl ?? constDefaultImageMisingPlaceholder;
    final int numberOfFriends = profileUser.friendsUserIds?.length ?? 0;

    buildChangeUserImageBottomSheet({required context}) {
      return showModalBottomSheet(
        enableDrag: true,
        useSafeArea: true, //ensures we leave padding on the top
        isScrollControlled: true,
        context: context,
        builder: ((BuildContext context) {
          return Container(
            color: constScaffoldBackground,
            padding: EdgeInsets.fromLTRB(
                screenWidth * 0.03,
                MediaQuery.of(context).viewInsets.top,
                screenWidth * 0.03,
                MediaQuery.of(context).viewInsets.bottom +
                    MediaQuery.of(context).viewPadding.bottom),
            child: Wrap(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //title
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                    child: const Text(
                      ConstStringUserProfileScreen
                          .bottomSheetChangeUserImageTitle,
                      style: constBodyLargeLight,
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                  //choose from gallery
                  ListTile(
                    onTap: () {
                      pickImageFromGallery(
                        userId: userId,
                        userImageUrl: userImageUrl,
                        ref: ref,
                      );
                    },
                    leading: Icon(
                      Platform.isIOS
                          ? constPictureGalleryCupertinoIcon
                          : constPictureGalleryMaterialIcon,
                      color: constIconColorLight,
                    ),
                    title: const Text(
                      ConstStringUserProfileScreen.pickImageFromGalleryLabel,
                      style: constBodyMediumWhite,
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                  //take photo
                  ListTile(
                    onTap: () {
                      takePhoto(
                        userId: userId,
                        userImageUrl: userImageUrl,
                        ref: ref,
                      );
                    },
                    leading: Icon(
                      Platform.isIOS
                          ? constTakePhotoCupertinoIcon
                          : constTakePhotoMaterialIcon,
                      color: constIconColorLight,
                    ),
                    title: const Text(
                      ConstStringUserProfileScreen.takePhotoLabel,
                      style: constBodyMediumWhite,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  )
                ],
              ),
            ]),
          );
        }),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: screenWidth * 0.3,
          height: screenWidth * 0.22,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: screenWidth * 0.15,
                  backgroundColor: constCircleAvatarBackgroundLight,
                  foregroundImage: NetworkImage(userImageUrl),
                ),
              ),
              if (isMyProfile)
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    onPressed: () {
                      buildChangeUserImageBottomSheet(context: context);
                    },
                    icon: const Icon(
                      CupertinoIcons.camera,
                    ),
                    iconSize: screenWidth * 0.05,
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(const CircleBorder()),

                      backgroundColor: MaterialStateProperty.all(
                          Colors.grey.shade300), // <-- Button color
                      overlayColor:
                          MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.pressed))
                          return Colors.grey.shade400; // <-- Splash color
                      }),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              0, screenHeight * 0.01, 0, screenHeight * 0.00),
          child: Text('$numberOfFriends friends',
              style: constSmallTextButtonLight),
        ),
      ],
    );
  }
}
