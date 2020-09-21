class Puzzle {
  static final Q = Math.PI / 2;
  static final QQ = Math.PI / 4;
  static final P = Math.PI;
  static var CHIMNEY1 = [0, 2, 3, 1, 0, 2];
  static var CHIMNEY2 = [3, 2, 1, 0, 0, 1];

  public static function start():Void {
    inline function sg(id:String):Stack {
      return Stack.get(id);
    }
    inline function om(id:String):StackP {
      return ren.objMap[id];
    }
    function addGroup(g:Array<Interactible>):Array<Interactible> {
      for (ix in g)
        ren.activeIx.push(ix);
      return g;
    }
    function removeGroup(g:Array<Interactible>):Void {
      for (ix in g)
        ren.activeIx.remove(ix);
    }
    function stopIx(on:StackP):Void {
      ren.activeIx = ren.activeIx.filter(ix -> ix.target != on);
    }
    function toggleStack(cur:StackP, off:Stack, on:Stack):Bool {
      if (cur.stack == off) {
        cur.stack = on;
        return true;
      }
      cur.stack = off;
      return false;
    }
    var sw0 = sg("sidewindowdark");
    var sw1 = sg("sidewindow");
    function group1(_, wakeup:()->Void):Void {
      var windows = 0;
      var g:Array<Interactible> = null;
      g = addGroup([ for (i in 1...4)
        Interactible.button(t -> {
          Sfx.play("LampOnOff");
          windows += toggleStack(t, sw0, sw1) ? 1 : -1;
          if (windows == 3) {
            removeGroup(g);
            Sfx.play("Success", 0);
            wakeup();
          }
        }, 0, 1, om('stern2.window$i'))
      ]);
    }
    function windowSeq(sequence:Array<Int>, stayOn:Bool):(Any, ()->Void)->Void {
      return (_, wakeup:()->Void) -> {
        for (i in 1...5) om('stern.window$i').stack = sw0;
        var windows = 0;
        var g:Array<Interactible> = null;
        g = addGroup([ for (i in 1...5)
          Interactible.button(t -> {
            Sfx.play("LampOnOff");
            if (stayOn) {
              if (i == sequence[windows]) {
                t.stack = sw1;
                windows++;
              } else {
                for (i in 1...5) om('stern.window$i').stack = sw0;
                windows = 0;
              }
            } else {
              t.stack = sw1;
              ren.animations.push({prog: 0, len: 10, f: prog -> {
                if (prog >= 10) t.stack = sw0;
              }, forbidden: false});
              if (i == sequence[windows]) {
                windows++;
              } else {
                windows = (i == sequence[0] ? 1 : 0);
              }
            }
            if (windows == sequence.length) {
              removeGroup(g);
              Sfx.play("Success", 0);
              wakeup();
            }
          }, 0, i < 3 ? -1 : 1, om('stern.window$i'))
        ]);
      }
    }
    var group2 = windowSeq([3, 2, 1, 4], true);
    function group3(_, wakeup:()->Void):Void {
      var scalePos = 0.;
      var leftSet = false;
      var rightSet = false;
      var done = false;
      var g:Array<Interactible> = null;
      var ph = 0;
      g = addGroup([Interactible.drag(
        1,
        f -> {
          if (done) return 0.;
          var psp = scalePos;
          scalePos = (scalePos + f * .05).clamp(-26, 26);
          if (psp != scalePos && ph++ % 17 == 0) Sfx.play("Metal4", .05);
          om("stern.left").tmpY = (scalePos * .4).clamp(-10, 0);
          om("stern.left.sub").tmpY = (scalePos * .4).clamp(-10, 0);
          om("stern.left").tmpZ = scalePos;
          om("stern.left.sub").tmpZ = scalePos.clamp(-26, 0);
          g[1].active = scalePos > 20;
          om("stern.right").tmpY = (scalePos * .4).clamp(0, 10);
          om("stern.right.sub").tmpY = (scalePos * .4).clamp(0, 10);
          om("stern.right").tmpZ = -scalePos;
          om("stern.right.sub").tmpZ = (-scalePos).clamp(-26, 0);
          g[2].active = scalePos < -20;
          Interactible.draggerMinMax(-5, 5, f);
        },
        f -> 0.,
        om("stern2"),
        om("stern2.window2")
      ), Interactible.drag(
        0,
        f -> {
          Interactible.draggerMinMax(0, 16, f);
        },
        f -> {
          leftSet = f > 15;
          om("stern2.window3").stack = leftSet ? sw1 : sw0;
          if (f > 15) Sfx.play("DoorKnock");
          f > 15 ? 16 : f;
        },
        om("stern.left.subcart"),
        om("stern.left.subcart")
      ), Interactible.drag(
        0,
        f -> {
          Interactible.draggerMinMax(0, 16, f);
        },
        f -> {
          rightSet = f > 15;
          om("stern2.window1").stack = rightSet ? sw1 : sw0;
          if (f > 15) Sfx.play("DoorKnock");
          f > 15 ? 16 : f;
        },
        om("stern.right.subcart"),
        om("stern.right.subcart")
      ), Interactible.ticker(_ -> {
        if (done) return;
        if (leftSet && rightSet && scalePos >= -2 && scalePos <= 2) {
          scalePos = 0;
          om("stern.left").resetTemp();
          om("stern.left.sub").resetTemp();
          om("stern.right").resetTemp();
          om("stern.right.sub").resetTemp();
          removeGroup(g);
          Sfx.play("Success", 0);
          wakeup();
          done = true;
        }
      })]);
    }
    function group4(_, wakeup:()->Void):Void {
      var leftPos = 0.;
      var rightPos = 0.;
      var done = false;
      var g:Array<Interactible> = null;
      g = addGroup([Interactible.button(
        t -> {
          Sfx.play("DoorKnock");
          leftPos += 2.4;
        }, 0, 0, om("stern.right.door")
      ), Interactible.button(
        t -> {
          Sfx.play("DoorKnock");
          rightPos += 3.2;
        }, 0, 0, om("stern.left.door")
      ), Interactible.ticker((delta:Float) -> {
        if (done) return;
        leftPos = (leftPos - delta * .002).clamp(0, 24);
        rightPos = (rightPos - delta * .002).clamp(0, 24);
        om("stern.window1").stack = rightPos > 16 ? sw1 : sw0;
        om("stern.window2").stack = rightPos > 16 ? sw1 : sw0;
        om("stern.window3").stack = leftPos > 16 ? sw1 : sw0;
        om("stern.window4").stack = leftPos > 16 ? sw1 : sw0;
        om("stern.left.subcart").tmpX = -leftPos;
        om("stern.right.subcart").tmpX = -rightPos;
        if (leftPos > 16 && rightPos > 16) {
          om("stern.left.subcart").resetTemp();
          om("stern.right.subcart").resetTemp();
          removeGroup(g);
          Sfx.play("Success", 0);
          wakeup();
          done = true;
        }
      })]);
    }
    function group5(_, wakeup:()->Void):Void {
      var ws = [
        om("stern.window2"),
        om("stern.window1"),
        om("stern2.window1"),
        om("stern2.window2"),
        om("stern2.window3"),
        om("stern.window3"),
        om("stern.window4"),
      ];
      var windows = 0;
      for (w in ws) {
        w.stack = sw0;
      }
      var g:Array<Interactible> = null;
      function tog(idx:Array<Int>):Void {
        Sfx.play("LampOnOff");
        for (i in idx) {
          windows += toggleStack(ws[i], sw0, sw1) ? 1 : -1;
        }
        if (windows == ws.length) {
          removeGroup(g);
          Sfx.play("Success", 0);
          wakeup();
        }
      }
      g = addGroup([
        Interactible.button(t -> tog([0, 3, 4]), -1, 0, ws[0]),
        Interactible.button(t -> tog([0, 1, 6]), -1, 0, ws[1]),
        Interactible.button(t -> tog([2, 3, 5]), 0, 1, ws[2]),
        Interactible.button(t -> tog([1, 3, 6]), 0, 1, ws[3]),
        Interactible.button(t -> tog([3, 4, 6]), 0, 1, ws[4]),
        Interactible.button(t -> tog([0, 3, 5]), -1, 0, ws[5]),
        Interactible.button(t -> tog([1, 4, 6]), -1, 0, ws[6]),
      ]);
    }
    function group6(_, wakeup:()->Void):Void {
      var level = 0;
      var correct = 0;
      var levels = [
        [0], // 0
        [0, 2],
        [0, 2, 1],
        [0, 2, 1, 3],
        [1], // 4
        [1, 0],
        [1, 0, 3],
        [1, 0, 3, 2],
        [1, 0, 3, 2, 0],
        [3], // 9
        [3, 3],
        [3, 3, 1],
        [3, 3, 1, 0],
        [3, 3, 1, 0, 2],
        [3, 3, 1, 0, 2, 0],
        [3, 3, 1, 0, 2, 0, 1],
        [3], // 16
        [3, 0],
        [3, 0, 1],
        [3, 0, 1, 1],
        [3, 0, 1, 1, 2],
        [3, 0, 1, 1, 2, 0],
      ];
      var g:Array<Interactible> = null;
      function showLevel(failed:Bool):Void {
        correct = 0;
        if (failed) {
          ren.animations.push({prog: 0, len: 20, f: prog -> if (prog == 18) Sfx.play("Failure", 0), forbidden: true});
        }
        for (i in 0...levels[level].length) {
          ren.animations.push({prog: 0, len: 30, f: _ -> {}, forbidden: true});
          ren.animations.push({
            prog: 0,
            len: 12,
            f: prog -> {
              if (prog == 6) {
                Sfx.play('Note${levels[level][i] + 1}', 0);
              }
              om('pole.left.tile${levels[level][i]}').stack = sg('polelight${prog % 12}');
            },
            forbidden: true
          });
        }
      }
      function playTile(tile:Int):Void {
        ren.animations.push({
          prog: 0,
          len: 12,
          f: prog -> {
            if (prog == 6) {
              Sfx.play('Note${tile + 1}', 0);
            }
            om('pole.right.tile${tile}').stack = sg('polelight${prog % 12}');
          },
          forbidden: false
        });
        if (tile == levels[level][correct]) {
          correct++;
          if (correct >= levels[level].length) {
            level++;
            switch (level) {
              case _ if (level == levels.length):
                removeGroup(g);
                Sfx.play("Success", 0);
                wakeup();
              case 4 | 9 | 16:
                Sfx.play("NoteChord", 0);
                wakeup();
              case _:
            }
            if (level < levels.length)
              showLevel(false);
          }
        } else {
          showLevel(true);
        }
      }
      showLevel(false);
      g = addGroup([
        Interactible.button(t -> showLevel(false), -1, 0, om('pole.left.tile0')),
        Interactible.button(t -> showLevel(false), -1, 0, om('pole.left.tile1')),
        Interactible.button(t -> showLevel(false), -1, 0, om('pole.left.tile2')),
        Interactible.button(t -> showLevel(false), -1, 0, om('pole.left.tile3')),
        Interactible.button(t -> playTile(0), -1, 0, om('pole.right.tile0')),
        Interactible.button(t -> playTile(1), -1, 0, om('pole.right.tile1')),
        Interactible.button(t -> playTile(2), -1, 0, om('pole.right.tile2')),
        Interactible.button(t -> playTile(3), -1, 0, om('pole.right.tile3')),
      ]);
    }
    var WORD = [1, 3, 4, 2];
    var group7 = windowSeq(CHIMNEY1.map(s -> WORD[s]), false);
    var group8 = windowSeq(CHIMNEY2.map(s -> WORD[s]), false);
    function group9(_, wakeup:()->Void):Void {
      var stops:Array<Float> = [
        -12, -8, -4, 0, 4, 8, 12
      ];
      var pos = [3, 3, 3];
      var g:Array<Interactible> = null;
      g = addGroup([
        for (i in 1...4) {
          var dragger = Interactible.draggerStops(stops);
          Interactible.drag(
            2,
            dragger,
            f -> {
              var idx = Interactible.draggerStopsF(stops, f);
              pos[i - 1] = idx;
              if (pos[0] == 1 && pos[1] == 6 && pos[2] == 4) {
                removeGroup(g);
                Sfx.play("Success", 0);
                wakeup();
              } else {
                if (idx == [1, 6, 4][i - 1]) {
                  Sfx.play("Clockw2");
                } else {
                  Sfx.play("Clockw1");
                }
              }
              stops[idx];
            },
            om('stern2.window$i'),
            om('stern2.window$i'),
            false
          );
        }
      ]);
    }
    var globalSpeed = 1.;
    Coco.co({
      ren.cameraTX = ren.cameraX = 260;
      ren.cameraTZoom = ren.cameraZoom = 0.8;
      ren.cameraTTilt = ren.cameraTilt = 0.2;
      ren.cameraTAngle = ren.cameraAngle = 0;
      ren.message = "$bH.M.S. Relentless Puzzler$b";
      wait(40);
      ren.message = "$bH.M.S. Relentless Puzzler$b
a puzzle box by Aurel B%l& and Eido Volta";
      wait(40);
      ren.message = "$bH.M.S. Relentless Puzzler$b
a puzzle box by Aurel B%l& and Eido Volta
made for Alakajam! 10";
      wait(40);
      ren.message = "$bH.M.S. Relentless Puzzler$b
a puzzle box by Aurel B%l& and Eido Volta
made for Alakajam! 10

click to start";
      suspend((_, wakeup) -> {
        var cc:Ui = null;
        cc = new Ui.Area(0, 0, Ren.W, Ren.H, () -> {
          cc.active = false;
          ren.activeUi.remove(cc);
          wakeup();
        }, Normal);
        ren.activeUi.unshift(cc);
      });
      ren.message = null;
      {
        suspend((_, wakeup) -> ren.animations.push({
          prog: 0,
          len: 240,
          f: prog -> {
            var pp:Float = prog / 240;
            ren.cameraTX = (1 - pp) * 260;
            ren.cameraTZoom = 0.8 + pp * 1.2;
            ren.cameraTTilt = 0.2 + pp * 0.3;
            ren.cameraTAngle = -pp * 0.5;
            if (prog >= 240) wakeup();
          },
          forbidden: true
        }));
      };

      // 1 press all windows on stern
      suspend(group1);

      animate(om("stern2").z += 2);
      Sfx.play("Metal1"); animate(om("stern2").angle += P, .08);
      animate(om("stern2").z -= 2);
      Sfx.play("Metal3"); animate(om("stern2.msg").y += 4, .2);
      addGroup([Interactible.zoom(om("stern2.msg"))]);

      // 2 sequence on side windows
      suspend(group2);

      stopIx(om("stern2.msg"));
      om("stern2.window1").stack = sw0;
      om("stern2.window2").stack = sg("sidewindowdrag");
      om("stern2.window3").stack = sw0;
      om("stern2.window1").x -= 2;
      om("stern2.window2").y -= 2;
      Sfx.play("Metal4"); om("stern2.window3").x += 2;
      animate(om("stern2.msg").y -= 4, .2);
      animate(om("stern2").z += 2);
      Sfx.play("Metal1"); animate(om("stern2").angle -= P, .08);
      animate(
          om("stern2").z -= 2,
          om("stern2").x -= 2
        );
      om("stern.left.sub").active = true;
      om("stern.right.sub").active = true;

      // 3 drag stern, tip scales
      //*
      suspend(group3);
      /*/
      om("stern.left.subcart").x += 16;
      om("stern.right.subcart").x += 16;
      //*/

      Sfx.play("Metal2"); animate(
          om("stern2").z += 2,
          om("stern2").x += 2
        );
      Sfx.play("Clockw1"); animate(om("stern2").angle += P, .08);
      om("stern2.window1").stack = sw1;
      om("stern2.window2").stack = sw1;
      om("stern2.window3").stack = sw1;
      Sfx.play("Metal4"); om("stern2.window1").x += 2;
      om("stern2.window2").y += 2;
      om("stern2.window3").x -= 2;
      Sfx.play("Clockw2"); animate(om("stern2").z -= 2);
      animate(
          om("stern.left.subcart").x += 6,
          om("stern.right.subcart").x += 6
        );
      var s = Sfx.play("MechanicDeepHumm"); animate(
          om("chimney1").z -= 80,
          om("chimney2").z -= 80
        ); s.fade(750);

      // 4 door knocking
      suspend(group4);

      om("stern.left.subcart").x -= 16 + 6;
      om("stern.right.subcart").x -= 16 + 6;
      om("stern.left.sub").active = false;
      om("stern.right.sub").active = false;

      Sfx.play("Metal5"); animate(
          om("stern.window1").x += 11,
          om("stern.window3").x += 11,
          .3
        );
      Sfx.play("Metal1"); animate(
          om("stern.window1").angle += Q,
          om("stern.window3").angle -= Q,
          .05
        );
      Sfx.play("Metal3"); animate(
          om("stern.window1").y -= 15,
          om("stern.window3").y += 15,
          om("stern.window2").x += 17 + 11,
          om("stern.window4").x += 17 + 11,
          .3
        );
      Sfx.play("Metal4"); animate(
          om("stern.window2").angle += Q,
          om("stern.window4").angle -= Q,
          .05
        );

      // 5 window light up xor
      suspend(group5);

      Sfx.play("Metal4"); animate(
          om("stern.window2").angle -= Q,
          om("stern.window4").angle += Q,
          .1
        );
      Sfx.play("Metal3"); animate(
          om("stern.window1").y += 15,
          om("stern.window3").y -= 15,
          om("stern.window2").x -= 17 + 11,
          om("stern.window4").x -= 17 + 11,
          .6
        );
      Sfx.play("Metal4"); animate(
          om("stern.window1").angle -= Q,
          om("stern.window3").angle += Q,
          .1
        );
      Sfx.play("Clockw3"); animate(
          om("stern.window1").x -= 11,
          om("stern.window3").x -= 11,
          .6
        );

      Sfx.play("DoorKnock"); animate(
          om("stern.window1").z -= 12,
          om("stern.window2").z -= 12,
          om("stern.window3").z -= 12,
          om("stern.window4").z -= 12,
          om("stern.left.door").z -= 16,
          om("stern.right.door").z -= 16,
          .6
        );
      var s = Sfx.play("MechanicDeepHumm"); animate(
          om("stern.left").layerAngles[7] += Q,
          om("stern.left").layerAngles[8] += Q,
          om("stern.left").layerAngles[9] += Q,
          om("stern.left").layerAngles[10] += Q,
          om("stern.left").layerAngles[11] += Q,
          om("stern.left").layerAngles[12] += Q,
          om("stern.left").layerAngles[13] += Q,
          om("stern.left").layerAngles[14] += Q,
          .025
        ); s.fade(890);
      var s = Sfx.play("MechanicDeepHumm"); animate(
          om("stern.right").layerAngles[7] -= Q,
          om("stern.right").layerAngles[8] -= Q,
          om("stern.right").layerAngles[9] -= Q,
          om("stern.right").layerAngles[10] -= Q,
          om("stern.right").layerAngles[11] -= Q,
          om("stern.right").layerAngles[12] -= Q,
          om("stern.right").layerAngles[13] -= Q,
          om("stern.right").layerAngles[14] -= Q,
          .025
        ); s.fade(810);
      Sfx.play("Metal2"); animate(
          om("stern2").x -= 4,
          om("stern2").z -= 14,
          om("stern.left").layerOffX[7] += 8,
          om("stern.left").layerOffX[8] += 8,
          om("stern.left").layerOffX[9] += 8,
          om("stern.left").layerOffX[10] += 8,
          om("stern.left").layerOffX[11] += 8,
          om("stern.left").layerOffX[12] += 8,
          om("stern.left").layerOffX[13] += 8,
          om("stern.left").layerOffX[14] += 8,
          om("stern.right").layerOffX[7] += 8,
          om("stern.right").layerOffX[8] += 8,
          om("stern.right").layerOffX[9] += 8,
          om("stern.right").layerOffX[10] += 8,
          om("stern.right").layerOffX[11] += 8,
          om("stern.right").layerOffX[12] += 8,
          om("stern.right").layerOffX[13] += 8,
          om("stern.right").layerOffX[14] += 8,
          .5
        );
      om("pole.left").active = true;
      om("pole.right").active = true;
      ren.cameraTZ = 64;
      ren.cameraTX = -30;

      var s = Sfx.play("MechanicDeepHumm"); animate(
          om("pole.left").z += 10,
          om("pole.right").z += 10,
          .05
        ); s.fade(100);
      Sfx.play("Metal1"); animate(
          om("pole.left").z += 68,
          om("pole.right").z += 68,
          2
        );

      // 6 simon says
      suspend(group6);
      Sfx.play("Clockw2"); animate(
          om("pole.left").z -= 12 + 14,
          .5
        );
      suspend();
      Sfx.play("Clockw2"); animate(
          om("pole.left").z -= 14,
          .5
        );
      suspend();
      Sfx.play("Clockw2"); animate(
          om("pole.left").z -= 28,
          .5
        );
      suspend();
      Sfx.play("Metal5"); animate(
          om("pole.left").z -= 10,
          om("pole.right").z -= 78,
          2
        );
      om("pole.left").active = false;
      om("pole.right").active = false;
      ren.cameraTZ = 48;
      ren.cameraTX = 0;

      Sfx.play("Metal3"); animate(
          om("stern2").x += 4,
          om("stern2").z += 14,
          om("stern.left").layerOffX[7] -= 8,
          om("stern.left").layerOffX[8] -= 8,
          om("stern.left").layerOffX[9] -= 8,
          om("stern.left").layerOffX[10] -= 8,
          om("stern.left").layerOffX[11] -= 8,
          om("stern.left").layerOffX[12] -= 8,
          om("stern.left").layerOffX[13] -= 8,
          om("stern.left").layerOffX[14] -= 8,
          om("stern.right").layerOffX[7] -= 8,
          om("stern.right").layerOffX[8] -= 8,
          om("stern.right").layerOffX[9] -= 8,
          om("stern.right").layerOffX[10] -= 8,
          om("stern.right").layerOffX[11] -= 8,
          om("stern.right").layerOffX[12] -= 8,
          om("stern.right").layerOffX[13] -= 8,
          om("stern.right").layerOffX[14] -= 8,
          .9
        );
      animate(
          om("stern.left").layerAngles[7] -= Q,
          om("stern.left").layerAngles[8] -= Q,
          om("stern.left").layerAngles[9] -= Q,
          om("stern.left").layerAngles[10] -= Q,
          om("stern.left").layerAngles[11] -= Q,
          om("stern.left").layerAngles[12] -= Q,
          om("stern.left").layerAngles[13] -= Q,
          om("stern.left").layerAngles[14] -= Q,
          om("stern.right").layerAngles[7] += Q,
          om("stern.right").layerAngles[8] += Q,
          om("stern.right").layerAngles[9] += Q,
          om("stern.right").layerAngles[10] += Q,
          om("stern.right").layerAngles[11] += Q,
          om("stern.right").layerAngles[12] += Q,
          om("stern.right").layerAngles[13] += Q,
          om("stern.right").layerAngles[14] += Q,
          .1
        );
      animate(
          om("stern.window1").z += 12,
          om("stern.window2").z += 12,
          om("stern.window3").z += 12,
          om("stern.window4").z += 12,
          om("stern.left.door").z += 16,
          om("stern.right.door").z += 16,
          .9
        );

      Sfx.play("Metal2"); animate(
          om("stern.window1").x += 9,
          om("stern.window2").x -= 9,
          om("stern.window3").x += 9,
          om("stern.window4").x -= 9,
          .3
        );
      Sfx.play("Metal1"); animate(
          om("stern.window1").angle += QQ,
          om("stern.window2").angle -= QQ,
          om("stern.window3").angle -= QQ,
          om("stern.window4").angle += QQ,
          .05
        );
      om("chimney1").angle = QQ;
      om("chimney2").angle = QQ;
      for (i in 0...6) {
        om("chimney1").layerAngles[12 + i * 3] += CHIMNEY1[i] * Q;
        om("chimney1").layerAngles[12 + i * 3 + 1] += CHIMNEY1[i] * Q;
        om("chimney1").layerAngles[12 + i * 3 + 2] += CHIMNEY1[i] * Q;
        om("chimney2").layerAngles[12 + i * 3] += CHIMNEY2[i] * Q;
        om("chimney2").layerAngles[12 + i * 3 + 1] += CHIMNEY2[i] * Q;
        om("chimney2").layerAngles[12 + i * 3 + 2] += CHIMNEY2[i] * Q;
      }
      var s = Sfx.play("MechanicDeepHumm"); animate(
          om("chimney1").z += 80
        ); s.fade(400);

      // 7 sequence on side windows (based on chimney codes)
      suspend(group7);

      Sfx.play("Clockw1"); animate(
          om("chimney1").angle += QQ,
          om("chimney1").layerAngles[12 + 0 * 3] -= CHIMNEY1[0] * Q,
          om("chimney1").layerAngles[12 + 0 * 3 + 1] -= CHIMNEY1[0] * Q,
          om("chimney1").layerAngles[12 + 0 * 3 + 2] -= CHIMNEY1[0] * Q,
          om("chimney1").layerAngles[12 + 1 * 3] -= CHIMNEY1[1] * Q,
          om("chimney1").layerAngles[12 + 1 * 3 + 1] -= CHIMNEY1[1] * Q,
          om("chimney1").layerAngles[12 + 1 * 3 + 2] -= CHIMNEY1[1] * Q,
          om("chimney1").layerAngles[12 + 2 * 3] -= CHIMNEY1[2] * Q,
          om("chimney1").layerAngles[12 + 2 * 3 + 1] -= CHIMNEY1[2] * Q,
          om("chimney1").layerAngles[12 + 2 * 3 + 2] -= CHIMNEY1[2] * Q,
          om("chimney1").layerAngles[12 + 3 * 3] -= CHIMNEY1[3] * Q,
          om("chimney1").layerAngles[12 + 3 * 3 + 1] -= CHIMNEY1[3] * Q,
          om("chimney1").layerAngles[12 + 3 * 3 + 2] -= CHIMNEY1[3] * Q,
          om("chimney1").layerAngles[12 + 4 * 3] -= CHIMNEY1[4] * Q,
          om("chimney1").layerAngles[12 + 4 * 3 + 1] -= CHIMNEY1[4] * Q,
          om("chimney1").layerAngles[12 + 4 * 3 + 2] -= CHIMNEY1[4] * Q,
          om("chimney1").layerAngles[12 + 5 * 3] -= CHIMNEY1[5] * Q,
          om("chimney1").layerAngles[12 + 5 * 3 + 1] -= CHIMNEY1[5] * Q,
          om("chimney1").layerAngles[12 + 5 * 3 + 2] -= CHIMNEY1[5] * Q,
          .02
        );

      var s = Sfx.play("MechanicDeepHumm"); animate(
          om("chimney2").z += 80
        ); s.fade(400);

      // 8 sequence on side windows (more...)
      suspend(group8);

      Sfx.play("Metal2"); animate(
          om("stern.window1").x -= 9,
          om("stern.window2").x += 9,
          om("stern.window3").x -= 9,
          om("stern.window4").x += 9,
          .6
        );
      Sfx.play("Metal4"); animate(
          om("stern.window1").angle -= QQ,
          om("stern.window2").angle += QQ,
          om("stern.window3").angle += QQ,
          om("stern.window4").angle -= QQ,
          .1
        );

      Sfx.play("Clockw1"); animate(
          om("chimney2").angle += QQ,
          om("chimney2").layerAngles[12 + 0 * 3] -= CHIMNEY2[0] * Q,
          om("chimney2").layerAngles[12 + 0 * 3 + 1] -= CHIMNEY2[0] * Q,
          om("chimney2").layerAngles[12 + 0 * 3 + 2] -= CHIMNEY2[0] * Q,
          om("chimney2").layerAngles[12 + 1 * 3] -= CHIMNEY2[1] * Q,
          om("chimney2").layerAngles[12 + 1 * 3 + 1] -= CHIMNEY2[1] * Q,
          om("chimney2").layerAngles[12 + 1 * 3 + 2] -= CHIMNEY2[1] * Q,
          om("chimney2").layerAngles[12 + 2 * 3] -= CHIMNEY2[2] * Q,
          om("chimney2").layerAngles[12 + 2 * 3 + 1] -= CHIMNEY2[2] * Q,
          om("chimney2").layerAngles[12 + 2 * 3 + 2] -= CHIMNEY2[2] * Q,
          om("chimney2").layerAngles[12 + 3 * 3] -= CHIMNEY2[3] * Q,
          om("chimney2").layerAngles[12 + 3 * 3 + 1] -= CHIMNEY2[3] * Q,
          om("chimney2").layerAngles[12 + 3 * 3 + 2] -= CHIMNEY2[3] * Q,
          om("chimney2").layerAngles[12 + 4 * 3] -= CHIMNEY2[4] * Q,
          om("chimney2").layerAngles[12 + 4 * 3 + 1] -= CHIMNEY2[4] * Q,
          om("chimney2").layerAngles[12 + 4 * 3 + 2] -= CHIMNEY2[4] * Q,
          om("chimney2").layerAngles[12 + 5 * 3] -= CHIMNEY2[5] * Q,
          om("chimney2").layerAngles[12 + 5 * 3 + 1] -= CHIMNEY2[5] * Q,
          om("chimney2").layerAngles[12 + 5 * 3 + 2] -= CHIMNEY2[5] * Q,
          .02
        );

      var s = Sfx.play("MechanicDeepHumm"); animate(om("chimney2").z -= 61);
      animate(om("stern2").x += 32, .2); s.fade(500);

      globalSpeed = 1.;
      ren.cameraTZ = 110;
      ren.cameraTX = -32;
      ren.cameraTZoom = 2.5;
      Sfx.play("Metal4"); animate(
          om("chimney2").z += 61,
          om("stern2").z += 61
        );
      Sfx.play("Clockw3"); animate(om("stern2").layerOffX[13] -= 6);

      // 9 combo puzzle sound
      suspend(group9);

      Sfx.play("Metal3"); animate(om("stern2").angle -= P, .08);
      Sfx.play("Metal1"); animate(om("stern2").angle += 2.3, .12);
      Sfx.play("Clockw3"); animate(om("stern2").z -= 2);
      Sfx.play("Metal5"); animate(om("stern2").angle -= P, .14);
      Sfx.play("Metal2"); animate(om("stern2").angle += 4.3, .17);
      Sfx.play("Metal4"); animate(om("stern2").z -= 2);
      Sfx.play("Clockw2"); animate(om("stern2").angle -= P, .19);
      Sfx.play("Metal2"); animate(om("stern2").angle -= P, .09);
      Sfx.play("Metal4"); animate(om("stern2").z -= 2);
      Sfx.play("Metal5"); animate(om("stern2").angle -= P, .19);
      Sfx.play("Clockw1"); animate(om("stern2").z -= 2);
      Sfx.play("Metal1"); animate(om("stern2").angle += P, .19);
      Sfx.play("Metal4"); animate(om("stern2").z += 10);
      {
        var len = 200;
        var initials:Array<Float> = [
          om("stern2").z,
          om("stern2").y
        ];
        suspend((_, wakeup) -> ren.animations.push({
          prog: 0,
          len: len,
          f: prog -> {
            var pp:Float = prog / len;
            om("stern2").z = initials[0] - pp * pp * 200;
            om("stern2").y = initials[1] + pp * 200;
            if (prog >= len) wakeup();
          },
          forbidden: true
        }));
      };
      Sfx.play("Splash", 0);
      wait(100);
      ren.cameraTZ = 48;
      ren.cameraTX = 0;
      ren.cameraTZoom = 1;
      ren.message = "$bH.M.S. Relentless Puzzler$b
a puzzle box by Aurel B%l& and Eido Volta
made for Alakajam! 10";
      wait(200);
      ren.message = "$bH.M.S. Relentless Puzzler$b
a puzzle box by Aurel B%l& and Eido Volta
made for Alakajam! 10

looks like it broke";
      wait(100);
      ren.message = "$bH.M.S. Relentless Puzzler$b
a puzzle box by Aurel B%l& and Eido Volta
made for Alakajam! 10

looks like it broke

thanks for playing";
    }).run().wakeup();
  }
}
