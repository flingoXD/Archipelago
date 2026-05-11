shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, vec2(SCREEN_UV.x, 1.0-SCREEN_UV.y));
}
