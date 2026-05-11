shader_type canvas_item;

uniform float snap = 0.01;
uniform float fog_dist = 0.95;
uniform float wavelen = 1;
uniform float time_scale = 0.5;

void fragment() {
	vec2 pos = abs(UV-vec2(0.5, 0.5));
	float dist = max(pos.x, pos.y);
	float depth = (1.0-fog_dist)*tan(PI*0.5*(1.0-dist));
	depth = round(depth/snap)*snap;
	float fog_mult = max(1.0-depth, 0.0);
	fog_mult *= fog_mult;
	float wave_mult = sin(depth*PI/wavelen-TIME*time_scale);
	wave_mult *= wave_mult;
	COLOR = vec4(1, 1, 1, wave_mult*fog_mult);
}
