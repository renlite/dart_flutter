import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart' show Colors;

void main() {
  RenderingFlutterBinding flutterBinding = RenderingFlutterBinding(
      root: RenderFlex(mainAxisAlignment: MainAxisAlignment.center, children: [
    RenderParagraph(
        TextSpan(
          text: 'Hello World!',
          style: TextStyle(color: Colors.purple, fontSize: 25.0),
        ),
        textDirection: TextDirection.ltr)
  ]));
  flutterBinding.drawFrame();
}
