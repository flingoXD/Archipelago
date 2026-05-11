shader_type canvas_item;

uniform vec4 sepia: source_color = vec4(1, 0.66, 0.33, 1);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	float value = (screen_color.r+screen_color.g+screen_color.b)*0.3+0.1;
	COLOR = sepia*value;
	COLOR.a = screen_color.a;
}
