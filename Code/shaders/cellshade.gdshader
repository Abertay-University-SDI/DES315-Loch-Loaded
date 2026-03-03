shader_type spatial;
render_mode unshaded;

uniform vec4 shadow_color : source_color = vec4(0.10, 0.11, 0.14, 1.0);
uniform vec4 mid_color    : source_color = vec4(0.25, 0.27, 0.32, 1.0);
uniform vec4 lit_color    : source_color = vec4(0.45, 0.48, 0.55, 1.0);
uniform vec4 rim_color    : source_color = vec4(0.70, 0.75, 0.85, 1.0);

uniform vec3 light_dir    = vec3(0.4, 0.8, 0.3);   // world-space light direction
uniform float rim_threshold : hint_range(0.0, 1.0) = 0.25;
uniform float rim_strength  : hint_range(0.0, 1.0) = 0.6;

// Per-instance tint fed from MultiMesh set_instance_color()
uniform bool use_instance_color = true;

void fragment() {
	// --- normal in world space ---
	vec3 N = normalize(NORMAL);
	vec3 L = normalize(light_dir);
	vec3 V = normalize(VIEW);

	float NdotL = dot(N, L);

	// --- 3-band cel shading ---
	vec4 cell_color;
	if (NdotL > 0.55) {
		cell_color = lit_color;
	} else if (NdotL > 0.0) {
		cell_color = mid_color;
	} else {
		cell_color = shadow_color;
	}

	// --- rim light (edge highlight facing away from camera) ---
	float rim = 1.0 - max(dot(N, -V), 0.0);
	rim = step(1.0 - rim_threshold, rim) * rim_strength;
	cell_color = mix(cell_color, rim_color, rim);

	// --- per-instance tint from MultiMesh ---
	if (use_instance_color) {
		cell_color *= COLOR;
	}

	ALBEDO = cell_color.rgb;
}
