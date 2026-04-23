shader_type canvas_item;

uniform float cooldown;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);//color line
uniform float line_scale : hint_range(0, 20) = 1.2;    // thickness of the lin

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec2 size = TEXTURE_PIXEL_SIZE * line_scale;
	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0f);
	
	float saturation = step(cooldown,1.0-UV.y);
	if(saturation != 0.0)
	{
	COLOR.rgb *= saturation*0.1;
	}
	if(cooldown > 0.9)
	{
	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, line_color , outline - color.a);	
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
