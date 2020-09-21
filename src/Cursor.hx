enum abstract Cursor(Int) from Int to Int {
  var Normal = 0;
  var Active;
  var Forbidden;
  var Drag;
  var TurnLeft;
  var TurnRight;
  var GoUp;
  var GoDown;
  var Zoom;
}
