import 'package:flutter/material.dart';

/// Creates a [TextPainter] with the given [text] and [style].
TextPainter createTextPainter({
  required String text,
  required TextStyle? style,
  required double textScaleFactor,
}) =>
    TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaleFactor: textScaleFactor,
      maxLines: 1,
    )..layout();

/// Calculates the x-position of the given [value] in the given [rect].
double getPixelX(Rect rect, double x) => rect.left + x * rect.width;

/// Calculates the y-position of the given [value] in the given [rect].
double getPixelY(Rect rect, double y) => rect.bottom - y * rect.height;
