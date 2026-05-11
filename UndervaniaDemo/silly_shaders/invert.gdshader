shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR = vec4(1.0-screen_color.r, 1.0-screen_color.g, 1.0-screen_color.b, screen_color.a);
}
