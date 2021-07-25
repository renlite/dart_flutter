## Renlite
is the try to develope a [Flutter](https://flutter.dev/) app only on the RenderTree (=RenderObjectTree).

### Entry Point
Following the boot process of a Flutter Widget based app `void main() => runApp(MyApp());` I found out that at some point the class [`RenderingFlutterBinding`](https://api.flutter.dev/flutter/rendering/RenderingFlutterBinding-class.html) was used to define the RenderTree.

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
In the constructor you already can define the root node of your UI tree, which must be a subclass of [`AbstractNode > RenderObject > RenderBox`](https://api.flutter.dev/flutter/rendering/RenderBox-class.html). There are a lot of implementers of [`AbstractNode > RenderObject > RenderBox`](https://api.flutter.dev/flutter/rendering/RenderBox-class.html). If you compare the different names beginning with Render* you will see that a lot of Widgets - not beeing only composition Widgets - have a corresponding [RenderObject](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) doing the layout and painting.

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
The [RendererBinding mixin](https://api.flutter.dev/flutter/rendering/RendererBinding-mixin.html) is the connection between the RenderTree and the [Flutter Engine](https://github.com/flutter/engine). The initialization of [PipelineOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) and of [RenderView](https://api.flutter.dev/flutter/rendering/RenderView-class.html) is here of interest. After creation of the [PipelineOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) a [RenderView](https://api.flutter.dev/flutter/rendering/RenderView-class.html) is initialized and assigned to the `_pipelineOwner.rootNode = value;` through the setter of `RenderView`.
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
* [PipelineOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) manages the rendering pipeline and the [RenderObjects](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) that are visible on the screen. [PipelineOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) for example maintains dirty state of [RenderObjects](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) for layout, composition and painting. Every [RenderObject](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) that is attached to a RenderTree managed by the [PipelineOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) holds a reference in the property `owner → PipelineOwner?`.  That means an attached [RenderObject](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) can access the [RenderView](https://api.flutter.dev/flutter/rendering/RenderView-class.html) instance, e.g. `final renderView = myRenderBox.owner.rootNode;`.
* [AbstractNode > RenderObject > RenderView](https://api.flutter.dev/flutter/rendering/RenderView-class.html) is a special subclass of [RenderObject](https://api.flutter.dev/flutter/rendering/RenderObject-class.html). It is the root of the RenderTree and handles bootstrapping of the RenderTree. It takes the entire size of a screen. 

### RenderTree Composition
There is no difference between composition of [Widgets](https://api.flutter.dev/flutter/widgets/Widget-class.html) and [RenderObjects](https://api.flutter.dev/flutter/rendering/RenderObject-class.html). [Dart](https://dart.dev/) offers the possibility to make composition declarativly, so we can define the RenderTree and write the logic in the same programming language.

With composition of [Dart](https://dart.dev/) objects (Widgets, RenderObjects) we can create reuseable UI objects and design the UI for the screen. There are three main types of RenderObjects: Leaf, Container with one child or Container with more children. The following table shows samples of the association between a  Widget(https://api.flutter.dev/flutter/widgets/Widget-class.html) and a RenderObject(https://api.flutter.dev/flutter/rendering/RenderObject-class.html) behind. E.g. [RawImage](https://api.flutter.dev/flutter/widgets/RawImage-class.html) creates [RenderImage](https://api.flutter.dev/flutter/rendering/RenderImage-class.html) in the `RenderImage createRenderObject(BuildContext context) {...}` method and uses [RenderImage](https://api.flutter.dev/flutter/rendering/RenderImage-class.html) to show an image on screen.  

| RenderObject        | with Mixin                            | children  | related Widget   | extends                       |
| --------------------|---------------------------------------| ----------|------------------|-------------------------------|
| [RenderImage](https://api.flutter.dev/flutter/rendering/RenderImage-class.html)         |                                       | null      | [RawImage](https://api.flutter.dev/flutter/widgets/RawImage-class.html)         | [LeafRenderObjectWidget](https://api.flutter.dev/flutter/widgets/LeafRenderObjectWidget-class.html)         |
| [RenderDecoratedBox](https://api.flutter.dev/flutter/rendering/RenderDecoratedBox-class.html)  | [RenderObjectWithChildMixin](https://api.flutter.dev/flutter/rendering/RenderObjectWithChildMixin-mixin.html)            | 0..1      | [DecoratedBox](https://api.flutter.dev/flutter/widgets/DecoratedBox-class.html)     | [SingleChildRenderObjectWidget](https://api.flutter.dev/flutter/widgets/SingleChildRenderObjectWidget-class.html) |
| [RenderFlex](https://api.flutter.dev/flutter/rendering/RenderFlex-class.html)          | [ContainerRenderObjectMixin](https://api.flutter.dev/flutter/rendering/ContainerRenderObjectMixin-mixin.html)            | 0..n      | [Flex](https://api.flutter.dev/flutter/widgets/Flex-class.html)             | [MultiChildRenderObjectWidget](https://api.flutter.dev/flutter/widgets/MultiChildRenderObjectWidget-class.html)  |

The composition happens during the instantiation (constructor and setter of the child property) of RenderObjects, but the attachment of a single RenderObject or a RenderTree to a [PipelineOwner](https://api.flutter.dev/flutter/rendering/PipelineOwner-class.html) occurs later and only, if the parent [RenderObject](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) we expand is attached already. This is important because during composition there is no access to the instance of the PipelineOwner.

[Composition and working example 'Hello World!' (14 LOC):](https://github.com/renlite/flutter/tree/master/render_sample_hello)
```Dart
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
```

### RenderTree Attachment
When is a RenderObject or a composition of RenderObjects attached? This happens the first time when a RenderObject or a Tree of RenderObjects is assigned to the [RenderView](https://api.flutter.dev/flutter/rendering/RenderView-class.html) or to another [RenderObject](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) that is already attached. This can be when the instance of RenderingFlutterBinding is created and the root parameter is assigned.
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
Code from [renlite_sample_page] https://github.com/renlite/flutter/tree/master/renlite_sample_page.

The RenderView kicks off the walk down the RenderTree. As RenderView is a container RenderObject which can hold one child, it has a mixed in type [RenderObjectWithChildMixin<RenderBox>](https://api.flutter.dev/flutter/rendering/RenderObjectWithChildMixin-mixin.html). Whith the assignement `RenderingFlutterBinding flutterBinding = RenderingFlutterBinding(root: RenderStack( ...` the child of RenderView is set to RenderDecoratedBox and the child setter of RenderView is called. Then `adoptChild(_child)` is invoked which is implemeented in the AbstractNode.

```Dart
class AbstractNode {
  // ...
  /// Whether this node is in a tree whose root is attached to something.
  ///
  /// This becomes true during the call to [attach].
  ///
  /// This becomes false during the call to [detach].
  bool get attached => _owner != null;
  
  @protected
  @mustCallSuper
  void adoptChild(covariant AbstractNode child) {
    // ...
    child._parent = this;
    if (attached)            // *** ONLY, if the parent (and so it's parent -> up to the root) of the RenderTree is attached too!!! ***
      child.attach(_owner!);
    redepthChild(child);
  }
}
  
abstract class RenderObject extends AbstractNode with DiagnosticableTreeMixin implements HitTestTarget {
  //..  
  @override
  void adoptChild(RenderObject child) {
    assert(_debugCanPerformMutations);
    assert(child != null);
    setupParentData(child);
    markNeedsLayout();
    markNeedsCompositingBitsUpdate();
    markNeedsSemanticsUpdate();
    super.adoptChild(child);
  }
}
```
Here the RenderView is assigned to be the child's parent and `child.attach(_owner!);` method (defined in RenderObjectWithChildMixin) is called, where `super.attach(owner);` of RenderObject and also `super.attach(owner);` of AbstractNode is invoked. In AbstractNode's attach method the PipelineOwner is finaly set to the child's (RenderDecoratedBox) `_owner` property and the RenderObject's attach method marks the child as dirty. After all if the child (RenderDecoratedBox) itself has a child (RenderSizedOverflowBox), the RenderSizedOverflowBox' attach method will be called and so on till a leaf RenderObject has no child. 

```Dart
class AbstractNode {
  // ...
  @mustCallSuper
  void attach(covariant Object owner) {
    //..
    _owner = owner;
  }
}

abstract class RenderObject extends AbstractNode with DiagnosticableTreeMixin implements HitTestTarget {
  //..
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    // If the node was dirtied in some way while unattached, make sure to add
    // it to the appropriate dirty list now that an owner is available
    if (_needsLayout && _relayoutBoundary != null) {
      // Don't enter this block if we've never laid out at all;
      // scheduleInitialLayout() will handle it
      _needsLayout = false;
      markNeedsLayout();
    }
    if (_needsCompositingBitsUpdate) {
      _needsCompositingBitsUpdate = false;
      markNeedsCompositingBitsUpdate();
    }
    if (_needsPaint && _layer != null) {
      // Don't enter this block if we've never painted at all;
      // scheduleInitialPaint() will handle it
      _needsPaint = false;
      markNeedsPaint();
    }
    if (_needsSemanticsUpdate && _semanticsConfiguration.isSemanticBoundary) {
      // Don't enter this block if we've never updated semantics at all;
      // scheduleInitialSemantics() will handle it
      _needsSemanticsUpdate = false;
      markNeedsSemanticsUpdate();
    }
  }
}
  
mixin RenderObjectWithChildMixin<ChildType extends RenderObject> on RenderObject {
  // ...
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_child != null)
      _child!.attach(owner);
  }
}
```
That means you can create more RenderTrees by composition but only that one that is appended to the RenderView or to a child of the RenderView is attached and painted to the screen. When a root RenderObject of a RenderTree is appended to another RenderObject that is already attached the attach method of all RenderObjects of the RenderTree is called. On the other side when a attached RenderObject is removed (child = null;) from parent's child the dettach method is called for the removed RenderObject and all their childs. For example there are tree RenderTrees Page_A, Page_B and Page_C. We could prepare all tree Pages by composition and assign only Page_A to the RenderView. Page_A will be rendered. Later on an user action we change the assigntment from Page_A to Page_B. All members of Page_A will be detached and all memebers of Page_B will be attached. Page_B will be showed. If we still hold a reference to the root RednerObject of Page_A the RenderTree of Page_A is available for later attechment without the need to (re)create new RenderObjects. The programmer can decide how to manage (re)creation of Dart objects and memory. In a typical Flutter app this is automatically managed by the framework in the ElementTree. Direct handling of RenderTree offers more control.

### Key of RenderObject
Unfortunatelly it is not simply possible to find a special RenderObject in the RenderTree by a Key like in the HTML-DOM e.g. to chnage the RenderObject or simply to change the color property. This is not necessery for Widget based apps because the rebuilding of a view is done by the ElementTree. An Element holds the positon of a Widget in the RenderTree and is responsible for the complicated diffing between Widgets. Theoretically it is possible to find a special RenderObject by walking up or down the RenderTree but this is not efficient and in most cases not recomended.
Amongst others Renlite brings the missing Key to RenderObjects with a very small framework 'service.dart'. RenliteKeyMixin uses the attach method to register a Key to an attached RenderObject. A very lightweight wrapper over a RenderObject using the ReliteKeyMixin makes it possible to find ther UI object later. For a better understanding and distinction I use the name convention Renlite* instead of Render*, e.g. RenliteParagraph (RenderParagraph), RenliteTransform (RenderTransform) or RenliteSimpleButton (Composition of more RenderObjects ).  
```Dart
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
```
You can even use RenliteObjects and RenderObjects together for composition of a RederTree, but only RenliteObjects can be find directly because of its Key. Sometimes it is not neccssary to create or use a RenliteObject, if the RenderObject (e.g. RenderParagraph) will never change or a RenderObject is the next child of a RenliteObject, so you can go down with:
```Dart
// e.g.
// ...  
RenliteTransform renliteTransform =
          renliteTree.getRenderObject("Transform") as RenliteTransform;
var renderParagraph = renliteTransform.child;`.
//...
```

###  Interaction
RenderObject offers the method [`@override void handleEvent(PointerEvent event, covariant HitTestEntry entry)`](https://api.flutter.dev/flutter/rendering/RenderObject/handleEvent.html), so you can react to diverse user actions. In service.dart a `typedef TabCallback = ...` is included for a simpler implementation. An example of onTab is available in [renlite_sample_page](https://github.com/renlite/flutter/tree/master/renlite_sample_page). Now the programmer has the full freedom on how and when to change the UI objects without the losse of Darst's composition posibilities. A part of a RenderTree (e.g. page) could maintain the rendering it self by reading data from a central datastore.
