shader_type canvas_item;

uniform vec2 grid_size = vec2(6.0, 6.0);
uniform float diamond_size : hint_range(0.0, 1.0) = 0.6;
uniform vec4 diamond_color : source_color = vec4(1.0, 0.8, 0.1, 1.0);
uniform vec4 background_color : source_color = vec4(0.1, 0.1, 0.15, 1.0);
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.2;
uniform float pulse_amount : hint_range(0.0, 0.5) = 0.1;
uniform float smin_k : hint_range(0.001, 0.5) = 0.08;

uniform float hue_stripe_frequency = 8.0;
uniform float hue_shift_amount : hint_range(0.0, 1.0) = 0.08;
uniform float hue_shift_speed = 0.5;

// ── RGB ↔ HSV helpers ──
vec3 rgb2hsv(vec3 c){
    vec4 K = vec4(0., -1./3., 2./3., -1.);
    vec4 p = mix(vec4(c.bg, K.wz),
                 vec4(c.gb, K.xy),
                 step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                 vec4(c.r, p.yzx),
                 step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1e-10;
    return vec3(abs((q.w - q.y) / (6. * d + e)),
                d / (q.x + e),
                q.x);
}

vec3 hsv2rgb(vec3 c){
    vec3 p = abs(fract(c.xxx + vec3(0., 2./3., 1./3.)) * 6. - 3.);
    return c.z * mix(vec3(1.), clamp(p - 1., 0., 1.), c.y);
}

// ── SDF: diamond ──
float sdf_diamond(vec2 p, float r) {
    return (abs(p.x) + abs(p.y)) - r;
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

void fragment() {

    vec2 cell_coord = UV * grid_size;
    vec2 f = fract(cell_coord + TIME);
    vec2 c = f - 0.5;

    float unique_float = sin(cell_coord.x * 23.12) + sin(cell_coord.y * 12.19);

    float animated_size = diamond_size + sin(TIME * pulse_speed +unique_float) * pulse_amount;
    float r = animated_size * 0.5;

    float d_center = sdf_diamond(c, r);

    float d = d_center;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            if (x == 0 && y == 0) continue;
            vec2 neighbour_c = c - vec2(float(x), float(y));
            float d_neighbour = sdf_diamond(neighbour_c, r);
            d = smin(d, d_neighbour, smin_k);
        }
    }

    float edge_softness = 0.5;
    float mask = 1.0 - smoothstep(-edge_softness, edge_softness, d);

    vec4 base = mix(diamond_color*0.3, diamond_color, mask);

	// diagonal coordinate
	float diag = (UV.x + UV.y);

	// stripe pattern
	float hue_offset =
    sin((diag) * hue_stripe_frequency + TIME * hue_shift_speed)
    * hue_shift_amount;

    vec3 hsv = rgb2hsv(base.rgb);

	float hue_range = 1.0; // size of allowed hue band
	float h = hsv.x + hue_offset;
	h = mod(h, hue_range);          // wrap inside band
	hsv.x = hsv.x + h - hue_range * 0.5;
    vec3 shifted = hsv2rgb(hsv);

    COLOR = vec4(shifted, 1.0);
}