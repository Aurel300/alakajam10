@:structInit
class Region {
  public static var REGIONS:Map<String, Region> = [];
  public static var REGION_STACKS:Map<String, Array<Region>> = [];

  public static function init(data:String):Void {
    var tr:haxe.DynamicAccess<Dynamic> = haxe.Json.parse(data);
    function process(id:String, v:Dynamic, sub:Bool):Array<Region> {
      var lid = id.split(" ").pop();
      var reg:Region = {
        tx: v.x,
        ty: v.y,
        tw: v.w,
        th: v.h,
        w: v.w,
        h: v.h,
        cx: v.w / 2,
        cy: v.h / 2,
      };
      if (id.startsWith("YY")) {
        var regs = process(id.split(" ").slice(1).join(" "), v, true);
        var ret = [ for (i in 0...reg.h) for (reg in regs) reg.offset(0, reg.h - i - 1).resize(reg.tw, 1).resizeVisual(reg.tw, 2) ];
        if (sub) return ret;
        REGION_STACKS[lid] = ret;
        new Stack(lid, ret).side = true;
      } else if (id.startsWith("Y")) {
        var params = id.split(" ")[0].substr(1).split(",").map(Std.parseInt);
        var n = params[0];
        var offY = params.length > 1 ? params[1] : reg.h;
        var regs = process(id.split(" ").slice(1).join(" "), v, true);
        var ret = [ for (i in 0...n) for (reg in regs) reg.offset(0, i * offY) ];
        if (sub) return ret;
        REGION_STACKS[lid] = ret;
        new Stack(lid, ret);
        // TODO: separate params for autostacks?
      } else if (id.startsWith("X")) {
        var n = Std.parseInt(id.split(" ")[0].substr(1));
        var regs = process(id.split(" ").slice(1).join(" "), v, true);
        var ret = [ for (i in 0...n) for (reg in regs) reg.offset(i * reg.w, 0) ];
        if (sub) return ret;
        REGION_STACKS[lid] = ret;
        new Stack(lid, ret);
      } else {
        if (sub) return [reg];
        REGIONS[id] = reg;
      }
      return [];
    }
    for (k => v in tr) process(k, v, false);
    Stack.get("sidewindow").zDensity = 1.5;
    Stack.get("sidewindowdark").zDensity = 1.5;
    Stack.get("sidewindowdrag").zDensity = 1.5;
    Stack.get("substerncart").zDensity = 1;
    Stack.get("substerncart").doubleSided = true;
    var pi = 0;
    for (pat in [
      [0, 0, 0, 0, 0, 0], // 0
      [1, 0, 0, 0, 0, 0],
      [1, 1, 0, 0, 0, 0],
      [1, 1, 1, 0, 0, 0],
      [1, 1, 1, 1, 0, 0],
      [1, 1, 1, 1, 1, 0],
      [1, 1, 1, 1, 1, 1], // 6
      [0, 1, 1, 1, 1, 1],
      [0, 0, 1, 1, 1, 1],
      [0, 0, 0, 1, 1, 1],
      [0, 0, 0, 0, 1, 1],
      [0, 0, 0, 0, 0, 1], // 11
    ]) {
      REGION_STACKS['polelight$pi'] = [
        for (i in 0...6) REGION_STACKS[["polelightoff", "polelighton"][pat[i]]][i]
      ];
      new Stack('polelight$pi', REGION_STACKS['polelight$pi']).side = true;
      pi++;
    }
  }

  public final tx:Int;
  public final ty:Int;
  public final tw:Int;
  public final th:Int;
  public final w:Int;
  public final h:Int;
  public final cx:Float; // centre
  public final cy:Float;

  public function offset(ox:Int, oy:Int):Region {
    return {
      tx: tx + ox,
      ty: ty + oy,
      tw: tw,
      th: th,
      w: w,
      h: h,
      cx: cx,
      cy: cy,
    };
  }

  public function resize(tw:Int, th:Int):Region {
    return {
      tx: tx,
      ty: ty,
      tw: tw,
      th: th,
      w: tw,
      h: th,
      cx: tw / 2,
      cy: th / 2,
    };
  }

  public function resizeVisual(w:Int, h:Int):Region {
    return {
      tx: tx,
      ty: ty,
      tw: tw,
      th: th,
      w: w,
      h: h,
      cx: w / 2,
      cy: h / 2,
    };
  }
}
