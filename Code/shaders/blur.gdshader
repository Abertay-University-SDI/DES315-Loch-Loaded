shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 16.0) = 2.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 size = 1.0 / vec2(textureSize(screen_texture, 0));
	vec4 color = vec4(0.0);
	
	float total = 0.0;
	int samples = 9;
	
	for (int x = -samples/2; x <= samples/2; x++) {
		for (int y = -samples/2; y <= samples/2; y++) {
			vec2 offset = vec2(float(x), float(y)) * size * blur_amount;
			color += texture(screen_texture, SCREEN_UV + offset);
			total += 1.0;
		}
	}
	
	COLOR = color / total;
}