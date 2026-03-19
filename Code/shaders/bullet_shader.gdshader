shader_type canvas_item;

uniform vec2 Velocity = vec2(1.0, 0.0);

uniform float base_radius = 0.01;
uniform float wave_strength = 0.5;
uniform float wave_frequency = 20.0;

uniform float glow_size = 0.04;

	uniform vec2 world_pos = vec2(0.0);

	float sdLine(vec2 p, vec2 a, vec2 b)
	{
		vec2 pa = p - a;
		vec2 ba = b - a;
		float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
		return length(pa - ba * h);
	}

	void fragment()
	{
		vec2 dir = normalize(Velocity);
		vec2 uv = (UV - 0.5)*2.0;

		vec2 a = -dir * 0.5;
		vec2 b =  dir * 0.5;

		float dist_to_edge = smoothstep(0.35,1.0,pow((1.0-length(UV-0.5)),3));
	
	vec2 pixel_pos_in_world = UV*TEXTURE_PIXEL_SIZE + world_pos;
	
	// oscillation anchored in world space
	float wave = sin(pixel_pos_in_world.x * wave_frequency);

	float radius = base_radius * (1.0 + wave * wave_strength)*dist_to_edge;

	float d = sdLine(uv, a, b);

	float line = smoothstep(radius, radius * 0.6, d);
	float glow = smoothstep(glow_size, 0.0, d);

	vec3 color = vec3(1.0) * line + vec3(1.0,0.85,0.6) * glow * 0.6;

	float alpha = max(line, glow * 0.5);

	COLOR = vec4(color, alpha);
}