shader_type canvas_item;

uniform float skew;
uniform float time_scale = 1;
uniform sampler2D noise2D: source_color;
uniform vec4 color: source_color = vec4(1, 1, 1, 1);

void fragment() {
	vec2 pos = UV;
	float x = pos.x+skew*pos.y;
	float y = TIME*time_scale;
	float light = texture(noise2D, vec2(mod(x, 1), mod(y, 1))).r;
	light = light*light; 
	COLOR = vec4(color.r, color.g, color.b, color.a*light);
}
