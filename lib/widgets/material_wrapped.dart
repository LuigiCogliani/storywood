import 'package:flutter/material.dart';

import '../data/theme_data.dart';

/// A widget that wraps a child in material and container, allowing
/// us to use it with both android and ios.
/// Material widgets will not work in ios unless they are wrapped in material.
/// Takes only a child as
class MaterialWrapped extends StatelessWidget {
  const MaterialWrapped({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        // if we don't explicitly give a color we will get a white BG
        color: constScaffoldBackground,
        child: child,
      ),
    );
  }
}
