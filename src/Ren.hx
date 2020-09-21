class Ren {
  public static inline final W:Int = 300;
  public static inline final H:Int = 240;
  public static inline final WH:Int = 300 >> 1;
  public static inline final HH:Int = 240 >> 1;

  public var canvas:js.html.CanvasElement;

  // rendering
  public var vertexCount:Int;
  public var surf:Surface;
  public var bufferIndex:Buffer;
  public var bufferPosition:Buffer;
  public var bufferOffset:Buffer;
  public var bufferAngle:Buffer;
  public var bufferUV:Buffer;
  public var uniformCameraPosition:Uniform;
  public var uniformCameraAngle:Uniform;
  public var uniformWave:Uniform;

  // camera
  public static inline final CAMERA_SMOOTH_X = 10;
  public static inline final CAMERA_SMOOTH_Y = 10;
  public static inline final CAMERA_SMOOTH_Z = 10;
  public static inline final CAMERA_SMOOTH_ANGLE = 10;
  public static inline final CAMERA_SMOOTH_TILT = 10;
  public static inline final CAMERA_SMOOTH_ZOOM = 10;
  public var cameraX:Float = 0; // in world coords
  public var cameraY:Float = 0;
  public var cameraZ:Float = 0;
  public var cameraAngle:Float = 0; // in radians
  public var cameraTilt:Float = 0.5; // 0..1
  public var cameraTiltOpp:Float = 1; // 1..0
  public var cameraZoom:Float = 2;
  public var cameraTX:Float = 0; // targets
  public var cameraTY:Float = 0;
  public var cameraTZ:Float = 48.;
  public var cameraTAngle:Float = 0.0;
  public var cameraTTilt:Float = 0.5;
  public var cameraTZoom:Float = 2;
  public var cameraInstances:Int = 1;

  public var mouseX:Int = 0;
  public var mouseY:Int = 0;

  public var ship:StackP;

  //var dbgMouse:String->Void;
  public var message:String = null;
  //public var dbgMC:String->Void;

  static final Q = Math.PI / 2;
  static final P = Math.PI;

  public function new(canvas:js.html.CanvasElement) {
    this.canvas = canvas;
    surf = new Surface({
      el: canvas,
      buffers: [
        bufferPosition = new Buffer("aPosition", F32, 4),
        bufferOffset = new Buffer("aOffset", F32, 2),
        bufferAngle = new Buffer("aAngle", F32, 1),
        bufferUV = new Buffer("aUV", F32, 2),
      ],
      uniforms: [
        uniformCameraPosition = new Uniform("uCameraPosition", 4),
        uniformCameraAngle = new Uniform("uCameraAngle", 3),
        uniformWave = new Uniform("uWave", 2),
      ],
    });
    bufferIndex = surf.indexBuffer;
    Main.aShade.loadSignal.on(asset -> {
      surf.loadProgram(
        asset.pack["common.c"].text + asset.pack["vert.c"].text,
        asset.pack["common.c"].text + asset.pack["frag.c"].text
      );
      Region.init(asset.pack["proto.json"].text);
    });
    Main.aPng.loadSignal.on(asset -> {
      surf.updateTexture(0, asset.pack["proto.png"].image);
    });
    //dbgMouse = Debug.text("Mouse");
    //dbgMC = Debug.text("Check");
    Main.input.mouse.move.on(e -> mouseMove(Std.int(e.x) >> 1, Std.int(e.y) >> 1));
    Main.input.mouse.down.on(e -> mouseDown(Std.int(e.x) >> 1, Std.int(e.y) >> 1));
    Main.input.mouse.up.on(e -> mouseUp(Std.int(e.x) >> 1, Std.int(e.y) >> 1));
    //Debug.button("zoom out", () -> cameraTZoom = 1);
    //Debug.button("zoom in", () -> cameraTZoom = 2);
    //Debug.button("zoom innn", () -> cameraTZoom = 4);
  }

  var activeUiDetail:Ui;

  public var animations:Array<{prog:Int, len:Int, f:Int->Void, forbidden:Bool}> = [];

  public function start():Void {
    activeUi = [
      activeUiDetail = new Ui.Area(0, 0, W, H, () -> unzoomDetail(), GoDown),
      new Ui.Button(W - 32, 0, Region.REGION_STACKS["ui"][0], b -> {
        Sfx.toggle();
        b.region2 = (Sfx.enabled ? null : Region.REGION_STACKS["ui"][2]);
      }),
      new Ui.Button(W - 16, 0, Region.REGION_STACKS["ui"][1], b -> {
        Sfx.toggleM();
        b.region2 = (Sfx.enabledM ? null : Region.REGION_STACKS["ui"][2]);
      }),
      new Ui.Area(0, 0, 20, H, () -> cameraTAngle += 0.05, TurnLeft),
      new Ui.Area(W - 20, 0, 20, H, () -> cameraTAngle -= 0.05, TurnRight),
      new Ui.Area(0, 0, W, 20, () -> cameraTTilt -= 0.05, GoUp),
      new Ui.Area(0, H - 20, W, 20, () -> cameraTTilt += 0.05, GoDown),
    ];
    activeUiDetail.active = false;

    ship = Stack.get("base").place(0, 0, 0, 0);
    ship.sub.push(new StackP(new Stack("sea", [{
      tx: -100,
      ty: -100,
      tw: 1,
      th: 1,
      w: 1024,
      h: 1024,
      cx: 512,
      cy: 512,
    }])));
    ship.sub.push(objMap["chimney1"] = Stack.get("chimney").place(9, 0, 14, 0));
    ship.sub.push(objMap["chimney2"] = Stack.get("chimney").place(-23, 0, 35, 0));
    // stern
    ship.sub.push(objMap["stern"] = Stack.get("stern").place(-32, 0, 32, 0));
    objMap["stern"].sub.push(objMap["stern.left"] = Stack.get("sternL").place(0, -20, 0, 0));
    objMap["stern"].sub.push(objMap["stern.right"] = Stack.get("sternR").place(0, 20, 0, 0));
    objMap["stern.left"].sub.push(objMap["stern.window3"] = Stack.get("sidewindow").place(9, -7.5, 3, P));
    objMap["stern.left"].sub.push(objMap["stern.window4"] = Stack.get("sidewindow").place(-8, -7.5, 3, P));
    objMap["stern.left"].sub.push(objMap["stern.left.door"] = Stack.get("sidedoor").place(-8, 12, 3, 0));
    objMap["stern.right"].sub.push(objMap["stern.window1"] = Stack.get("sidewindow").place(9, 7.5, 3, 0));
    objMap["stern.right"].sub.push(objMap["stern.window2"] = Stack.get("sidewindow").place(-8, 7.5, 3, 0));
    objMap["stern.right"].sub.push(objMap["stern.right.door"] = Stack.get("sidedoor").place(-8, -12, 3, P));
    // substern
    objMap["stern"].sub.push(objMap["stern.left.sub"] = Stack.get("substernR").place(0, -18, 0, 0));
    objMap["stern.left.sub"].sub.push(objMap["stern.left.subcart"] = Stack.get("substerncart").place(2, 0, 2, 0));
    objMap["stern.left.sub"].active = false;
    objMap["stern"].sub.push(objMap["stern.right.sub"] = Stack.get("substernL").place(0, 18, 0, 0));
    objMap["stern.right.sub"].sub.push(objMap["stern.right.subcart"] = Stack.get("substerncart").place(2, 0, 2, 0));
    objMap["stern.right.sub"].active = false;
    // poles
    objMap["stern.left"].sub.push(objMap["pole.left"] = Stack.get("pole").place(-12, 2, -64, 0));
    objMap["pole.left"].active = false;
    objMap["pole.left"].lowCutoff = 32;
    objMap["stern.right"].sub.push(objMap["pole.right"] = Stack.get("pole").place(-12, -2, -64, 0));
    objMap["pole.right"].active = false;
    objMap["pole.right"].lowCutoff = 32;
    for (i in 0...4) {
      objMap["pole.left"].sub.push(objMap['pole.left.tile$i'] = Stack.get("polelight0").place(6, 0, 12 + i * 14, Q));
      objMap['pole.left.tile$i'].lowCutoff = 32;
      objMap["pole.right"].sub.push(objMap['pole.right.tile$i'] = Stack.get("polelight0").place(6, 0, 12 + i * 14, Q));
      objMap['pole.right.tile$i'].lowCutoff = 32;
    }
    // stern2
    ship.sub.push(Stack.get("stern2support").place(-58, 0, 32, 0));
    ship.sub.push(objMap["stern2"] = Stack.get("stern2").place(-56, 0, 62, Q));
    objMap["stern2"].sub.push(objMap["stern2.window1"] = Stack.get("sidewindowdark").place(-11, -10, 0, P));
    objMap["stern2"].sub.push(objMap["stern2.window2"] = Stack.get("sidewindowdark").place(0, -10, 0, P));
    objMap["stern2"].sub.push(objMap["stern2.window3"] = Stack.get("sidewindowdark").place(11, -10, 0, P));
    objMap["stern2"].sub.push(objMap["stern2.msg"] = Stack.get("stern2msg").place(0, 5, 0, 0));
    Puzzle.start();
    var deltaC = 0.0;
    Glewb.rate(delta -> {
      if (Main.aPng.loading || Main.aShade.loading)
        return;
      deltaC += delta;
      if (deltaC >= 15) {
        surf.render(0xaebdd6, () -> {
          vertexCount = 0;
          tick(16.66667);
        });
        deltaC -= 16.66667;
      }
    });
  }

  public var objMap:Map<String, StackP> = [];
  public var activeIx:Array<Interactible> = [];
  public var activeUi:Array<Ui> = [];

  public function mouseIx(mx:Int, my:Int, tolerance:Int):Null<Interactible> {
    if (animations.length > 0) return null;
    for (ix in activeIx) {
      if (ix.active && ix.checkMouse(mx, my, tolerance))
        return ix;
    }
    return null;
  }

  public function mouseUi(mx:Int, my:Int):Null<Ui> {
    for (ui in activeUi) {
      if (ui.active && ui.checkMouse(mx, my))
        return ui;
    }
    return null;
  }

  public var mOverUi:Ui;
  public var mHeldUi:Ui;
  public var mOverIx:Interactible;
  public var mHeldIx:Interactible;

  public function mouseMove(mx:Int, my:Int):Void {
    mouseX = mx;
    mouseY = my;
    var ui = mouseUi(mx, my);
    if (ui != mOverUi) {
      if (mOverUi != null) {
        mOverUi.hover(false);
      }
      mOverUi = ui;
      if (mOverUi != null) {
        mOverUi.hover(true);
      }
    }
    mOverIx = mOverUi != null ? null : mouseIx(mx, my, 0);
  }

  public function mouseDown(mx:Int, my:Int):Void {
    var ui = mouseUi(mx, my);
    if (ui != mHeldUi) {
      if (mHeldUi != null) {
        mHeldUi.mouse(Released);
      }
      mHeldUi = ui;
      if (mHeldUi != null) {
        mHeldUi.mouse(Held);
      }
    }
    var ix = ui != null ? null : mouseIx(mx, my, 0);
    if (ix != mHeldIx) {
      if (mHeldIx != null) switch (mHeldIx.kind) {
        case Press(f): f(Released, mHeldIx.target);
        case _:
      }
      mHeldIx = ix;
      if (mHeldIx != null) switch (mHeldIx.kind) {
        case Press(f): f(Held, mHeldIx.target);
        case _:
      }
    }
  }

  public function mouseUp(mx:Int, my:Int):Void {
    var ui = mouseUi(mx, my);
    if (ui != null && ui == mHeldUi) {
      mHeldUi.mouse(Pressed);
    }
    if (mHeldUi != null) {
      Sfx.play("Click", 0.02);
      mHeldUi.mouse(Released);
    }
    /*var ix = ui != null ? null : mouseIx(mx, my, 0);
    if (ix != null) switch (ix.kind) {
      case Press(f) if (ix == mHeldIx): f(Pressed, ix.target);
      case _:
    }*/
    if (mHeldIx != null) switch (mHeldIx.kind) {
      case Press(f):
        if (mHeldIx.checkMouse(mx, my, 4)) f(Pressed, mHeldIx.target);
        f(Released, mHeldIx.target);
      case _:
    }
    mHeldUi = null;
    mHeldIx = null;
  }

  public var cameraDetail:StackP = null;
  public var cameraZBX:Float = 0; // zoom backups
  public var cameraZBY:Float = 0;
  public var cameraZBZ:Float = 0;
  public var cameraZBAngle:Float = 0;
  public var cameraZBTilt:Float = 0;
  public var cameraZBZoom:Float = 0;

  public function zoomDetail(obj:StackP):Void {
    if (cameraDetail == null) {
      cameraZBX = cameraTX;
      cameraZBY = cameraTY;
      cameraZBZ = cameraTZ;
      cameraZBAngle = cameraTAngle;
      cameraZBTilt = cameraTTilt;
      cameraZBZoom = cameraTZoom;
    }
    activeUiDetail.active = true;
    cameraDetail = obj;
    cameraTX = obj.wX;
    cameraTY = obj.wY;
    cameraTZ = obj.wZ;
    cameraTAngle = -obj.wA;
    cameraTTilt = obj.stack.side ? .92 : .5;
    cameraTZoom = 3.5;
  }

  public function unzoomDetail():Void {
    if (cameraDetail != null) {
      cameraTX = cameraZBX;
      cameraTY = cameraZBY;
      cameraTZ = cameraZBZ;
      cameraTAngle = cameraZBAngle;
      cameraTTilt = cameraZBTilt;
      cameraTZoom = cameraZBZoom;
      cameraDetail = null;
    }
    activeUiDetail.active = false;
  }

  public function quadInOut(x:Float):Float {
    return (x < .5
      ? 2 * x * x
      : -.5 * (x = 2 * x - 2) * x + 1);
  }

  var waveX:Float = 0;
  var waveY:Float = 0;

  public function tick(delta:Float):Void {
    if (animations.length > 0) {
      var a = animations[0];
      a.f(++a.prog);
      if (a.prog >= a.len) animations.shift();
      mHeldIx = mOverIx = null;
    }
    cameraX = (cameraX * CAMERA_SMOOTH_X + cameraTX) / (1 + CAMERA_SMOOTH_X);
    cameraY = (cameraY * CAMERA_SMOOTH_Y + cameraTY) / (1 + CAMERA_SMOOTH_Y);
    cameraZ = (cameraZ * CAMERA_SMOOTH_Z + cameraTZ) / (1 + CAMERA_SMOOTH_Z);
    while (cameraTAngle > Math.PI) cameraTAngle -= Math.PI * 2;
    while (cameraTAngle < -Math.PI) cameraTAngle += Math.PI * 2;
    while (cameraAngle > Math.PI) cameraAngle -= Math.PI * 2;
    while (cameraAngle < -Math.PI) cameraAngle += Math.PI * 2;
    var distAngle1 = Math.abs(cameraTAngle - cameraAngle);
    var distAngle2 = Math.PI * 2 - distAngle1;
    if (distAngle1 < distAngle2) {
      cameraAngle = (cameraAngle * CAMERA_SMOOTH_ANGLE + cameraTAngle) / (1 + CAMERA_SMOOTH_ANGLE);
    } else if (cameraTAngle < cameraAngle) {
      cameraAngle = (cameraAngle * CAMERA_SMOOTH_ANGLE + (cameraTAngle + 2 * Math.PI)) / (1 + CAMERA_SMOOTH_ANGLE);
    } else {
      cameraAngle = (cameraAngle * CAMERA_SMOOTH_ANGLE + (cameraTAngle - 2 * Math.PI)) / (1 + CAMERA_SMOOTH_ANGLE);
    }
    cameraTTilt = cameraTTilt.clamp(0, .92);
    cameraTilt = (cameraTilt * CAMERA_SMOOTH_TILT + cameraTTilt) / (1 + CAMERA_SMOOTH_TILT);
    cameraZoom = (cameraZoom * CAMERA_SMOOTH_ZOOM + cameraTZoom) / (1 + CAMERA_SMOOTH_ZOOM);
    cameraInstances = Math.round(1 + (cameraTilt * cameraZoom) * 2);
    cameraTiltOpp = Math.sqrt(1 - cameraTilt * cameraTilt);

    uniformCameraPosition.writeF32([cameraX, cameraY, cameraZ, cameraZoom]);
    uniformCameraAngle.writeF32([cameraAngle, cameraTilt, cameraTiltOpp]);
    uniformWave.writeF32([waveX, waveY]);
    waveX += 0.037;
    waveY += 0.065;
    ship.render(0, 0, 0, 0);
    for (ix in activeIx) {
      ix.tick(delta);
    }
    for (ui in activeUi) {
      ui.tick();
      if (ui.region != null) drawRegion2D(ui.region, ui.x, ui.y);
      if (ui.region2 != null) drawRegion2D(ui.region2, ui.x, ui.y);
    }
    var cursor:Cursor = Normal;
    if (mHeldUi != null) {
      if (mHeldUi.cursor != null) cursor = mHeldUi.cursor;
    } else if (mOverUi != null) {
      if (mOverUi.cursor != null) cursor = mOverUi.cursor;
    } else if (animations.length > 0 && animations[0].forbidden) {
      cursor = Forbidden;
    } else if (mHeldIx != null) {
      if (mHeldIx.cursor != null) cursor = mHeldIx.cursor;
    } else if (mOverIx != null) {
      if (mOverIx.cursor != null) cursor = mOverIx.cursor;
    }
    if (message != null) {
      Text.render(8, 8, message);
    }
    drawRegion2D(Region.REGION_STACKS["cursor"][cursor], mouseX - 2, mouseY - 2);
  }

  public function drawRaw(x:Int, y:Int, tx:Int, ty:Int, tw:Int, th:Int):Void {
    // 4 vertices
    // 0 1
    // 2 3

    // CW triangles: 0-1-2 and 1-3-2
    bufferIndex.writeUI16(vertexCount);
    bufferIndex.writeUI16(vertexCount + 1);
    bufferIndex.writeUI16(vertexCount + 2);
    bufferIndex.writeUI16(vertexCount + 1);
    bufferIndex.writeUI16(vertexCount + 3);
    bufferIndex.writeUI16(vertexCount + 2);

    // region's "centre" is the same for all 4 vertices
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(-100);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(-100);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(-100);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(-100);
    bufferPosition.writeF32(0);

    // different XY offset for each vertex
    bufferOffset.writeF32(x);
    bufferOffset.writeF32(y);
    bufferOffset.writeF32(x + tw);
    bufferOffset.writeF32(y);
    bufferOffset.writeF32(x);
    bufferOffset.writeF32(y + th);
    bufferOffset.writeF32(x + tw);
    bufferOffset.writeF32(y + th);

    // UV
    bufferUV.writeF32(tx);
    bufferUV.writeF32(ty);
    bufferUV.writeF32(tx + tw);
    bufferUV.writeF32(ty);
    bufferUV.writeF32(tx);
    bufferUV.writeF32(ty + th);
    bufferUV.writeF32(tx + tw);
    bufferUV.writeF32(ty + th);

    vertexCount += 4;

    if (vertexCount > 1024) {
      surf.renderFlush();
      vertexCount = 0;
    }
  }

  public function drawRegion2D(region:Region, x:Int, y:Int):Void {
    // 4 vertices
    // 0 1
    // 2 3

    // CW triangles: 0-1-2 and 1-3-2
    bufferIndex.writeUI16(vertexCount);
    bufferIndex.writeUI16(vertexCount + 1);
    bufferIndex.writeUI16(vertexCount + 2);
    bufferIndex.writeUI16(vertexCount + 1);
    bufferIndex.writeUI16(vertexCount + 3);
    bufferIndex.writeUI16(vertexCount + 2);

    // region's "centre" is the same for all 4 vertices
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(-100);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(-100);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(-100);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(-100);
    bufferPosition.writeF32(0);

    // different XY offset for each vertex
    bufferOffset.writeF32(x/* - region.cx*/);
    bufferOffset.writeF32(y/* - region.cy*/);
    bufferOffset.writeF32(x/* - region.cx*/ + region.w);
    bufferOffset.writeF32(y/* - region.cy*/);
    bufferOffset.writeF32(x/* - region.cx*/);
    bufferOffset.writeF32(y/* - region.cy*/ + region.h);
    bufferOffset.writeF32(x/* - region.cx*/ + region.w);
    bufferOffset.writeF32(y/* - region.cy*/ + region.h);

    // UV
    bufferUV.writeF32(region.tx);
    bufferUV.writeF32(region.ty);
    bufferUV.writeF32(region.tx + region.tw);
    bufferUV.writeF32(region.ty);
    bufferUV.writeF32(region.tx);
    bufferUV.writeF32(region.ty + region.th);
    bufferUV.writeF32(region.tx + region.tw);
    bufferUV.writeF32(region.ty + region.th);

    vertexCount += 4;

    if (vertexCount > 1024) {
      surf.renderFlush();
      vertexCount = 0;
    }
  }

  public inline function drawRegion(region:Region, wX:Float, wY:Float, wZ:Float, wA:Float, zDensity:Float):Void {
    // 4 vertices
    // 0 1
    // 2 3

    for (i in 0...cameraInstances) {
      var instanceZ = (zDensity / cameraInstances) * i;

      // CW triangles: 0-1-2 and 1-3-2
      bufferIndex.writeUI16(vertexCount);
      bufferIndex.writeUI16(vertexCount + 1);
      bufferIndex.writeUI16(vertexCount + 2);
      bufferIndex.writeUI16(vertexCount + 1);
      bufferIndex.writeUI16(vertexCount + 3);
      bufferIndex.writeUI16(vertexCount + 2);

      // region's "centre" is the same for all 4 vertices
      bufferPosition.writeF32(wX);
      bufferPosition.writeF32(wY);
      bufferPosition.writeF32(wZ + instanceZ);
      bufferPosition.writeF32(wA);
      bufferPosition.writeF32(wX);
      bufferPosition.writeF32(wY);
      bufferPosition.writeF32(wZ + instanceZ);
      bufferPosition.writeF32(wA);
      bufferPosition.writeF32(wX);
      bufferPosition.writeF32(wY);
      bufferPosition.writeF32(wZ + instanceZ);
      bufferPosition.writeF32(wA);
      bufferPosition.writeF32(wX);
      bufferPosition.writeF32(wY);
      bufferPosition.writeF32(wZ + instanceZ);
      bufferPosition.writeF32(wA);

      // different XY offset for each vertex
      bufferOffset.writeF32(-region.cx);
      bufferOffset.writeF32(-region.cy);
      bufferOffset.writeF32(-region.cx + region.w);
      bufferOffset.writeF32(-region.cy);
      bufferOffset.writeF32(-region.cx);
      bufferOffset.writeF32(-region.cy + region.h);
      bufferOffset.writeF32(-region.cx + region.w);
      bufferOffset.writeF32(-region.cy + region.h);

      // UV
      bufferUV.writeF32(region.tx);
      bufferUV.writeF32(region.ty);
      bufferUV.writeF32(region.tx + region.tw);
      bufferUV.writeF32(region.ty);
      bufferUV.writeF32(region.tx);
      bufferUV.writeF32(region.ty + region.th);
      bufferUV.writeF32(region.tx + region.tw);
      bufferUV.writeF32(region.ty + region.th);

      vertexCount += 4;
    }

    if (vertexCount > 1024) {
      surf.renderFlush();
      vertexCount = 0;
    }
  }

  public function project(roX:Float, roY:Float, wX:Float, wY:Float, wZ:Float, wA:Float):{x:Float, y:Float} {
    var ms = Math.sin(wA); // model angles
    var mc = Math.cos(wA);
    var modelX = roX * mc + roY * ms; // model local
    var modelY = -roX * ms + roY * mc;
    var cs = Math.sin(cameraAngle); // camera angles
    var cc = Math.cos(cameraAngle);
    modelX += wX - cameraX;
    modelY += wY - cameraY;
    var worldX = modelX * cc + modelY * cs; // world coords
    var worldY = -modelX * cs + modelY * cc;
    return {
      x: Std.int((worldX * cameraZoom) + 0.5 + WH),
      y: Std.int(((
          (worldY * cameraTiltOpp) // top view
          + ((-wZ + cameraZ) * cameraTilt) // side view
        ) * cameraZoom) + 0.5 + HH)
    };
  }
}
