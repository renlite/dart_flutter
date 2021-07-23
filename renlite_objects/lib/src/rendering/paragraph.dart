import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:renlite/foundation.dart';

class RenliteParagraph extends RenderParagraph with RenliteKeyMixin {
  RenliteParagraph({required String text, String? key, Color? color})
      : super(
            TextSpan(
              text: text,
              style: TextStyle(color: color ?? Colors.black, fontSize: 25.0),
            ),
            textDirection: TextDirection.ltr) {
    this.key = key;
  }
}
