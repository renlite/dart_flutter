## Renlite
is the try to develope a [Flutter](https://flutter.dev/) app only on the RenderObjectTree.

### Entry Point
Following the boot process of a Flutter Widget based app `void main() => runApp(MyApp());` I found out that at some point the class [`RenderingFlutterBinding`](https://api.flutter.dev/flutter/rendering/RenderingFlutterBinding-class.html) was used to define the RenderObjectTree.

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
In the constructor you already can define the root node of your UI tree, which must be a subclass of [`AbstractNode > RenderObject > RenderBox`](https://api.flutter.dev/flutter/rendering/RenderBox-class.html). There are a lot of implementers of [`AbstractNode > RenderObject > RenderBox`](https://api.flutter.dev/flutter/rendering/RenderBox-class.html). If you compare the different names beginning with Render* you will see that a lot of Widgets - not beeing only composition Widgets - have a corresponding RenderObject doing the layout and painting.

The superclass constructor `BindingBase(){...}` is called implicitly when the incstance of RenderingFlutterBinding is created. In the [BindingBase's constructor](https://github.com/flutter/flutter/blob/b22742018b/packages/flutter/lib/src/foundation/binding.dart#L45) there is especially the call `initInstances();` which invokes the overriden method in the [RendererBinding mixin](https://api.flutter.dev/flutter/rendering/RendererBinding-mixin.html). [RenderingFlutterBinding](https://api.flutter.dev/flutter/rendering/RenderingFlutterBinding-class.html) uses [RendererBinding](https://api.flutter.dev/flutter/rendering/RendererBinding-mixin.html) among other mixins.

```Dart
mixin RendererBinding on BindingBase, ServicesBinding, SchedulerBinding, GestureBinding, SemanticsBinding, HitTestable {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    _pipelineOwner = PipelineOwner(
      onNeedVisualUpdate: ensureVisualUpdate,
      onSemanticsOwnerCreated: _handleSemanticsOwnerCreated,
      onSemanticsOwnerDisposed: _handleSemanticsOwnerDisposed,
    );
    window
      ..onMetricsChanged = handleMetricsChanged
      ..onTextScaleFactorChanged = handleTextScaleFactorChanged
      ..onPlatformBrightnessChanged = handlePlatformBrightnessChanged
      ..onSemanticsEnabledChanged = _handleSemanticsEnabledChanged
      ..onSemanticsAction = _handleSemanticsAction;
    initRenderView();
    ...
  }

```
The [RendererBinding mixin](https://api.flutter.dev/flutter/rendering/RendererBinding-mixin.html) is the connection between the RenderObjectTree and the Flutter engine. The initialization of [PipelineOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) and of [RenderView](https://api.flutter.dev/flutter/rendering/RenderView-class.html) is here of interest. After creation of the [PipelineOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) a [RenderView](https://api.flutter.dev/flutter/rendering/RenderView-class.html) is initialized and assigned to the `_pipelineOwner.rootNode = value;` through the setter of `RenderView`.
```Dart
  /// Creates a [RenderView] object to be the root of the
  /// [RenderObject] rendering tree, and initializes it so that it
  /// will be rendered when the next frame is requested.
  void initRenderView() {
    ...
    renderView = RenderView(configuration: createViewConfiguration(), window: window);
    renderView.prepareInitialFrame();
  }
  ...
  /// The render tree that's attached to the output surface.
  RenderView get renderView => _pipelineOwner.rootNode! as RenderView;
  /// Sets the given [RenderView] object (which must not be null), and its tree, to
  /// be the new render tree to display. The previous tree, if any, is detached.
  set renderView(RenderView value) {
    assert(value != null);
    _pipelineOwner.rootNode = value;
  }
```
* [PipelineOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) manages the rendering pipeline and the [RenderObjects](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) that are visible on the screen. [PipelineOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) for example maintains dirty states of [RenderObjects](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) for layout, composition and painting. Every [RenderObject](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) that is attached to a render tree managed by the [PipelineOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) holds a reference in the property `owner → PipelineOwner?`.  That means an attached [RenderObject](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) can access the [RenderView](https://api.flutter.dev/flutter/rendering/RenderView-class.html) instance, e.g. `final renderView = myRenderBox.owner.rootNode;`.
* [AbstractNode > RenderObject > RenderView](https://api.flutter.dev/flutter/rendering/RenderView-class.html) is a special subclass of [RenderObject](https://api.flutter.dev/flutter/rendering/RenderObject-class.html). It is the root of the RenderObjectTree and handles bootstrapping of the render tree. It takes the entire size of a screen. 

### Composition
When does composition happen or when is a RenderObject attached to a RenderTree? This happens the first time when a RenderObject or a Tree of RenderObjects is assigned to the [RenderView](https://api.flutter.dev/flutter/rendering/RenderView-class.html). This can be when the instance of RenderingFlutterBinding is created and the root parameter is assigned.
```Dart
void main() {
  var app = AppService();
  RenderingFlutterBinding flutterBinding = RenderingFlutterBinding(
      root: RenderStack(
          children: [MasterService(app: app), Detail(app)],
          textDirection: TextDirection.ltr));
  flutterBinding.drawFrame();
}
```
