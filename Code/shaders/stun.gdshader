shader_type canvas_item;

uniform float ellipse_x : hint_range(0.1, 1.0) = 0.35;
uniform float ellipse_y : hint_range(0.1, 1.0) = 0.2;

uniform float thickness : hint_range(0.001, 0.05) = 0.012;
uniform float arc_size : hint_range(0.1, 3.14) = 1.0;

uniform float speed = 2.5;
uniform float glow_strength = 1.5;

uniform vec4 color : source_color = vec4(1.0, 1.0, 0.2, 1.0);

uniform sampler2D noise_image;

mat2 rot(float a) {
	return mat2(vec2(cos(a), -sin(a)), vec2(sin(a), cos(a)));
}

float angle_diff(float a, float b) {
	float d = a - b;
	return mod(d + 3.1415926, 6.283185) - 3.1415926;
}

float star_field(vec2 uv) {
	float density = 14.0;

	vec2 grid = floor(uv * density);
	vec2 local = fract(uv * density) - 0.5;

	float h = texture(noise_image, grid / density).r;

	float star = step(0.82, h);

	float d = length(local);
	float sparkle = pow(max(0.0, 1.0 - d * 3.0), 3.0);

	return star * sparkle;
}

float ellipse_arc(vec2 uv, float base_rot) {
	uv -= 0.5;

	float wobble = sin(TIME * 6.0) * 0.18;

	uv = rot(base_rot + wobble) * uv;

	vec2 e = vec2(uv.x / ellipse_x, uv.y / ellipse_y);

	float dist = abs(length(e) - 1.0);

	float ang = atan(e.y, e.x);

	float t = TIME * speed + wobble;

	float d = angle_diff(ang, t);

	float arc = smoothstep(0.0, 0.2, d) * (1.0 - smoothstep(arc_size, arc_size + 0.2, d));
	arc *= smoothstep(arc_size, 0.0, d);

	float line = smoothstep(thickness, 0.0, dist);

	return arc * line;
}

void fragment() {
	vec2 uv = UV;

	float e1 = ellipse_arc(uv, radians(45.0));
	float e2 = ellipse_arc(uv, radians(135.0));

	float arcs = max(e1, e2);

	float glow = smoothstep(0.05, 0.0, abs(arcs - 0.2)) * glow_strength;

	float pulse = 0.85 + sin(TIME * 8.0) * 0.15;

	float stars = star_field(uv + vec2(TIME * 0.1, sin(TIME) * 0.05));

	float alpha = clamp(arcs + glow + stars * 1.5, 0.0, 1.0);


	vec3 varried_color = color.rgb;
	varried_color.r = (texture(noise_image,UV+TIME).r +varried_color.r)/2.0;
	varried_color.g = (texture(noise_image,UV+TIME).g +varried_color.g)/2.0;
	
	
	
	COLOR = vec4(varried_color * pulse, alpha * color.a);
}