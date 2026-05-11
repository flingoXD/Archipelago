shader_type canvas_item;

uniform vec2 RES = vec2(160, 120);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

float qun(float n, float q, bool parity) {
	n *= q;
	if (parity) {
		float d = fract(n+0.5);
		if (d < 0.25) {return floor(n)/q;}
		if (d > 0.75) {return ceil(n)/q;}
	}
	return round(n)/q;
}

void fragment() {
	vec2 screen_pos = vec2((floor(SCREEN_UV.x*RES.x)+0.125)/RES.x, (floor(SCREEN_UV.y*RES.y)+0.125)/RES.y);
	vec4 screen_color = texture(SCREEN_TEXTURE, screen_pos);
	//vec4 screen_coords = trunc(FRAGCOORD*0.5);
	bool parity = false; //mod(screen_coords.x+screen_coords.y, 2.0) >= 1.0;
	COLOR = vec4(
		qun(screen_color.r, 8.0, parity),
		qun(screen_color.g, 8.0, parity),
		qun(screen_color.b, 4.0, parity),
	screen_color.a);
}

//void light() {
	//LIGHT = LIGHT_ENERGY > 0.5? vec4(1, 1, 1, 1): vec4(0, 0, 0, 0);
//}
