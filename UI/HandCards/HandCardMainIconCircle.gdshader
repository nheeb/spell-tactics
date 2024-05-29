shader_type canvas_item;

#include "res://Shaders/lib.gdshaderinc"
uniform float distort_progress: hint_range(0.0, 1.0);
uniform sampler2D distort_noise;

uniform vec4 color: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	float middle_dist = distance(UV, vec2(.5));
	float edge = mix(0.0, .75, distort_progress);
	float rotation = distort_progress * (.3 + 1.6 * smoothstep(0.0, .5, middle_dist));
	vec2 rotated_uv = rotateUV(UV, vec2(.5), rotation);
	float distort_value = texture(distort_noise, rotated_uv).r;
	vec4 tex = texture(TEXTURE, rotated_uv);
	COLOR = tex;
	COLOR.rgb = color.rgb;
	COLOR.a *= smoothstep(edge - .3, edge, distort_value);
	COLOR.a = max(COLOR.a, smoothstep(.46, .5, middle_dist));
	COLOR.a = float(middle_dist < .5) * COLOR.a;
	//COLOR.a = max(COLOR.a, float)
}
