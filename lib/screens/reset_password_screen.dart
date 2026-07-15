import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import '../widgets/android_ios_picker.dart';
import '../data/theme_data.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const routeName = '/resetPassword';
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final String message = ConstStringResetPasswordScreen.message;
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  /// send a password reset email
  // Future resetPassword() async {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) {
  //         return const Center(
  //             child: CircularProgressIndicator(
  //           color: constCircularProgressIndicatorWhite,
  //         ));
  //       });
  //   try {
  //     await FirebaseAuth.instance
  //         .sendPasswordResetEmail(email: emailController.text.trim());

  //     // go back to the auth screen
  //     Navigator.of(context).popUntil((route) {
  //       return route.isFirst;
  //     });
  //   } on FirebaseAuthException catch (e) {
  //     Navigator.of(context).pop();
  //   }
  // }

  /// send a password reset email and show an alert dialog with the outcome
  Future<void> _resetPassword() {
    return showDialog(
        context: context,
        builder: (context) {
          return FutureBuilder(
            future: FirebaseAuth.instance
                .sendPasswordResetEmail(email: emailController.text.trim()),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                  return Platform.isIOS
                      ? CupertinoAlertDialog(
                          title: const Text(
                              ConstStringResetPasswordScreen
                                  .alertDialogGenericTitle,
                              style: ConstCupertinoDialog.title),
                          content: const Text(
                            ConstStringResetPasswordScreen.errorMessage,
                            style: ConstCupertinoDialog.message,
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text(
                                  ConstStringResetPasswordScreen
                                      .alertDialogGenericCloseButton,
                                  style: ConstCupertinoDialog.closeButton),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        )
                      : AlertDialog(
                          title: const Text(
                              ConstStringResetPasswordScreen
                                  .alertDialogGenericTitle,
                              style: ConstMaterialDialog.title),
                          content: const Text(
                            ConstStringResetPasswordScreen.errorMessage,
                            style: ConstMaterialDialog.message,
                          ),
                          actions: [
                            TextButton(
                              child: const Text(
                                  ConstStringResetPasswordScreen
                                      .alertDialogGenericCloseButton,
                                  style: ConstMaterialDialog.closeButton),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                } else {
                  return androidIosPicker(
                      androidVersion:
                          const ResetPasswordConfirmationMaterialAlertDialog(),
                      iosVersion:
                          const ResetPasswordConfirmationCupertinoAlertDialog());
                }
              }
              /* 
              Since the future used of type void the snapshot will not have data, hence we need
              this other alert dialog outside of all the if statement for it to work.
              Note that the code after the last "else" is also needed in order to not raise an error
              */
              return androidIosPicker(
                  androidVersion:
                      const ResetPasswordConfirmationMaterialAlertDialog(),
                  iosVersion:
                      const ResetPasswordConfirmationCupertinoAlertDialog());
            },
          );
        });
  }

  Widget _buildResetPasswordScreen(mediaQueryWidth) {
    return Scaffold(
      backgroundColor: constScaffoldBackground,
      appBar: AppBar(
        centerTitle: constIsAppBarTitleNotCentered,
        backgroundColor: constTopBarBackgroundColor,
        elevation: 0,
        title: const Text(
          ConstStringResetPasswordScreen.screenTitle,
          style: constTopBar,
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
                maxHeight: 300, maxWidth: mediaQueryWidth * 0.60),
            child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      ConstStringResetPasswordScreen.screenBody,
                      textAlign: TextAlign.center,
                      style: constBodyLargeDark,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        color: constAuthScreenCard,
                        child: TextFormField(
                          style: constMaterialTextFieldInput,
                          controller: emailController,
                          cursorColor: constCursorColorDark,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                              // label of the form field
                              labelText: ConstStringResetPasswordScreen
                                  .emailFieldPrefix,
                              labelStyle: constMaterialTextInputLabel,
                              // change the color of the underline
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: constMaterialTextFieldUnderline),
                              )),
                          keyboardType: TextInputType.emailAddress,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (email) {
                            email != null && !EmailValidator.validate(email)
                                ? ConstStringResetPasswordScreen.emailFieldError
                                : null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor:
                              constAuthScreenElevatedButtonBackground),
                      icon: const Icon(
                        Icons.email_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        ConstStringResetPasswordScreen.buttonText,
                        style: constMaterialElevatedButtonLightText,
                      ),
                      onPressed: () {
                        _resetPassword();
                      },
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoResetPasswordScreen(mediaQueryWidth) {
    return CupertinoPageScaffold(
      backgroundColor: constScaffoldBackground,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: constTopBarBackgroundColor,
        middle: Text(ConstStringResetPasswordScreen.screenTitle,
            style: constTopBar),
      ),
      child: Center(
        child: Card(
          color: constAuthScreenCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 8.0,
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(
                maxHeight: 300, maxWidth: mediaQueryWidth * 0.60),
            child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      ConstStringResetPasswordScreen.screenBody,
                      textAlign: TextAlign.center,
                      style: constBodyLargeDark,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CupertinoTextFormFieldRow(
                      style: constCupertinoTextFieldInput,
                      key: const ValueKey('e-mail'),
                      prefix: const Text(
                        ConstStringResetPasswordScreen.emailFieldPrefix,
                        style: constCupertinoTextFieldPrefix,
                      ),
                      //keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      cursorColor: constCursorColorDark,
                      textInputAction: TextInputAction.done,
                      validator: (email) {
                        email != null && !EmailValidator.validate(email)
                            ? ConstStringResetPasswordScreen.emailFieldError
                            : null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CupertinoButton.filled(
                      onPressed: () {
                        _resetPassword();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            constEmailCupertinoIcon,
                            color: constIconColorLight,
                            size: 16,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            ConstStringResetPasswordScreen.buttonText,
                            style: constCupertinoElevatedButtonLightText,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryWidth = MediaQuery.of(context).size.height;
    return androidIosPicker(
        androidVersion: _buildResetPasswordScreen(mediaQueryWidth),
        iosVersion: _buildCupertinoResetPasswordScreen(mediaQueryWidth));
  }
}

class ResetPasswordConfirmationCupertinoAlertDialog extends StatelessWidget {
  const ResetPasswordConfirmationCupertinoAlertDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text(ConstStringResetPasswordScreen.message,
          style: ConstCupertinoDialog.title),
      content: const Text(ConstStringResetPasswordScreen.iosContent,
          style: ConstCupertinoDialog.message),
      actions: [
        CupertinoDialogAction(
          child: const Text(
              ConstStringResetPasswordScreen.alertDialogGenericCloseButton,
              style: ConstCupertinoDialog.closeButton),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}

class ResetPasswordConfirmationMaterialAlertDialog extends StatelessWidget {
  const ResetPasswordConfirmationMaterialAlertDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ConstStringResetPasswordScreen.message,
          style: ConstMaterialDialog.title),
      content: const Text(ConstStringResetPasswordScreen.iosContent,
          style: ConstMaterialDialog.message),
      actions: [
        TextButton(
          child: const Text(
              ConstStringResetPasswordScreen.alertDialogGenericCloseButton,
              style: ConstMaterialDialog.closeButton),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
