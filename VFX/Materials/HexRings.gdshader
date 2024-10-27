shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx,unshaded;

#include "res://VFX/Materials/lib.gdshaderinc"

uniform vec4 albedo : source_color;
uniform float progress : hint_range(0.0, 1.0);
uniform float p_start = -.3;
uniform float p_end = 1.1;
uniform int rings = 3;
uniform float ring_dist = .1;
uniform float thickness = 1.0;

void fragment() {
	ALBEDO = albedo.rgb;

	float p = clamp_and_map(progress, 0.0, 1.0, p_start, p_end);
	float y = clamp_and_map(UV.y, 0.0, 0.5, 1.0, 0.0);

	float a = 1.0;

	for(int i = 0; i < rings; i++) {
		a *= clamp_and_map_and_pow(distance(y, p + float(i) * ring_dist), .01 * thickness, .02 * thickness, 0.0, 1.0, .5);
	}

	a = invert(a);

	float fade = clamp_and_map_and_pow(y, 0.0, 1.0, 1.0, 0.0, 1.0) * clamp_and_map(y, 0.01, .19, 0.0, 1.0);

	ALPHA = a * fade;
}
