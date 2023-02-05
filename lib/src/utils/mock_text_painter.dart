import 'package:flutter/material.dart';

class FLTextPainter extends TextPainter {
  FLTextPainter({
    InlineSpan? text,
    TextAlign textAlign = TextAlign.start,
    TextDirection? textDirection,
    double textScaleFactor = 1.0,
  }) : super(
            text: text,
            textAlign: textAlign,
            textDirection: textDirection,
            textScaleFactor: textScaleFactor);

  double get width {
    var fontSize = 14.0;
    if (text?.style != null) {
      fontSize = text?.style?.fontSize ?? 14.0;
    } else {
      text?.visitChildren((span) {
        fontSize = span.style?.fontSize ?? 14.0;
        return false;
      });
    }
    return (text?.toPlainText().length ?? 0) * (fontSize * 0.5);
  }

  double get height {
    var fontSize = 14.0;
    if (text?.style != null) {
      fontSize = text?.style?.fontSize ?? 14.0;
    } else {
      text?.visitChildren((span) {
        fontSize = span.style?.fontSize ?? 14.0;
        return false;
      });
    }
    return fontSize;
  }

  Size get size {
    return Size(width, height);
  }
}
