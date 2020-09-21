class Ui {
  public var active:Bool = true;
  public var x:Int;
  public var y:Int;
  public var w:Int;
  public var h:Int;
  public var regionId:String;
  public var regionSub:Int = 0;
  public var region:Region;
  public var region2:Region;
  public var cursor:Null<Cursor>;

  public function new(x:Int, y:Int, region:Region) {
    this.x = x;
    this.y = y;
    this.region = region;
    w = 16;
    h = 16;
  }

  public function checkMouse(mx:Int, my:Int):Bool {
    return mx >= x && mx < x + w && my >= y && my < y + h;
  }

  public function mouse(k:PressKind):Void {
    // override
  }

  public function hover(h:Bool):Void {
    // override
  }

  public function tick():Void {
    // override
  }
}

class Button extends Ui {
  public var held:Bool = false;
  public var over:Bool = false;
  public var f:(Button)->Void;

  public function new(x:Int, y:Int, region:Region, f:(Button)->Void) {
    super(x, y, region);
    cursor = Active;
    this.f = f;
  }

  override public function mouse(k:PressKind):Void {
    switch (k) {
      case Held: held = true;
      case Released: held = false;
      case Pressed: f(this);
    }
  }

  override public function hover(h:Bool):Void {
    over = h;
  }
}

class Area extends Ui {
  public var held:Bool = false;
  public var f:()->Void;

  public function new(x:Int, y:Int, w:Int, h:Int, f:()->Void, cursor:Cursor) {
    super(x, y, null);
    this.w = w;
    this.h = h;
    this.f = f;
    this.cursor = cursor;
  }

  override public function mouse(k:PressKind):Void {
    switch (k) {
      case Held: held = true;
      case Released: held = false;
      case _:
    }
  }

  override public function tick():Void {
    if (held)
      f();
  }
}
