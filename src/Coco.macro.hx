import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;

class Coco {
  public static function co(e:Expr):Expr {
    function walk(e:Expr) {
      return (switch (e.expr) {
        case ECall({expr: EConst(CIdent("wait"))}, [frames]):
          macro suspend((_, wakeup) -> ren.animations.push({
            prog: 0,
            len: $frames,
            f: prog -> {
              if (prog >= $frames) wakeup();
            },
            forbidden: true
          }));
        case ECall({expr: EConst(CIdent("animate"))}, args):
          var speed:Expr = null;
          while (args.length > 0) {
            if (!args[args.length - 1].expr.match(EBinop(OpAssignOp(OpAdd | OpSub), _, _))) {
              if (speed != null) throw "unexpected extra arg";
              speed = args.pop();
              continue;
            }
            break;
          }
          if (speed == null) {
            speed = macro 1.;
          }
          var initials = [];
          var progs = [];
          var offA:Expr = null;
          for (i in 0...args.length) {
            var a = args[i];
            switch (a.expr) {
              case EBinop(OpAssignOp(OpAdd), prop, off):
                offA = off;
                initials.push(prop);
                progs.push(macro $prop = initials[$v{i}] + $off * ren.quadInOut(prog / len));
              case EBinop(OpAssignOp(OpSub), prop, off):
                offA = off;
                initials.push(prop);
                progs.push(macro $prop = initials[$v{i}] - $off * ren.quadInOut(prog / len));
              case _: throw "unexpected arg";
            }
          }
          macro {
            var len:Int = Std.int(Math.ceil(Math.abs($offA) / $speed / globalSpeed));
            var initials:Array<Float> = $a{initials};
            suspend((_, wakeup) -> ren.animations.push({
              prog: 0,
              len: len,
              f: prog -> {
                $b{progs};
                if (prog >= len) wakeup();
              },
              forbidden: true
            }));
          };
        case _: e.map(walk);
      });
    }
    return pecan.Co.co(walk(e), macro null, macro null);
  }
}
