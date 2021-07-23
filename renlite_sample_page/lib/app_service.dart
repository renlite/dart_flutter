import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:renlite/foundation.dart';
import 'package:renlite_objects/rendering.dart';

class AppService extends RenliteService {
  String greeting = "Dart";

  AppService() {
    this.tree = renliteTree;
  }

  @override
  void onTab(PointerEvent event, RenliteKeyMixin renderObject) {
    print("EVENT Tap !!!");
    print(renderObject.key);
    print(renderObject.parent);

    var renderView = this.tree?.renderView;
    var viewSize = renderView?.size;

    if (renderObject.key == "MasterButton") {
      print(viewSize?.width);
      AnimationController animationController = AnimationController(
          lowerBound: 1.0,
          upperBound: viewSize!.width,
          vsync: RenliteTicker(),
          duration: Duration(milliseconds: 250));
      RenliteTransform renliteTransform =
          this.tree?.getRenderObject("Transform") as RenliteTransform;

      animationController.addListener(() {
        renliteTransform.transform =
            Matrix4.translationValues(animationController.value, 1.0, 1.0);
      });
      animationController.addStatusListener((status) {
        if (status.index == 1) {
          print(animationController.value);
        } else if (status.index == 3) {
          animationController.dispose();
          RenderStack renderStack = renderView?.child as RenderStack;
          renderStack.move(renderStack.firstChild as RenderBox,
              after: renderStack.lastChild);
          renliteTransform.transform = Matrix4.identity();
          //this.greeting = "Flutter";
          //this.child = DetailPage(this);
          print("======");
          print(renliteTransform);
        }
      });
      animationController.forward();
    }

    if (renderObject.key == "DetailButton") {
      this.greeting = 'Dart';
      var page1 = this.tree?.getRenderObject("One");
      RenderStack renderStack = renderView?.child as RenderStack;
      renderStack.move(renderStack.firstChild as RenderBox,
          after: renderStack.lastChild);
    }
  }
}
