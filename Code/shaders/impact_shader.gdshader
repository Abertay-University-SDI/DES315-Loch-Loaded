shader_type canvas_item;
uniform float strength: hint_range(0.0, 0.1, 0.001) = 0.08;
uniform vec2 center = vec2(0.5, 0.5);
uniform float radius: hint_range(0.0, 1.0, 0.001) = 0.25;
uniform float aberration: hint_range(0.0, 1.0, 0.001) = 0.425;
uniform float width: hint_range(0.0, 0.1, 0.0001) = 0.04;
uniform float feather: hint_range(0.0, 1.0, 0.001) = 0.135;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 st = UV;
    vec2 dist_center = st - center;

    float mask = (1.0 - smoothstep(radius - feather, radius, length(dist_center)))
               * smoothstep(radius - width - feather, radius - width, length(dist_center));

    vec2 offset = normalize(dist_center) * strength * mask;

    // Scale the UV-space offset into screen-space
    vec2 screen_offset = offset * (1.0 / SCREEN_PIXEL_SIZE) * SCREEN_PIXEL_SIZE;
    vec2 abber_vec = offset * aberration * mask;

    // Use SCREEN_UV as the base, apply offsets in screen space
    vec2 base_uv = SCREEN_UV - offset;
    vec2 final_st = mix(SCREEN_UV, base_uv, mask);

    vec4 red  = texture(SCREEN_TEXTURE, final_st + abber_vec);
    vec4 blue = texture(SCREEN_TEXTURE, final_st - abber_vec);
    vec4 ori  = texture(SCREEN_TEXTURE, final_st);

    COLOR = vec4(red.r, ori.g, blue.b, 1.0)*2.1;
}