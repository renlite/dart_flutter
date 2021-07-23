import 'master.dart';
import 'detail.dart';
import 'app_service.dart';
import 'package:flutter/rendering.dart';

void main() {
  var app = AppService();
  RenderingFlutterBinding flutterBinding = RenderingFlutterBinding(
      root: RenderStack(
          children: [MasterService(app: app), Detail(app)],
          textDirection: TextDirection.ltr));
  flutterBinding.drawFrame();
}
