shader_type canvas_item;

#include "res://VFX/Materials/lib.gdshaderinc"
uniform float distort_progress: hint_range(0.0, 1.0);
uniform sampler3D distort_noise: repeat_enable;

uniform vec4 color: source_color;

void fragment() {
	float t = TIME * .09;
	float middle_dist = distance(UV, vec2(.5));
	float edge = mix(0.0, .75, distort_progress);
	float rotation = distort_progress * (.05 + .07 * smoothstep(0.0, .4, middle_dist));
	vec2 rotated_uv = rotateUV(UV, vec2(.5), rotation);
	float change_x = texture(distort_noise, vec3(UV.x * .05, UV.y * .03, t * .3)).r;
	float change_y = texture(distort_noise, vec3(UV.x * .05, UV.y * .03, .5 + t * .3)).r;
	rotated_uv += distort_progress * .17 * (vec2(.5) - vec2(change_x, change_y));

	float distort_value = texture(distort_noise, vec3(rotated_uv, t)).r;
	float uv_noise = .5 * smoothstep(edge - .4, edge, texture(distort_noise, vec3(UV, t)).r);//pow(texture(distort_noise, vec3(UV,TIME * .07)).r, 3.0);
	vec4 tex = texture(TEXTURE, rotated_uv);
	vec4 base_tex = texture(TEXTURE, UV);
	COLOR = tex * mix(1.0, .7, distort_progress);
	COLOR.rgb = color.rgb;
	COLOR.a *= smoothstep(edge - .4, edge, distort_value);
	COLOR.a = max(COLOR.a, base_tex.a * .4 * distort_progress * uv_noise);
	COLOR.a = max(COLOR.a, smoothstep(.42, .5, middle_dist));
	COLOR.a = (1.0 - smoothstep(.49, .5, middle_dist)) * COLOR.a;
}
