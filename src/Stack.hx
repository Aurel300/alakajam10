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

  public function new(id:String, regions:Array<Region>) {
    STACKS[id] = this;
    this.id = id;
    this.regions = regions;
  }

  public function render():Void {
    for (ri in 0...regions.length) {
      var layer = regions.length - ri - 1;
      regions[layer].render();
    }
  }

  //public function place():StackP { //?
  //  
  //}
}
