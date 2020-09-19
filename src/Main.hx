class Main {
  public static inline final W:Int = 300;
  public static inline final H:Int = 240;
  public static inline final WH:Int = 300 >> 1;
  public static inline final HH:Int = 240 >> 1;

  // assets
  public static var aShade:Asset;
  public static var aPng:Asset;
  // public static var aWav:Asset;
  // public static var aMusic:Asset;
  public static var REGIONS:Map<String, Region>;

  public static var input:Input;
  public static var canvas:js.html.CanvasElement;

  // rendering
  public static var vertexCount:Int;
  public static var surf:Surface;
  public static var bufferIndex:Buffer;
  public static var bufferPosition:Buffer;
  public static var bufferUV:Buffer;
  public static var texW:Int = 128;
  public static var texH:Int = 128;

  public static function main():Void window.onload = _ -> {
    canvas = cast document.querySelector("canvas");
    input = new Input(document.body, canvas);
    //Save.init();
    Debug.init();
    Debug.button("reload png", () -> aPng.reload());
    Debug.button("reload shade", () -> aShade.reload());
    aShade = Asset.load(null, "shade.glw");
    aPng = Asset.load(null, "png.glw");
    //aWav = Asset.load(null, "wav.glw");
    //aMusic = Asset.load(null, "music.glw");
    //Music.init();
    //var inited = false;

    surf = new Surface({
      el: canvas,
      buffers: [
        bufferPosition = new Buffer("aPosition", F32, 3),
        bufferUV = new Buffer("aUV", F32, 2)
      ],
      uniforms: []
    });
    bufferIndex = surf.indexBuffer;
    aShade.loadSignal.on(asset -> {
      surf.loadProgram(asset.pack["vert.c"].text, asset.pack["frag.c"].text);
      Region.init(asset.pack["proto.json"].text);
    });
    aPng.loadSignal.on(asset -> {
      surf.updateTexture(0, asset.pack["proto.png"].image);
    });
    var loaded = 0;
    for (asset in [aPng, aShade]) asset.loadSignal.on(_ -> {
      loaded++;
      if (loaded == 2)
        init();
    });
  };

  static function init():Void {
    Glewb.rate(delta -> {
      if (Main.aPng.loading || Main.aShade.loading)
        return;
      surf.render(0x5692b5, () -> {
        vertexCount = 0;
        tick(delta);
      });
    });
  }

  static function tick(delta:Float):Void {
    Stack.get("proto").render();
  }

  public static function draw(x:Int, y:Int, tx:Int, ty:Int, tw:Int, th:Int, ?flip:Bool = false, ?vflip:Bool = false):Void {
    bufferIndex.writeUI16(vertexCount);
    bufferIndex.writeUI16(vertexCount + 1);
    bufferIndex.writeUI16(vertexCount + 2);
    bufferIndex.writeUI16(vertexCount + 1);
    bufferIndex.writeUI16(vertexCount + 3);
    bufferIndex.writeUI16(vertexCount + 2);

    var gx1:Float = ((flip ? x + tw : x) - WH) / WH;
    var gx2:Float = ((flip ? x : x + tw) - WH) / WH;
    var gy1:Float = (H - (vflip ? y + th : y) - HH) / HH;
    var gy2:Float = ((H - (vflip ? y : y + th)) - HH) / HH;

    bufferPosition.writeF32(gx1);
    bufferPosition.writeF32(gy1);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(gx2);
    bufferPosition.writeF32(gy1);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(gx1);
    bufferPosition.writeF32(gy2);
    bufferPosition.writeF32(0);
    bufferPosition.writeF32(gx2);
    bufferPosition.writeF32(gy2);
    bufferPosition.writeF32(0);

    var gtx1 = (tx) / texW;
    var gtx2 = (tx + tw) / texW;
    var gty1 = (ty) / texH;
    var gty2 = (ty + th) / texH;

    bufferUV.writeF32(gtx1);
    bufferUV.writeF32(gty1);
    bufferUV.writeF32(gtx2);
    bufferUV.writeF32(gty1);
    bufferUV.writeF32(gtx1);
    bufferUV.writeF32(gty2);
    bufferUV.writeF32(gtx2);
    bufferUV.writeF32(gty2);

    vertexCount += 4;
    if (vertexCount > 400) {
      surf.renderFlush();
      vertexCount = 0;
    }
  }
}
