## [Renlite](https://github.com/renlite/flutter/blob/master/renlite/README.md)
is the try to develope a Flutter app only on the RenderObjectTree.

### Entry Point
Following the boot process of a Flutter Widget based app `void main() => runApp(MyApp());` I found out that at some point the class [`RenderFlutterBinding`](https://api.flutter.dev/flutter/rendering/RenderingFlutterBinding-class.html) was used to define the RenderObjectTree.

```Dart
class RenderingFlutterBinding extends BindingBase with GestureBinding, SchedulerBinding, ServicesBinding, SemanticsBinding, PaintingBinding, RendererBinding {
  /// Creates a binding for the rendering layer.
  ///
  /// The `root` render box is attached directly to the [renderView] and is
  /// given constraints that require it to fill the window.
  RenderingFlutterBinding({ RenderBox? root }) {
    assert(renderView != null);
    renderView.child = root;
  }
}
```
In the constructor you already can define the root node of your UI tree, whis must be a subcluss of [`AbstractNode > RenderObject > RenderBox`](https://api.flutter.dev/flutter/rendering/RenderBox-class.html). There are a lot of implementers of [`AbstractNode > RenderObject > RenderBox`](https://api.flutter.dev/flutter/rendering/RenderBox-class.html). If you compare the different names beginning with Render* you will see that a lot of Widgets have a corresponding RenderObject doing the layout and painting.
 
