precision highp float;
precision highp int;

uniform sampler2D uSampler;
uniform vec2 uWave;
uniform vec3 uCameraAngle;

varying highp vec2 vUV;
varying highp vec2 vPosition;

void main(void) {
  // dithered bias
  int subX = int(floor(mod(gl_FragCoord.x, 4.0)));
  int subY = int(floor(mod(gl_FragCoord.y, 4.0)));
  int sub = subX + subY * 4;
  int limit = 0;
  /**/ if (sub ==  0) limit = 0;
  else if (sub ==  1) limit = 12;
  else if (sub ==  2) limit = 3;
  else if (sub ==  3) limit = 15;
  else if (sub ==  4) limit = 8;
  else if (sub ==  5) limit = 4;
  else if (sub ==  6) limit = 11;
  else if (sub ==  7) limit = 7;
  else if (sub ==  8) limit = 2;
  else if (sub ==  9) limit = 14;
  else if (sub == 10) limit = 1;
  else if (sub == 11) limit = 13;
  else if (sub == 12) limit = 10;
  else if (sub == 13) limit = 6;
  else if (sub == 14) limit = 9;
  else if (sub == 15) limit = 15;
  float l16 = float(limit) / 16.0;

  vec4 col = vec4(0, 0, 0, 0);
  if (vUV.x < -90.) {
    // sea
    vec2 vP = vUV + vec2(99.5, 99.5);
    float closeness = 0.5 - sqrt(vP.x * vP.x + vP.y * vP.y);
    float wave1 = sin(uWave.x + vUV.x * mod(vUV.y, 0.8) * 5. + vUV.y * 9.) * closeness + l16 * .8;
    float wave2 = sin(uWave.y + vUV.x * 60. + vUV.y * 85.) * closeness + l16 * .9;
    vec4 boat = texture2D(uSampler, vec2(
        (0. + clamp(vP.x * 860. + float(subX) + 50., 0., 101.)) / TW,
        (0. + clamp(vP.y * 750. + float(subY) + 25. + 64., 64., 114.)) / TH
      ));
    wave2 += boat.w;
    float wave3 = sin(vUV.x * 15. + vUV.y * 29.) * sin(vUV.x * 3. + vUV.y * 17.) * closeness;
    float ca1 = sin(uCameraAngle.x + 1.);
    ca1 *= ca1 * .8;
    wave1 *= wave3 * 20.;
    if (wave1 * ca1 >= 2.95 + boat.w * 2.) {
      col.r = 163. / 255.;
      col.g = 247. / 255.;
      col.b = 254. / 255.;
    } else if (abs(wave1 * closeness * closeness) >= 0.3 + boat.w * .4) {
      if (boat.w > .5) {
        col.r =  29. / 255.;
        col.g = 144. / 255.;
        col.b = 241. / 255.;
      } else {
        col.r =  88. / 255.;
        col.g = 201. / 255.;
        col.b = 248. / 255.;
      }
    } else if (wave2 >= .5) {
      col.r =  13. / 255.;
      col.g =  48. / 255.;
      col.b = 149. / 255.;
    } else if (wave2 >= .25) {
      col.r =  23. / 255.;
      col.g =  99. / 255.;
      col.b = 192. / 255.;
    } else {
      col.r =  29. / 255.;
      col.g = 144. / 255.;
      col.b = 241. / 255.;
    }
    col.w = 1.0;
  } else {
    // texture
    vec2 iUV = vec2((floor(vUV.x + 1000.) - 1000. + 0.5) / TW, (floor(vUV.y + 1000.) - 1000. + 0.5) / TH);
    col = texture2D(uSampler, iUV);
    if (col.w < 0.5)
      discard;
  }

  gl_FragColor = col;
}
