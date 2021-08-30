#ifdef GL_ES
precision highp float;
#endif

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

  vec2 fragCoordN = fragCoord.xy / (iResolution.xy / vec2(1, 2));

  vec2 cPos = -2.0 + 4.0 * fragCoordN;
  float cLength = length(cPos);

  vec2 uv = fragCoordN +
    (cPos / cLength) *
    cos(cLength * 12.0 - iTime * 4.0) *
    0.03;

  vec3 col = vec3(uv, 1.0);

  fragColor = vec4(col, 1.0);
  
}