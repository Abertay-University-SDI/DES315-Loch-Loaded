shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform vec2 viewport_size;

uniform float dot_size = 6.0;

// angles for each channel
uniform float angle_r = 0.261799; // 15°
uniform float angle_g = 0.785398; // 45°
uniform float angle_b = 1.309;    // 75°

vec2 rotate(vec2 p, float a){
	float s = sin(a);
	float c = cos(a);
	return mat2(vec2(c,-s), vec2(s,c)) * p;
}

float halftone_channel(vec2 uv, float angle, float value){
	vec2 p = uv * viewport_size;
	p = rotate(p, angle);
	vec2 cell = floor(p / dot_size) * dot_size + dot_size * 0.5;
	float dist = length(p - cell);
	float radius = dot_size * (1.0 - value) * 0.5;
	return 1.0 - smoothstep(radius - 1.0, radius + 1.0, dist);
}

void fragment(){
	vec2 uv = SCREEN_UV;
	vec3 col = texture(screen_texture, uv).rgb;

	float r_mask = halftone_channel(uv, angle_r, col.r);
	float g_mask = halftone_channel(uv, angle_g, col.g);
	float b_mask = halftone_channel(uv, angle_b, col.b);

	vec3 halftone = vec3(r_mask, g_mask, b_mask);

	COLOR = vec4(halftone, 1.0);
	COLOR.rgb = vec3(1.0)-COLOR.rgb;
}