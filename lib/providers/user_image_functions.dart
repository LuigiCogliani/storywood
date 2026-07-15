import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_constants.dart';
import './users_provider_riverpod.dart';

///upload image to Firebase and update local records
void submitImage(
    {required File? pickedImageFile,
    required String userId,
    required String userImageUrl,
    required WidgetRef ref}) async {
  final storageRef =
      FirebaseStorage.instance.ref().child('user_images').child('$userId.jpg');

  await storageRef.putFile(pickedImageFile!);

  storageRef.getDownloadURL().then((value) {
    //update imageUrl in the user record locally and on Firebase
    ref.read(userInfoProvider.notifier).updateUserImageUrl(value);
  });
}

///method to select image from the gallery for user avatar
void pickImageFromGallery(
    {required String userId,
    required String userImageUrl,
    required WidgetRef ref}) async {
  ImagePicker()
      .pickImage(
    source: ImageSource.gallery,
    imageQuality: userProfileImageQuality,
    maxWidth: userProfileImageMaxWidth,
  )
      .then((value) {
    if (value == null) {
      return;
    } else {
      File pickedImage = File(value.path);
      submitImage(
        pickedImageFile: pickedImage,
        userId: userId,
        userImageUrl: userImageUrl,
        ref: ref,
      );
    }
  });
}

///method to take a photo with camera for user avatar
void takePhoto(
    {required String userId,
    required String userImageUrl,
    required WidgetRef ref}) {
  ImagePicker()
      .pickImage(
    source: ImageSource.camera,
    imageQuality: userProfileImageQuality,
    maxWidth: userProfileImageMaxWidth,
  )
      .then((value) {
    if (value == null) {
      return;
    } else {
      File pickedImage = File(value.path);
      submitImage(
          pickedImageFile: pickedImage,
          userId: userId,
          userImageUrl: userImageUrl,
          ref: ref);
    }
  });
}
