precision highp float;
precision highp int;

attribute vec4 aPosition;
attribute vec2 aOffset;
attribute vec2 aUV;

uniform vec4 uCameraPosition;
uniform vec3 uCameraAngle;

varying highp vec2 vUV;
varying highp vec2 vPosition;

void main(void) {
  gl_PointSize = 1.0;
  if (aPosition.z < -90.) {
    // UI
    gl_Position = vec4(
      (aOffset.x - WH) / WH,
      ((H - aOffset.y) - HH) / HH,
      .999,
      1.0
    );
  } else {
    // 3D
    float ms = sin(aPosition.w); // model angles
    float mc = cos(aPosition.w);
    vec2 model = vec2( // model local
      aOffset.x * mc + aOffset.y * ms,
      -aOffset.x * ms + aOffset.y * mc
    );
    float cs = sin(uCameraAngle.x); // camera angles
    float cc = cos(uCameraAngle.x);
    model.x += aPosition.x - uCameraPosition.x;
    model.y += aPosition.y - uCameraPosition.y;
    vec2 world = vec2( // world coords
      model.x * cc + model.y * cs,
      -model.x * cs + model.y * cc
    );
    vec2 proj2 = vec2(
      R((world.x * uCameraPosition.w) + 1000.) - 1000. + WH,
      R((
        (world.y * uCameraAngle.z) // top view
        + ((-aPosition.z + uCameraPosition.z) * uCameraAngle.y) // side view
      ) * uCameraPosition.w + 1000.) - 1000. + HH
    );
    gl_Position = vec4(
      (proj2.x - WH) / WH,
      ((H - proj2.y) - HH) / HH,
      aPosition.z * 0.001, // avoid cutting plane, TODO: avoid UI?
      1.0
    );
  }
  vPosition = aPosition.xy;
  vUV = aUV;
}
