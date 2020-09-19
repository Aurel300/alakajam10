/**
A Stack placed in the world.
 */
class StackP {
  public var stack:Stack;
  public var x:Float = 0;
  public var y:Float = 0;
  public var angle:Float = 0;

  public function new(stack:Stack) {
    this.stack = stack;
  }

  public function render():Void {
    for (layer in 0...stack.regions.length) {
      stack.regions[layer].render();
    }
  }
}
