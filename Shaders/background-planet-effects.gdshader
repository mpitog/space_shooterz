shader_type canvas_item;

// A shader by The Gingerjam, I used this page https://godotshaders.com/snippet/random-value/ for the pseudo random value, rest of the code by me :)

// Colours
uniform vec4 colour1 : source_color;
uniform vec4 colour2 : source_color;
uniform int gradientType : hint_range(1, 5, 1);
uniform float proportion : hint_range(0.0, 10.0, 0.001);
uniform float noise : hint_range(0.0, 1.0, 0.01);
// Alpha clipping
uniform bool clipAlpha = true;
uniform float clipThreshold : hint_range(0.0, 1.0, 0.01);

float random (vec2 uv) {
	// Generate pseudo random value
	return (fract(sin(dot(uv.xy,vec2(12.9898,78.233))) * 43758.5453123) - 0.4) * 1.0;
}

float calculate_distance(vec2 v1, vec2 v2) {
	// Calculate the distance between 2 vectors (used in the radial gradient)
	return sqrt(pow((v1.x - v2.x), 2.0) + pow((v1.y - v2.y), 2.0));
}

vec4 lerp_colour(vec4 c1, vec4 c2, float ratio) {
	// Lerp between 2 vec4s with the given ratio
	return c1 + (c2 - c1) * clamp(ratio, 0.0, 1);
}

void fragment() {
	float ratio = proportion; // Kind of weirdly coded, the ratio should be multiplied by proportion, I just set the ratio here and multiply everything else
	if(gradientType == 1){
		ratio = clamp(calculate_distance(UV, vec2(0.5,0.5)) * (proportion * 2.0) + random(UV) * noise, 0.0, 1.0); // Apart from here lol
		COLOR = lerp_colour(colour1, colour2, ratio);
	} else if(gradientType == 2){
		ratio *= UV.x + random(UV) * noise;
		COLOR = lerp_colour(colour1, colour2, ratio);
	} else if(gradientType == 3){
		ratio *= abs(UV.x - UV.y) + random(UV) * noise;
		COLOR = lerp_colour(colour1, colour2, ratio);
	} else if(gradientType == 4){
		ratio *= abs(((UV.x * -1.0) + 1.0) - UV.y) + random(UV) * noise;
		COLOR = lerp_colour(colour1, colour2, ratio);
	} else {
		ratio *= (abs(((UV.x * -1.0) + 1.0) - UV.y) + abs(UV.x - UV.y)) + random(UV) * noise;
		COLOR = lerp_colour(colour1, colour2, ratio);
	}
	
	if(clipAlpha) {
		if(COLOR.a > clipThreshold) {
			COLOR.a = 1.0;
		} else {
			COLOR.a = 0.0;
		}
	}
}
