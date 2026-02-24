shader_type canvas_item;

// Add the required uniform for screen texture in Godot 4.4.1
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform int mode : hint_range(0, 3) = 0; // 0 = off, 1 = protanopia, 2 = deuteranopia, 3 = tritanopia

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);

    mat3 m;

    if (mode == 1) // Protanopia
	{ 
        m = mat3(
            vec3(0.567, 0.433, 0.000),
            vec3(0.558, 0.442, 0.000),
            vec3(0.000, 0.242, 0.758)
        );
    }
    else if (mode == 2) // Deuteranopia
	{
        m = mat3(
            vec3(0.625, 0.375, 0.000),
            vec3(0.700, 0.300, 0.000),
            vec3(0.000, 0.300, 0.700)
        );
    }
    else if (mode == 3) { // Tritanopia
        m = mat3(
            vec3(0.950, 0.050, 0.000),
            vec3(0.000, 0.433, 0.567),
            vec3(0.000, 0.475, 0.525)
        );
    }
    else {
        m = mat3(1.0); // identity
    }

    color.rgb = m * color.rgb;
    COLOR = color;
}