
shader_type canvas_item;

uniform bool taking_damage  = false; //Activate the rainbow or select you color
uniform bool stunning = false;
uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);//color line
uniform float line_scale : hint_range(0, 20) = 1.2;    // thickness of the line
uniform sampler2D noise;

void fragment() {

	float noise_num = texture(noise,UV).r;

	vec2 size = TEXTURE_PIXEL_SIZE * line_scale;

	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	//outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	//outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	//outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0f);

	vec2 offset_UV = (UV-0.5)+noise_num;
	float pulse = sqrt(offset_UV.x*offset_UV.x+offset_UV.y*offset_UV.y);
	vec3 stun_color = vec3(0.0,sin(TIME*10.0+pulse*50.0),tan(TIME*-10.0+pulse*40.0));

	vec3 hurt_color = vec3(1.2,sin(TIME*10.0+UV.x+UV.y*100.0)*0.2,sin(TIME*12.0+UV.y+UV.x*86.0)*0.2);
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb,stun_color,float(stunning));
	color.rgb = mix(color.rgb,hurt_color,float(taking_damage));
	COLOR = mix(color, line_color , outline - color.a);
}