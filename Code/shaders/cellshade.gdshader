shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform vec4 shadow_color  : source_color = vec4(0.10, 0.11, 0.14, 1.0);
uniform vec4 mid_color     : source_color = vec4(0.25, 0.27, 0.32, 1.0);
uniform vec4 lit_color     : source_color = vec4(0.45, 0.48, 0.55, 1.0);
uniform vec4 rim_color     : source_color = vec4(0.70, 0.75, 0.85, 1.0);

uniform float shadow_threshold : hint_range(0.0, 1.0) = 0.0;
uniform float mid_threshold    : hint_range(0.0, 1.0) = 0.55;
uniform float rim_threshold    : hint_range(0.0, 1.0) = 0.25;
uniform float rim_strength     : hint_range(0.0, 1.0) = 0.6;

void fragment() {
    // Base albedo — tint via instance color if needed
    ALBEDO = vec3(1.0);
    if (COLOR.a > 0.0) {
        ALBEDO *= COLOR.rgb;
    }
}

void light() {
    // Combine NdotL with attenuation so self-shadow collapses into shadow band
    float NdotL = dot(NORMAL, LIGHT) * ATTENUATION;

    float band = smoothstep(shadow_threshold - 0.02, shadow_threshold + 0.02, NdotL) * 0.5
               + smoothstep(mid_threshold    - 0.02, mid_threshold    + 0.02, NdotL) * 0.5;

    vec3 cell = mix(shadow_color.rgb, mid_color.rgb, clamp(band * 2.0, 0.0, 1.0));
    cell       = mix(cell,            lit_color.rgb, clamp(band * 2.0 - 1.0, 0.0, 1.0));

    // Rim (skip in shadow)
    float rim = 1.0 - max(dot(NORMAL, VIEW), 0.0);
    float rim_mask = step(1.0 - rim_threshold, rim) * rim_strength * ATTENUATION;
    cell = mix(cell, rim_color.rgb, rim_mask);

    DIFFUSE_LIGHT += cell * LIGHT_COLOR;
}