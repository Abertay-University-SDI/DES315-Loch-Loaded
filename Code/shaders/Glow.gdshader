
shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);//color line
uniform float line_scale : hint_range(0, 20) = 1.2;    // thickness of the line
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

uniform sampler2D noise;

void fragment() {
	float rise_strength = pow(1.0-UV.y,2)*8.0;
	vec2 noise_uv = UV + vec2(0.0, sin(TIME)/4.0+0.25);
	float noise_strength = texture(noise, noise_uv).r * 10.0;
	vec2 size = TEXTURE_PIXEL_SIZE * (line_scale+noise_strength)*rise_strength;

	float d = length(UV - 0.5);
	float dist = 1.0 - smoothstep(-1.8, 0.45, d);

	vec4 faded_line_color = vec4(line_color.rgb, dist);



	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0f);


	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, faded_line_color , outline - color.a);
}