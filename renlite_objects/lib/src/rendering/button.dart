import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:renlite/foundation.dart';

class RenliteSimpleButton extends RenderDecoratedBox with RenliteKeyMixin {
  TabCallback? onTab;

  RenliteSimpleButton(
      {required Decoration decoration,
      TabCallback? onTab,
      String? key,
      SemanticsConfiguration? config,
      RenderBox? child})
      : super(decoration: decoration, child: child) {
    this.key = key;
    this.onTab = onTab;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    //print(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) this.onTab!(event, this);
  }
}
