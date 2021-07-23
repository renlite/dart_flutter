import 'package:flutter/rendering.dart';

typedef TabCallback = void Function(
    PointerDownEvent event, RenliteKeyMixin renderObject);

class SingltonRenliteTree {
  var _renderKeys = Map<String, RenderObject>();
  var _renderTypes = Map<Type, int>();
  RenderView? _renderView;

  SingltonRenliteTree._();

  RenderObject? getRenderObject(String key) {
    return _renderKeys[key];
  }

  void _setRenderObject(String key, RenderObject renderObject) {
    _renderKeys[key] = renderObject;
    if (_renderView == null) {
      _renderView = renderObject.owner?.rootNode as RenderView;
      print("RENDERVIEW DEBUG *******");
    }
  }

  String getKey(RenderObject renderObject) {
    Type type = renderObject.runtimeType;
    int? count = _renderTypes[type];
    count = count == null ? 1 : count += 1;
    _renderTypes[type] = count;
    return '${type.toString()}_${count.toString()}';
  }

  setRenderView(RenderView value) {
    this._renderView = value;
  }

  RenderView? get renderView {
    return this._renderView;
  }
}

final SingltonRenliteTree renliteTree = SingltonRenliteTree._();

mixin RenliteKeyMixin on RenderObject {
  String? key;
  bool _hasKey = false;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    print('in attach');
    if (_hasKey == false) {
      //print(this.owner!.rootNode);
      if (this.key == null) {
        this.key = renliteTree.getKey(this);
      }
      renliteTree._setRenderObject(this.key!, this);
      _hasKey = true;
    }
  }

  @override
  void detach() {
    super.detach();
    print('in detach');
  }
}

abstract class RenliteService {
  SingltonRenliteTree? tree;

  void onTab(PointerEvent event, RenliteKeyMixin renderObject);
}
