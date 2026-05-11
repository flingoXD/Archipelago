//https://godotshaders.com/shader/gaussian-blur-2/

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture,repeat_disable, filter_nearest;
uniform float sigma: hint_range(0.1, 20.0) = 3.3;


float gaussianDistribution(float x, float STD){
	return exp(-(x*x)/(2.*STD*STD))/(sqrt(2.*PI)*STD);
}

vec3 gaussianblur(sampler2D sampler, vec2 pos, vec2 pixel_size, float sigmaUsed, int radius){
    vec3 blurredPixel = vec3(0.0);
    float total_weight = 0.0;
    for(int i = -radius ; i <= radius; i++){ 
        for(int j = -radius; j <= radius; j++){
			vec2 offset = vec2(float(i), float(j))*pixel_size;
			vec2 changedPos = pos + offset;        
			float weight = gaussianDistribution(float(i), sigmaUsed)*gaussianDistribution(float(j), sigmaUsed);
			blurredPixel += texture(SCREEN_TEXTURE, changedPos).rgb * weight;
			total_weight += weight;
        }
    }
	blurredPixel/=total_weight;
    return blurredPixel;
}
void fragment() {
    vec3 PixelBlurred = gaussianblur(SCREEN_TEXTURE, SCREEN_UV, SCREEN_PIXEL_SIZE, sigma, int(round(3.0 * sigma)));
    COLOR = vec4(PixelBlurred, 1.);
}