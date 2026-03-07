shader_type canvas_item;

uniform float smear_length : hint_range(0.0, 5.0) = 2.0;       // How far the smear stretches (in texture heights)
uniform float smear_samples : hint_range(2, 32) = 16.0;         // Quality of smear
uniform float smear_falloff : hint_range(0.5, 8.0) = 2.5;       // How quickly the smear fades (higher = sharper tail)
uniform float glow_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float glow_radius : hint_range(0.0, 10.0) = 3.0;
uniform vec4 glow_color : source_color = vec4(1.0, 0.85, 0.3, 1.0);

void fragment() {
    vec2 pixel_size = TEXTURE_PIXEL_SIZE;

    // --- Vertical Smear ---
    // Sample along Y axis above and below current UV, weighted by distance
    vec4 smear = vec4(0.0);
    float total_weight = 0.0;

    for (float i = 0.0; i < smear_samples; i++) {
        // t goes from -1 (top/leading edge) to +1 (bottom/tail)
        float t = (i / (smear_samples - 1.0)) * 2.0 - 1.0;

        // Offset in UV space along Y — smear_length * texture height
        float offset_y = t * smear_length * pixel_size.y * (1.0 / pixel_size.y) * pixel_size.y;
        // Simpler: offset in UV units directly
        float uv_offset = t * smear_length * pixel_size.y * 100.0 * pixel_size.y;

        vec2 sample_uv = UV + vec2(0.0, t * smear_length * pixel_size.y * 50.0);

        // Weight: full at center, fades toward tail (bottom positive Y)
        // Asymmetric: leading tip (t < 0, up) fades fast, tail (t > 0, down) fades slower
        float weight;
        if (t <= 0.0) {
            // Front/tip — quick falloff
            weight = pow(1.0 - abs(t), smear_falloff * 2.0);
        } else {
            // Tail — slower fade
            weight = pow(1.0 - t, smear_falloff);
        }

        smear += texture(TEXTURE, sample_uv) * weight;
        total_weight += weight;
    }
    smear /= total_weight;

    // --- Glow (radial multi-sample) ---
    vec4 glow = vec4(0.0);
    float glow_total = 0.0;
    int glow_steps = 8;

    for (int i = 0; i < glow_steps; i++) {
        float angle = float(i) * (6.28318 / float(glow_steps));
        for (int r = 1; r <= 3; r++) {
            float radius = float(r) * glow_radius * pixel_size.x;
            vec2 goff = vec2(cos(angle), sin(angle)) * radius;
            vec4 s = texture(TEXTURE, UV + goff);
            float falloff = 1.0 / float(r * r);
            glow += s * falloff;
            glow_total += falloff;
        }
    }
    glow /= glow_total;

    // --- Combine ---
    vec4 glow_contrib = glow_color * glow.a * glow_intensity;
    vec4 final_color = smear + glow_contrib * (1.0 - smear.a);
    final_color.rgb += smear.rgb * smear.a * (glow_intensity * 0.3);
    final_color.a = max(smear.a, glow_contrib.a);

    COLOR = final_color;
}