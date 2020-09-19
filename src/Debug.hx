import js.html.*;

class Debug {
  #if AKJ_DEBUG
  public static var ui:Element;
  #end

  public static function init():Void {
    #if AKJ_DEBUG
    ui = document.querySelector("#debug");
    #end
  }

  public static function button(label:String, f:Void->Void):Void {
    #if AKJ_DEBUG
    var hold = document.createElement("span");
    hold.innerHTML = '<a href="#">$label</a>';
    hold.querySelector("a").addEventListener("click", f);
    ui.appendChild(hold);
    #end
  }

  public static function text(label:String):(String->Void) {
    #if AKJ_DEBUG
    var hold = document.createElement("span");
    hold.innerHTML = '$label: <b></b>';
    var cont = hold.querySelector("b");
    ui.appendChild(hold);
    return txt -> cont.innerText = txt;
    #else
    return _ -> {};
    #end
  }
}
