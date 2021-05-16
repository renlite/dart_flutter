## [Renlite](https://github.com/renlite/flutter/blob/master/renlite/README.md)
is the try to develope a Flutter app only on the RenderObjectTree.

### Entry Point
Following the boot process of a Flutter Widget based app `void main() => runApp(MyApp());` I found out that at some point the class [`RenderFlutterBinding`] was used to define the RenderObjectTree.
