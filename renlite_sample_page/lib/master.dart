import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:renlite/foundation.dart';
import 'package:renlite_objects/rendering.dart';
import 'app_service.dart';

class MasterService extends RenderProxyBox with RenliteKeyMixin {
  String name = "Goto Detail";
  late AppService app;

  MasterService({String key = "One", required RenliteService app}) {
    this.key = key;
    this.app = app as AppService;
    this.child = this.build(app);
  }

  RenderBox build(RenliteService app) {
    return RenliteTransform(
        key: "Transform",
        transform: Matrix4.identity(),
        child: RenderPositionedBox(
          alignment: Alignment.center,
          child: RenliteSimpleButton(
              key: "MasterButton",
              onTab: app.onTab,
              decoration: BoxDecoration(color: Colors.blue),
              child: RenderSizedOverflowBox(
                  requestedSize: Size(400.0, 400.0),
                  child: RenderParagraph(
                      TextSpan(
                        text: this.name,
                        // appService?.greeting,
                        // Casting (this.renliteAppService as AppService).greeting
                        style: TextStyle(color: Colors.white, fontSize: 25.0),
                      ),
                      textDirection: TextDirection.ltr))),
        ));
  }

  void onTab(PointerDownEvent event, RenliteKeyMixin renderObject) {
    this.app.tree?.renderView;
  }
}
