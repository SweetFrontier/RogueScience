shader_type canvas_item;

uniform vec2 point_1 = vec2(0.45, 0.2);
uniform vec2 point_2 = vec2(0.55, 0.5);

uniform vec3 effect_color: source_color = vec3(0.2, 0.3, 0.8);
uniform int octave_count: hint_range(1, 20) = 10;
uniform float amp_start = 0.5;
uniform float amp_coeff = 0.5;
uniform float freq_coeff = 2.0;
uniform float speed = 0.5;


float hash12(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}

vec2 hash22(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1,311.7)),
              dot(uv, vec2(269.5,183.3)));
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, fuv);
    return mix(mix(dot(hash22(iuv + vec2(0.0,0.0)), fuv - vec2(0.0,0.0)),
                   dot(hash22(iuv + vec2(1.0,0.0)), fuv - vec2(1.0,0.0)), blur.x),
               mix(dot(hash22(iuv + vec2(0.0,1.0)), fuv - vec2(0.0,1.0)),
                   dot(hash22(iuv + vec2(1.0,1.0)), fuv - vec2(1.0,1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 uv, int octaves) {
    float value = 0.0;
    float amplitude = amp_start;
    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise(uv);
        uv *= freq_coeff;
        amplitude *= amp_coeff;
    }
    return value;
}

float line(vec2 p1, vec2 p2, float width, vec2 uv) {
    float dist = distance(p1, p2); // Distance between points
    float dist_uv = distance(p1, uv); // Distance from p1 to current pixel

    // If the point is on the line, according to dist, it should match the current UV.
    // Ideally, the '0.001' should be SCREEN_PIXEL_SIZE.x, but we can't use that outside of the fragment function.
    return 1.0 - floor(1.0 - (0.001 * width) + distance(mix(p1, p2, clamp(dist_uv / dist, 0.0, 1.0)), uv));
}

void fragment() {
    vec2 uv = 2.0f*vec2(line(point_1, point_2, 3.0f, UV))-0.5f;//2.0 * UV - 0.5;
	uv *= vec2(1, 1);
    uv += 2.0 * fbm(uv + TIME * speed, octave_count) - 1.0f;
    float dist = abs(uv.x);
    vec3 color = effect_color * mix(0.0, 0.05, hash12(vec2(TIME))) / dist;
	//vec3 color = vec3(line(point_1, point_2, 2.0, UV));
    COLOR = vec4(uv, 0.0, 1.0);
}