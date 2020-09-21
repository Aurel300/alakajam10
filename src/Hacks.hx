class Hacks {
  public static inline function i(f:Float):Int {
    return js.Syntax.code("({0}|0)", f);
  }

  public static inline function clamp(f:Float, min:Float, max:Float):Float {
    return f < min ? min : (f > max ? max : f);
  }
}
