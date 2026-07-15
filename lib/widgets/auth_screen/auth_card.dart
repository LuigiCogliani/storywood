import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../data/app_constants.dart';

import '../../widgets/android_ios_picker.dart';
import '../../data/theme_data.dart';

// ignore: constant_identifier_names
enum AuthMode { Signup, Login }

class AuthCard extends ConsumerStatefulWidget {
  const AuthCard(
      {required this.passDataToSubmitAuthScreenFunction,
      required this.isLoading,
      super.key});

  final bool isLoading;
  final void Function(String? email, String? password, String? username,
      AuthMode? authMode, WidgetRef ref) passDataToSubmitAuthScreenFunction;

  @override
  ConsumerState<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends ConsumerState<AuthCard> {
  // Initially password is obscure
  bool _obscureText = true;
  // needed to check if email inputted both times correctly on sign-up
  final _passwordController = TextEditingController();

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey();
  //Default view is Login card
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
    'username': '',
  };

  Widget _buildCupertinoEmailInputField() {
    return CupertinoTextFormFieldRow(
      style: constCupertinoTextFieldInput,
      key: const ValueKey('e-mail'),
      placeholder: ConstStringAuthScreen.emailFieldPrefix,
      placeholderStyle: constCupertinoTextFieldPrefix,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty || !value.contains('@')) {
          return ConstStringAuthScreen.emailFieldError;
        }
        return null;
      },
      onSaved: (value) {
        _authData['email'] = value!;
      },
    );
  }

  Widget _buildEmailInputField() {
    return TextFormField(
      style: constMaterialTextFieldInput,
      key: const ValueKey('e-mail'),
      decoration: const InputDecoration(
          labelText: ConstStringAuthScreen.emailFieldPrefix,
          labelStyle: constMaterialTextInputLabel),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty || !value.contains('@')) {
          return ConstStringAuthScreen.emailFieldError;
        }
        return null;
      },
      onSaved: (value) {
        _authData['email'] = value!;
      },
    );
  }

// list of rules for the username
  final List<TextInputFormatter> inputFormatters = [
    FilteringTextInputFormatter.allow(RegExp("[0-9\.\_a-zA-Z]")),
    FilteringTextInputFormatter.deny(RegExp(r'\s'))
  ];
  Widget _buildCupertinoUsernameInputField() {
    return CupertinoTextFormFieldRow(
      inputFormatters: inputFormatters,
      style: constCupertinoTextFieldInput,
      key: const ValueKey('username'),
      placeholder: ConstStringAuthScreen.usernameFieldPrefix,
      placeholderStyle: constCupertinoTextFieldPrefix,
      validator: _authMode == AuthMode.Signup
          ? (value) {
              if (value!.isEmpty || value.length < usernameMinimumLength) {
                return ConstStringAuthScreen.usernameFieldError;
              }
            }
          : null,
      onSaved: (value) {
        _authData['username'] = value!;
      },
    );
  }

  Widget _buildUsernameInputField() {
    return TextFormField(
      inputFormatters: inputFormatters,
      style: constMaterialTextFieldInput,
      key: const ValueKey('username'),
      enabled: _authMode == AuthMode.Signup,
      decoration: const InputDecoration(
          errorStyle: constAuthScreenTextInputError,
          labelText: ConstStringAuthScreen.usernameFieldPrefix,
          labelStyle: constMaterialTextInputLabel),
      validator: _authMode == AuthMode.Signup
          ? (value) {
              if (value!.isEmpty || value.length < usernameMinimumLength) {
                return ConstStringAuthScreen.usernameFieldError;
              }
            }
          : null,
      onSaved: (value) {
        _authData['username'] = value!;
      },
    );
  }

  Widget _buildCupertinoPasswordInputField() {
    return Row(
      children: [
        Expanded(
          child: CupertinoTextFormFieldRow(
            style: constCupertinoTextFieldInput,
            key: const ValueKey('password'),
            placeholder: ConstStringAuthScreen.passwordFieldPrefix,
            placeholderStyle: constCupertinoTextFieldPrefix,
            obscureText: _obscureText,
            controller: _passwordController,
            validator: (value) {
              if (value!.isEmpty || value.length < passwordMinimumLength) {
                return ConstStringAuthScreen.passwordFieldError;
              }
            },
            onSaved: (value) {
              _authData['password'] = value!;
            },
          ),
        ),
        IconButton(
          onPressed: _toggle,
          icon: Icon(
            _obscureText
                ? constAuthScreenCupertinoShowPasswordIcon
                : constAuthScreenCupertinoHidePasswordIcon,
            color: constAuthScreenShowHidePasswordIcon,
          ),
        )
      ],
    );
  }

  Widget _buildPasswordInputField() {
    return TextFormField(
      style: constMaterialTextFieldInput,
      key: const ValueKey('password'),
      decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: _toggle,
            icon: Icon(
              _obscureText
                  ? constAuthScreenMaterialShowPasswordIcon
                  : constAuthScreenMaterialHidePasswordIcon,
              color: constAuthScreenShowHidePasswordIcon,
            ),
          ),
          errorStyle: constAuthScreenTextInputError,
          labelText: ConstStringAuthScreen.passwordFieldPrefix,
          labelStyle: constMaterialTextInputLabel),
      obscureText: _obscureText,
      controller: _passwordController,
      validator: (value) {
        if (value!.isEmpty || value.length < passwordMinimumLength) {
          return ConstStringAuthScreen.passwordFieldError;
        }
      },
      onSaved: (value) {
        _authData['password'] = value!;
      },
    );
  }

  Widget _buildCupertinoPasswordConfirmationInputField() {
    return CupertinoTextFormFieldRow(
      style: constCupertinoTextFieldInput,
      key: const ValueKey('Confirm_Password'),
      placeholder: ConstStringAuthScreen.confirmPasswordFieldPrefix,
      placeholderStyle: constCupertinoTextFieldPrefix,
      validator: _authMode == AuthMode.Signup
          ? (value) {
              if (value != _passwordController.text) {
                return ConstStringAuthScreen.confirmPasswordFieldError;
              }
            }
          : null,
      enabled: _authMode == AuthMode.Signup,
      obscureText: _obscureText,
    );
  }

  Widget _buildPasswordConfirmationInputField() {
    return TextFormField(
      style: constMaterialTextFieldInput,
      enabled: _authMode == AuthMode.Signup,
      decoration: const InputDecoration(
          labelText: ConstStringAuthScreen.confirmPasswordFieldPrefix,
          labelStyle: constMaterialTextInputLabel),
      obscureText: _obscureText,
      validator: _authMode == AuthMode.Signup
          ? (value) {
              if (value != _passwordController.text) {
                return ConstStringAuthScreen.confirmPasswordFieldError;
              }
            }
          : null,
    );
  }

  ///Function to submit data and pass on to Auth Screen _submitAuthForm function
  Future<void> _submit(WidgetRef ref) async {
    // when the user logs in we can update the tour preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tourSeen', true);

    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    widget.passDataToSubmitAuthScreenFunction(
        _authData['email']!.trim(),
        _authData['password']!.trim(),
        _authData['username']!.trim(),
        _authMode,
        ref);
  }

  Widget _buildSubmitButton(mediaQueryWidth) {
    return SizedBox(
      width: mediaQueryWidth * 0.6,
      child: ElevatedButton(
        onPressed: () {
          _submit(ref);
        },
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0)),
          foregroundColor: MaterialStateProperty.all(
              constAuthScreenElevatedButtonForeground),
          backgroundColor: MaterialStateProperty.all(
              constAuthScreenElevatedButtonBackground),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        ),
        child: Text(
          _authMode == AuthMode.Login
              ? ConstStringAuthScreen.login
              : ConstStringAuthScreen.signup,
          style: constMaterialElevatedButtonLightText,
        ),
      ),
    );
  }

  Widget _buildCupertinoSubmitButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      width: 300,
      child: CupertinoButton.filled(
        onPressed: () {
          _submit(ref);
        },
        child: Text(
          _authMode == AuthMode.Login
              ? ConstStringAuthScreen.login
              : ConstStringAuthScreen.signup,
          style: constCupertinoElevatedButtonLightText,
        ),
      ),
    );
  }

  ///Function switches state from Login to Signup and back
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  Widget _buildAuthmodeSwitchButton(mediaQueryWidth) {
    return SizedBox(
      width: mediaQueryWidth * 0.6,
      child: TextButton(
        onPressed: _switchAuthMode,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 4.0)),
          foregroundColor: MaterialStateProperty.all(
              constAuthScreenElevatedButtonForeground),
          backgroundColor: MaterialStateProperty.all(
              constAuthScreenElevatedButtonBackground),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
            '${_authMode == AuthMode.Login ? ConstStringAuthScreen.signup : ConstStringAuthScreen.login} ${ConstStringAuthScreen.instead}',
            style: constMaterialElevatedButtonLightText),
      ),
    );
  }

  Widget _buildCupertinoAuthmodeSwitchButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      width: 300,
      child: CupertinoButton.filled(
        onPressed: _switchAuthMode,
        child: Text(
          '${_authMode == AuthMode.Login ? ConstStringAuthScreen.signup : ConstStringAuthScreen.login} ${ConstStringAuthScreen.instead}',
          style: constCupertinoElevatedButtonLightText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final widgetWidth = deviceSize.width * 0.75;
    const double minWidgetHeightLogin = 260;
    const double minWidgetHeightSignup = 320;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        constraints: BoxConstraints(
            minHeight: _authMode == AuthMode.Signup
                ? minWidgetHeightSignup
                : minWidgetHeightLogin),
        width: widgetWidth,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              androidIosPicker(
                  androidVersion: _buildEmailInputField(),
                  iosVersion: _buildCupertinoEmailInputField()),
              if (_authMode == AuthMode.Signup)
                androidIosPicker(
                    androidVersion: _buildUsernameInputField(),
                    iosVersion: _buildCupertinoUsernameInputField()),
              androidIosPicker(
                  androidVersion: _buildPasswordInputField(),
                  iosVersion: _buildCupertinoPasswordInputField()),
              if (_authMode == AuthMode.Signup)
                androidIosPicker(
                    androidVersion: _buildPasswordConfirmationInputField(),
                    iosVersion:
                        _buildCupertinoPasswordConfirmationInputField()),
              const SizedBox(
                height: 20,
              ),
              if (widget.isLoading)
                androidIosPicker(
                    androidVersion: const CircularProgressIndicator(
                      color: constCircularProgressIndicatorBlack,
                    ),
                    iosVersion: const CupertinoActivityIndicator(
                      color: constCircularProgressIndicatorBlack,
                    ))
              else
                androidIosPicker(
                    androidVersion: _buildSubmitButton(deviceSize.width),
                    iosVersion: _buildCupertinoSubmitButton()),
              androidIosPicker(
                  androidVersion: _buildAuthmodeSwitchButton(deviceSize.width),
                  iosVersion: _buildCupertinoAuthmodeSwitchButton()),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: GestureDetector(
                  child: const Text(
                    ConstStringAuthScreen.acceptAgreement,
                    style: constAuthCardLegalLink,
                    textAlign: TextAlign.center,
                  ),
                  onTap: () {
                    launchUrl(Uri.parse(constStorywoodLegalLink),
                        mode: LaunchMode.externalApplication);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
