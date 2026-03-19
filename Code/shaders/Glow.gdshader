
shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);//color line
uniform float line_scale : hint_range(0, 20) = 1.2;    // thickness of the line
uniform float alpha : hint_range(0.0, 1.0) = 1.0;

uniform sampler2D noise;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * (line_scale+texture(noise,UV*sin(TIME*1.2)+0.5).r*13.0);

	float dist = pow(length(UV-0.5),2.1);
	vec4 faded_line_color = vec4(line_color.rgb,dist);


	
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