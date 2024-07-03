// NOTE: Shader automatically converted from Godot Engine 4.2.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode unshaded, blend_mix,depth_draw_opaque,cull_back, shadows_disabled;

#include "res://Shaders/lib.gdshaderinc"

uniform vec4 albedo : source_color;
uniform vec4 blink_color : source_color;
uniform float time_scale = 1.0;
uniform float range = 0.04;
uniform float smooth_edge = 0.1;
uniform float width = 0.1;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float blink_start = .7;
uniform float blink_strength = 2.0;

float sdHexagon( in vec2 p, in float r )
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p)*sign(p.y);
}

void fragment() {
	float load_progress = clamp(progress / blink_start, 0.0, 1.0);
	float blink_progress = clamp((progress - blink_start) / (1.0 - blink_start), 0.0, 1.0);
	float fade_progress = smoothstep(.5, 1.0, blink_progress);
	float d = sdHexagon(2.50 * (vec2(UV.x - 0.5, UV.y - 0.5)), 1.0);
	float time_offset = range;range * sin(TIME * time_scale);
	float outer_edge = 1.0 - smoothstep(time_offset-smooth_edge, time_offset+smooth_edge, d);
	float inner_edge = smoothstep(time_offset - width - smooth_edge, time_offset - width + smooth_edge, d);
	float angle = mod(positive_direction_of_vec2(UV-vec2(.5)) + PI / 6.0, TAU);
	ALPHA = outer_edge * inner_edge * float(angle < load_progress * TAU);
	float blink_value = invert(2.0 * abs(blink_progress - .5));
	ALBEDO = mix(albedo.rgb, blink_color.rgb, blink_value);
	EMISSION = ALBEDO * blink_value * blink_strength;
	ALPHA *= invert(fade_progress);
}
