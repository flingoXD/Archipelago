shader_type canvas_item;

uniform float MULT = 3.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	float max_comp = max(screen_color.r, max(screen_color.g, screen_color.b));
	float mult = min(1.0/max_comp, MULT);
	COLOR = screen_color*mult;
	COLOR = min(COLOR-max_comp*(mult-1.0), 1.0);
	COLOR.a = screen_color.a;
}
