shader_type canvas_item;

uniform sampler2D noise_image : repeat_enable;
uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float t : hint_range(0.0, 1.0) = 0.0; // 0 = center, 1 = fully expanded
uniform float ring_thickness : hint_range(0.01, 0.5) = 0.1;

void fragment() {
	vec2 center = vec2(0.5);
	vec2 uv_offset = UV - center;

	float dist = length(uv_offset);

	// Ring expands outward as t increases
	float radius = t * 0.5; // 0 → edge (approx, since max dist is ~0.707)

	// Create donut (ring) using distance from radius
	float ring = smoothstep(ring_thickness, 0.0, abs(dist - radius));

	// Noise follows UV + slight motion
	vec2 noise_uv = UV + uv_offset * 0.2;
	float noise = texture(noise_image, noise_uv).r;

	// Fade out as it expands
	float fade = 1.0 - t;

	float alpha = ring * fade * (1.0 - smoothstep(0.0, 0.5, dist));

	vec3 final_rgb = mix(color.rgb, color.rgb * noise, 0.5);

	COLOR = vec4(final_rgb, clamp(alpha, 0.0, 1.0));
}