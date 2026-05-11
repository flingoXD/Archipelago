shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR = pow(screen_color, vec4(2, 2, 2, 2));
	COLOR = (COLOR*3.0+COLOR.gbra+COLOR.brga)*0.2;
}
