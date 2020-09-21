class Main {
  // assets
  public static var aShade:Asset;
  public static var aPng:Asset;
  public static var aWav:Asset;

  public static var input:Input;
  public static var ren:Ren;

  public static function main():Void window.onload = _ -> {
    var canvas = document.querySelector("canvas");
    #if ITCHIO
    js.Syntax.code("window.addEventListener('resize', {0}, {passive:true})", () -> {
      var vw:Int = js.Browser.window.innerWidth;
      var vh:Int = js.Browser.window.innerHeight;
      var aw:Int = vw;
      var ah:Int = vh;
      var ml:Int = 0;
      var mt:Int = 0;
      if (vw >= vh) { aw = Std.int((vh / 3) * 4); ml = Std.int((vw - aw) / 2); }
      else { ah = Std.int((vw / 4) * 3); mt = Std.int((vh - ah) / 2); }
      canvas.style.width = '${aw}px';
      canvas.style.height = '${ah}px';
      canvas.style.margin = '${mt}px 0 0 ${ml}px';
    });
    #end
    input = new Input(document.body, canvas);
    Debug.init();
    Debug.button("reload png", () -> aPng.reload());
    Debug.button("reload shade", () -> aShade.reload());
    aShade = Asset.load(null, "shade.glw");
    aPng = Asset.load(null, "png.glw");
    aWav = Asset.load(null, "wav.glw");
    aWav.loadSignal.on(_ -> Sfx.init());

    ren = new Ren(cast canvas);
    var loaded = 0;
    for (asset in [aPng, aShade, aWav]) asset.loadSignal.on(_ -> {
      loaded++;
      if (loaded == 3)
        ren.start();
    });
  };
}
