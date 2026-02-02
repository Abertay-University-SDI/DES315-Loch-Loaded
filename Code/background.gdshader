shader_type canvas_item;

//thank Inigo Quilez for the invetion of sdfs in rendering

uniform float aspect_ratio = 1.78;
uniform float radius = 0.08;
uniform float speed = 0.25;
uniform vec2 var_pos = vec2(0.0,0.0);
uniform sampler2D gradient; 

const int SPHERE_COUNT = 32;

float sd_circle(vec2 p, vec2 c, float r) {
	return length(p - c) - r;
}

float smin(float a, float b, float k) {
	float h = max(k - abs(a - b), 0.0) / k;
	return min(a, b) - h * h * k * 0.25;
}

float ping_pong(float t, float min_v, float max_v) {
	float range = max_v - min_v;
	return min_v + abs(mod(t, range * 2.0) - range);
}

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= aspect_ratio;
	uv.y += sin(uv.x+TIME)*0.1;

	float dist = 1000.0;
	float rim_dist = 0.04;
	float inside_dist = 0.0;
	
	vec3 col = vec3(0.0,0.1,0.8);

	for (int i = 0; i < SPHERE_COUNT; i++) {
		float fi = float(i);
		
		vec2 base_pos = vec2(
			fract(sin(fi * 12.9898) * 43758.5453),
			fract(sin(fi * 78.233) * 12345.6789)
		) - 0.5;

		vec2 vel = vec2(
			sin(fi * 3.1),
			cos(fi * 4.7)
		) * speed;

		vec2 pos;
		pos.x = ping_pong(base_pos.x + vel.x * TIME, -0.5, 0.5);
		pos.y = ping_pong(base_pos.y + vel.y * TIME, -0.5, 0.5);

		pos.x *= aspect_ratio;
		float r = clamp(cos(fi * 13.2)+0.2,0.2,1);
		float d = sd_circle(uv, pos, r*radius);
		dist = smin(dist, d, 0.12);
		if (dist < inside_dist)
		{
			col.r = sin(fi*34.1);
			col.g = sin(fi*3.1);
			col.b +=0.2;
			break;
		}
	}
	col += texture(gradient,vec2(uv.y,0)).rgb;
	COLOR = vec4(col, 1.0);
}
