import 'package:flutter/material.dart';

void showTopSnackBar(
  BuildContext context,
  String message, {
  Color color = Colors.green,
}) {
  final mediaQuery = MediaQuery.of(context);
  final height = mediaQuery.size.height;
  final safeAreaTop = mediaQuery.padding.top;

  // Calculate bottom margin to push it to the top
  // Height - Safe Area - Estimated SnackBar Height (~60) - padding
  double bottomMargin = height - safeAreaTop - 80;
  if (bottomMargin < 0) bottomMargin = 0;

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: bottomMargin, left: 20, right: 20),
      duration: const Duration(seconds: 3),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
