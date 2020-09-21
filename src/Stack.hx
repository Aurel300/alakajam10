/**
A "model", representing a set of PNG regions stacked one above the other for
faux-3D effect. One model = one instance of Stack; copies are achieved using
StackP.
 */
class Stack {
  public static var STACKS:Map<String, Stack> = [];

  public inline static function get(id:String):Stack {
    return STACKS[id];
  }

  public var id:String;
  public var regions:Array<Region>;
  public var zDensity:Float = 2;
  public var side:Bool = false;
  public var doubleSided:Bool = false;

  public function new(id:String, regions:Array<Region>) {
    STACKS[id] = this;
    this.id = id;
    this.regions = regions;
  }

  public function place(x:Float, y:Float, z:Float, angle:Float):StackP {
    var ret = new StackP(this);
    ret.x = x;
    ret.y = y;
    ret.z = z;
    ret.angle = angle;
    return ret;
  }
}
