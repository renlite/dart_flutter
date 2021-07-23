import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:renlite/foundation.dart';

class RenliteTransform extends RenderTransform with RenliteKeyMixin {
  RenliteTransform({
    required Matrix4 transform,
    String? key,
    RenderBox? child,
  }) : super(transform: transform, child: child) {
    this.key = key;
  }
}
