class Sfx {
  public static var rng = new Chance(0xDEAFF00D);
  public static var enabled:Bool = true;
  public static var enabledM:Bool = true;

  public static function toggle():Void {
    enabled = !enabled;
    if (!enabled) {
      for (id => asset in Asset.ids) {
        if (id.endsWith(".mp3") && id != "Theme.mp3") {
          Asset.ids[id].sound.stop();
        }
      }
    }
  }

  public static function toggleM():Void {
    enabledM = !enabledM;
    Asset.ids["Theme.mp3"].sound.mute(!enabledM);
  }

  public static function init():Void {
    Asset.ids["Theme.mp3"].sound.play();
    Asset.ids["Theme.mp3"].sound.loop(true);
    Asset.ids["Theme.mp3"].sound.volume(.65);
    Asset.ids["Click.mp3"].sound.volume(.4);
    Asset.ids["MechanicDeepHumm.mp3"].sound.volume(.5);
  }

  static var nullSound:{stop:()->Void, fade:(len:Int)->Void} = {stop: () -> {}, fade: _ -> {}};

  public static function play(id:String, ?varyPitch:Float = 0.2):{stop:()->Void, fade:(len:Int)->Void} {
    if (!enabled)
      return nullSound;
    var channel = Asset.ids[id + ".mp3"].sound.play();
    if (varyPitch > 0)
      Asset.ids[id + ".mp3"].sound.rate(rng.rangeF(1.0 - varyPitch, 1.0 + varyPitch), channel);
    return {
      stop: () -> Asset.ids[id + ".mp3"].sound.stop(channel),
      fade: (len:Int) -> Asset.ids[id + ".mp3"].sound.fade(1., 0., len, channel),
    };
  }
}
