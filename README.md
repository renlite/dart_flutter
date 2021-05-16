## Proof of Concept: Renlite - [Flutter](https://flutter.dev/) light

### [Flutter](https://flutter.dev/) is different: layout
https://hackernoon.com/whats-revolutionary-about-flutter-946915b09514

Flutter and it's rendering with the new box layout model brings performance gains over traditional layout of objects. Traditionally layouts have a large set of rules and even a base component used in a render tree has a lot of properties. Components and their rules can interact or conflict with each other during the render process, which means many checks and if-clauses making layout of components slow and error prone.

Instead Flutter's [`AbstractNode > RenderObject > RenderBox`](https://api.flutter.dev/flutter/rendering/RenderBox-class.html) doesn't include all possible layouts but expresses the simple box layout in form of an [`BoxConstraints`](https://api.flutter.dev/flutter/rendering/BoxConstraints-class.html) object, passing it down the tree. A child [`RenderObject`](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) must respect the size (frame) passed by the parent [`RenderObject`](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) and so on. Beside [`RenderBox`](https://api.flutter.dev/flutter/rendering/RenderBox-class.html) representing the box layout there is a second layout protocol in Flutter currently: [`RenderSliver`](https://api.flutter.dev/flutter/rendering/RenderSliver-class.html), which is the base class for the RenderObjects that implement scrollable UI objects like List or Table.

https://proandroiddev.com/understanding-flutter-layout-box-constraints-292cc0d5e807

![box_constraints](https://miro.medium.com/max/500/1*Bz2AIkXQV1qWki4RiqLg_w.png)


### [Flutter](https://flutter.dev/) is different: building process
https://flutter.dev/docs/resources/architectural-overview#build-from-widget-to-element

Different UI frameworks use different main names for an UI object (Container, Button, Textfield, List, ...) that is part of a render tree. Common names for UI objects are: Components, Elements, Nodes, Controls, Widgets or RenderObjects. But wait, in Flutter there are Widgets, Elements and RenderObjekts.

Flutter's layout and rendering is based on following trees: WidgetTree, ElementTree, RenderObjectTree

![image](https://flutter.dev/images/arch-overview/trees.png)

* WidgetTree: is the declarative description of a screen in `Dart`and could be compared with a HTML page or a XML view in other UI frameworks. [`Widget`](https://api.flutter.dev/flutter/widgets/Widget-class.html) is the blueprint or configuration of an corresponding [`Element`](https://api.flutter.dev/flutter/widgets/Element-class.html). Widgets are immutable (final). At the first time and when something changes the build method of all [`Widgets`](https://api.flutter.dev/flutter/widgets/Widget-class.html) is called and the [`Widgets`](https://api.flutter.dev/flutter/widgets/Widget-class.html) used in the Widget(Sub)Tree are (new) recreated and the old instances are deleted by the garbage collector.

* ElementTree: is the part of the Flutter framework where the management of the ui (diffing) and the state management happens. ElementTree could be compared with the VDOM of a JavaScript framework. An [`Element`](https://api.flutter.dev/flutter/widgets/Element-class.html) is the implementation of a [`Widget`](https://api.flutter.dev/flutter/widgets/Widget-class.html). Every [`Element > ComponentElement`](https://api.flutter.dev/flutter/widgets/ComponentElement-class.html) holds a reference to a Widget and in case of a [`Element > RenderObjectElement`](https://api.flutter.dev/flutter/widgets/RenderObjectElement-class.html) also a reference to an associated RenderObject. [`ComponentElement`](https://api.flutter.dev/flutter/widgets/ComponentElement-class.html) is responsible for composition of Widgets. Thats the reason, why there are more blue and green than red circles on the picture.

* RenderObjectTree: is the area where the real work (composition, layout, painting) is done and the result of rendering is handed over to the [Skia](https://skia.org/) c++ engine, which translates the received commands to pixels showing on the screen. RenderObectTree could be compared with the [DOM - Document Object Model](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model/Introduction) for HTML pages. [`RenderObject`](https://api.flutter.dev/flutter/rendering/RenderObject-class.html) implements the basic layout and paint protocols. At the moment of writing there are two implemented layout protocols by the subclasses [`AbstractNode > RenderObject > RenderBox`](https://api.flutter.dev/flutter/rendering/RenderBox-class.html) and [`AbstractNode > RenderObject > RenderSliver`](https://api.flutter.dev/flutter/rendering/RenderSliver-class.html) as mentioned above. In most cases to implement a new UI object, it will be sufficient to inherit from [`RenderBox`](https://api.flutter.dev/flutter/rendering/RenderBox-class.html) or one of its subclasses and reuse the [`BoxConstraints`](https://api.flutter.dev/flutter/rendering/BoxConstraints-class.html) protocol.

### [Renlite](https://github.com/renlite/flutter/blob/master/renlite/README.md)
The picture of the build process shows three layers with a lot of repetition of UI objects. At the end of the day the configuration and logic of the WidgetTree and the ElementTree lands in the RenderObjectTree to layout and paint the ideas of a programmer.

If you
* don't like the syntax of two classes for state management StatefulWidgets
  ```dart
  class YellowBird extends StatefulWidget {
    const YellowBird({ Key? key }) : super(key: key);

    @override
    _YellowBirdState createState() => _YellowBirdState();
  }

  class _YellowBirdState extends State<YellowBird> {
    @override
    Widget build(BuildContext context) {
      return Container(color: const Color(0xFFFFE306));
    }
  }
  ```
* don't like the overhead of layers and UI objects
* like to understand, what happens under the hood
* like to reduce size and complexity
* still want to benefit from the declarativ style [Dart's](https://dart.dev/) [named parameters](https://dart.dev/guides/language/language-tour#parameters) offer

than Renlite is an attempt to use only the RenderObjectTree to write Flutter apps in a lightweight way.

[Continue reading ...](https://github.com/renlite/flutter/blob/master/renlite/README.md)
