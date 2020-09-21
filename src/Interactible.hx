class Interactible {
  public static function button(f:StackP->Void, ox:Float, oy:Float, obj:StackP):Interactible {
    return new Interactible(Press((k, t) -> switch (k) {
      case Held: t.offset(ox, oy);
      case Released: t.resetTemp();
      case Pressed: f(t);
    }), obj);
  }

  public static function zoom(obj:StackP):Interactible {
    var ret = new Interactible(Press((k, t) -> switch (k) {
      case Pressed: ren.zoomDetail(t);
      case _:
    }), obj);
    ret.cursor = Zoom;
    return ret;
  }

  public static function drag(
    axisIdx:Int, // 0 = x, 1 = y, 2 = z
    dragger:Float->Float, // dragger
    finish:Float->Float, // finish function
    obj:StackP, // object to move during drag
    handle:StackP, // object to grab to drag
    ?finalDragger:Bool = true
  ):Interactible {
    // var initialOA:Float = 0;
    var initialOA = [obj.x, obj.y, obj.z][axisIdx];
    var initialH:Float = 0;
    var currentOA:Float = 0;
    var axis = null;
    var initialX:Int = 0;
    var initialY:Int = 0;
    var held = false;
    var ret = new Interactible(Press((k, t) -> switch (k) {
      case Held:
        held = true;
        initialX = ren.mouseX;
        initialY = ren.mouseY;
        initialH = [obj.x, obj.y, obj.z][axisIdx];
        axis = obj.projectAxes()[axisIdx];
      case Released:
        currentOA = finish(currentOA);
        if (finalDragger) {
          switch (axisIdx) {
            case 0: obj.x = initialOA + dragger(currentOA);
            case 1: obj.y = initialOA + dragger(currentOA);
            case _: obj.z = initialOA + dragger(currentOA);
          }
        } else {
          switch (axisIdx) {
            case 0: obj.x = initialOA + currentOA;
            case 1: obj.y = initialOA + currentOA;
            case _: obj.z = initialOA + currentOA;
          }
        }
        held = false;
      case _:
    }), handle);
    ret.tf = _ -> {
      if (!held) return;
      var dx = ren.mouseX - initialX;
      var dy = ren.mouseY - initialY;
      var dAxis = dx * axis.x + dy * axis.y;
      currentOA = dAxis / (ren.cameraZoom * ren.cameraZoom) + initialH;
      switch (axisIdx) {
        case 0: obj.x = initialOA + dragger(currentOA);
        case 1: obj.y = initialOA + dragger(currentOA);
        case _: obj.z = initialOA + dragger(currentOA);
      }
    };
    ret.cursor = Drag;
    return ret;
  }

  public static function ticker(f:(delta:Float)->Void):Interactible {
    var ret = new Interactible(Tick, null);
    ret.tf = f;
    return ret;
  }

  public static function draggerLinear(f:Float):Float {
    return f;
  }

  public static function draggerMinMax(min:Float, max:Float, f:Float):Float {
    return f < min ? min : (f > max ? max : f);
  }

  public static function draggerStops(stops:Array<Float>):Float->Float {
    var lpos = 0.;
    var first = true;
    return f -> {
      if (first) {
        lpos = f;
        first = false;
      }
      lpos = (lpos * 9 + stops[draggerStopsF(stops, f)]) / 10;
    };
  }

  public static function draggerStopsF(stops:Array<Float>, f:Float):Int {
    var bestI = 0;
    var bestDist = 1000.;
    for (i in 0...stops.length) {
      var dist = Math.abs(f - stops[i]);
      if (dist < bestDist) {
        bestI = i;
        bestDist = dist;
      }
    }
    return bestI;
  }

  public var active:Bool = true;
  public var kind:IxKind;
  public var target:StackP;
  public var cursor:Null<Cursor>;
  public var tf:(delta:Float)->Void;

  public function new(kind:IxKind, target:StackP) {
    this.kind = kind;
    this.target = target;
    cursor = Active;
  }

  public inline function checkMouse(mx:Int, my:Int, tolerance:Int):Bool {
    return target != null && target.checkMouse(mx, my, tolerance);
  }

  public function tick(delta:Float):Void {
    if (tf != null) tf(delta);
  }
}

enum IxKind {
  Tick;
  Press(action:(kind:PressKind, target:StackP)->Void);
  // Drag(action:(ix:Int, iy:Int, cx:Int, cy:Int, target:StackP)->Void);
}
