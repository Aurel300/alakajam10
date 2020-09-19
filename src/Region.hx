@:structInit
class Region {
  public static var REGIONS:Map<String, Region> = [];
  public static var REGION_STACKS:Map<String, Array<Region>> = [];

  public static function init(data:String):Void {
    var tr:haxe.DynamicAccess<Dynamic> = haxe.Json.parse(data);
    function process(id:String, v:Dynamic, sub:Bool):Array<Region> {
      var reg:Region = {
        x: v.x,
        y: v.y,
        w: v.w,
        h: v.h,
      };
      if (id.startsWith("Y")) {
        var n = Std.parseInt(id.split(" ")[0].substr(1));
        var regs = process(id.split(" ").slice(1).join(" "), v, true);
        var ret = [ for (i in 0...n) for (reg in regs) reg.offset(0, i * reg.h) ];
        if (sub) return ret;
        REGION_STACKS[id.split(" ").pop()] = ret;
        new Stack(id.split(" ").pop(), ret); // TODO: separate params for autostacks?
      } else if (id.startsWith("X")) {
        var n = Std.parseInt(id.split(" ")[0].substr(1));
        var regs = process(id.split(" ").slice(1).join(" "), v, true);
        var ret = [ for (i in 0...n) for (reg in regs) reg.offset(i * reg.w, 0) ];
        if (sub) return ret;
        REGION_STACKS[id.split(" ").pop()] = ret;
        new Stack(id.split(" ").pop(), ret);
      } else {
        if (sub) return [reg];
        REGIONS[id] = reg;
      }
      return [];
    }
    for (k => v in tr) process(k, v, false);
  }

  public final x:Int;
  public final y:Int;
  public final w:Int;
  public final h:Int;

  public function offset(ox:Int, oy:Int):Region {
    return {
      x: x + ox,
      y: y + oy,
      w: w,
      h: h
    };
  }

  public function render():Void {
    Main.draw(0, 0, x, y, w, h);
  }
}
