shader_type canvas_item;

uniform sampler2D sprite;
uniform sampler2D noise;

uniform float completion : hint_range(0.0, 1.0) = 0.0;
uniform vec2 origin = vec2(0.5, 0.5);

// Spray tuning
uniform float spray_radius = 1.6;
uniform float angle_jitter = 0.35;
uniform float softness = 0.15;

void fragment() {
    vec2 to_pixel = UV - origin;
    float dist = length(to_pixel);

    // Stable noise per pixel
    float n = texture(noise, UV).r;

    // Base radial direction
    vec2 dir = normalize(to_pixel + 0.0001);

    // Angular spray jitter
    float jitter_angle = (n - 0.5) * angle_jitter * TAU;
    vec2 perp = vec2(-dir.y, dir.x);
    dir = dir * cos(jitter_angle) + perp * sin(jitter_angle);

    // Per-pixel delay
    float delay = n * 0.6;

    float t = clamp((completion - delay) / (1.0 - delay), 0.0, 1.0);
    t = smoothstep(0.0, 1.0, t);

    // Spray travel
    vec2 offset = dir * (1.0 - t) * dist * spray_radius;
    vec2 sample_uv = UV - offset;

    vec4 col = texture(sprite, sample_uv);

    // Soft spray alpha
    col.a *= smoothstep(0.0, softness, t);
	col.a *= smoothstep(length(UV-0.5)-completion,0.2,0.8);

    COLOR = col;
}
