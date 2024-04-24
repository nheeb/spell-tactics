// NOTE: Shader automatically converted from Godot Engine 4.2.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,unshaded;
uniform vec4 albedo : source_color;
uniform vec4 albedo2 : source_color;
uniform sampler2D texture_albedo : source_color,filter_linear_mipmap,repeat_enable;

uniform sampler3D noise;
uniform sampler2D flame_noise;

#include "lib.gdshaderinc"

void vertex() {
	//UV=UV*uv1_scale.xy+uv1_offset.xy;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0), vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0), vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}


void fragment() {
	ALBEDO = albedo.rgb;
	float a = texture(flame_noise, UV + vec2(.0, TIME)).r;
	float noise_x = norm_to_negative(texture(noise, vec3(UV + vec2(.0, TIME*.6), TIME*.2)).r);
	float dist = distance(UV, vec2(.5)) - texture(noise, vec3(UV, TIME*.2)).r * .1;
	dist -= clamp_and_map_and_pow(distance(.5, UV.x + noise_x * .1), 0.0, .2, .9, .0, 1.0) * 
		clamp_and_map(.5 - UV.y, 0.1, .2, 0.0, 1.0) * .3;
	float cut = float(dist < .15);
	ALPHA = cut * smoothstep(.1, .5, a) * .4;
	ALBEDO = mix(ALBEDO, albedo2.rgb, 1.0+sin(10.0 *( UV.x + UV.y)  + TIME * 10.0));
	//ALBEDO = mix(albedo.rgb, albedo2.rgb, smoothstep(.4, .6, a));
	//ALPHA = float(distance(vec2(UV.x, UV.y), vec2(.5, .5)) + (.8 - texture(noise, vec3(UV.x, UV.y,TIME)).r) * .4 < .5);
}
