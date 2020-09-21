/**
A Stack placed in the world.
 */
class StackP {
  public var active:Bool = true;

  public var stack:Stack;
  public var x:Float = 0;
  public var y:Float = 0;
  public var z:Float = 0;
  public var angle:Float = 0;

  public var tmpX:Float = 0;
  public var tmpY:Float = 0;
  public var tmpZ:Float = 0;
  public var tmpAngle:Float = 0;

  public var wX:Float = 0; // cache for checkMouse
  public var wY:Float = 0;
  public var wZ:Float = 0;
  public var wA:Float = 0;

  public var sub:Array<StackP> = [];
  public var layerAngles:Array<Float>;
  public var layerOffX:Array<Float>;
  public var layerOffY:Array<Float>;
  public var lowCutoff:Float = 0;

  public function new(stack:Stack) {
    this.stack = stack;
    layerAngles = [ for (i in 0...100) 0 ];
    layerOffX = [ for (i in 0...100) 0 ];
    layerOffY = [ for (i in 0...100) 0 ];
  }

  public function offset(x:Float, ?y:Float = 0, ?z:Float = 0, ?angle:Float = 0):Void {
    tmpX += x;
    tmpY += y;
    tmpZ += z;
    tmpAngle += angle;
  }

  public function resetTemp():Void {
    tmpX = 0;
    tmpY = 0;
    tmpZ = 0;
    tmpAngle = 0;
  }

  public function render(wX:Float, wY:Float, wZ:Float, wA:Float):Void {
    if (!active) return;
    this.wX = wX;
    this.wY = wY;
    this.wZ = wZ;
    this.wA = wA;
    for (layer in 0...stack.regions.length) {
      if (wZ + layer * stack.zDensity >= lowCutoff) ren.drawRegion(
        stack.regions[layer],
        wX + layerOffX[layer],
        wY + layerOffY[layer],
        wZ + layer * stack.zDensity,
        wA + layerAngles[layer],
        stack.zDensity
      );
    }
    if (sub.length == 0) return;
    for (s in sub) {
      var wc = Math.cos(wA);
      var ws = Math.sin(wA);
      var ox = (s.x + s.tmpX) * wc + (s.y + s.tmpY) * ws;
      var oy = -(s.x + s.tmpX) * ws + (s.y + s.tmpY) * wc;
      s.render(wX + ox, wY + oy, wZ + s.z + s.tmpZ, wA + s.angle + s.tmpAngle);
    }
  }

  public function projectAxes():Array<{x:Float, y:Float}> {
    var proj = [
      ren.project(0, 0, wX, wY, wZ, wA),
      ren.project(0, 0, wX + 100, wY, wZ, wA),
      ren.project(0, 0, wX, wY + 100, wZ, wA),
      ren.project(0, 0, wX, wY, wZ + 100, wA),
    ];
    function pp(p:{x:Float, y:Float}):{x:Float, y:Float} {
      return {
        x: (p.x - proj[0].x) / 100.,
        y: (p.y - proj[0].y) / 100.,
      };
    }
    return [ for (i in 1...4) pp(proj[i]) ];
  }

  public function checkMouse(mx:Int, my:Int, tolerance:Int):Bool {
    if (!active) return false;
    if (stack.side) {
      // project 4 corners
      var r0 = stack.regions[0];
      var rN = stack.regions[stack.regions.length - 1];
      var height = stack.regions.length * stack.zDensity;
      var proj = [
        ren.project(-r0.cx, 0, wX, wY, wZ, wA),
        ren.project(-r0.cx + r0.w, 0, wX, wY, wZ, wA),
      ];
      if (mx >= proj[0].x - tolerance && mx < proj[1].x + tolerance) {
        var grad = (proj[1].y - proj[0].y) / (proj[1].x - proj[0].x);
        var line = proj[0].y + grad * (mx - proj[0].x);
        if (my <= line + tolerance && my >= line - height * ren.cameraTilt * ren.cameraZoom - tolerance) {
          return true;
        }
      } else if (stack.doubleSided && mx >= proj[1].x - tolerance && mx < proj[0].x + tolerance) {
        var grad = (proj[0].y - proj[1].y) / (proj[0].x - proj[1].x);
        var line = proj[1].y + grad * (mx - proj[1].x);
        if (my <= line + tolerance && my >= line - height * ren.cameraTilt * ren.cameraZoom - tolerance) {
          return true;
        }
      }
    } else {
      // TODO
    }
    return false;
  }
}
