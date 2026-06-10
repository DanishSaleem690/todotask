import 'package:flutter/material.dart';

/// Branded app logo used on auth screens and in the app bar.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 120,
  });

  final double height;

  static const _assetPath = 'assets/images/app_logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.check_circle_outline,
          size: height * 0.5,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}
