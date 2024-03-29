shader_type canvas_item;

#include "res://Shaders/lib.gdshaderinc"

uniform sampler2D noise: repeat_enable;
uniform int sections = 5;
uniform int fill = 0;
uniform float rotation_offset = 0.0;
uniform vec4 color_empty: source_color;
uniform vec4 color_filled: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float t = TIME * .01;
	vec2 pos = rotateVector(UV - vec2(.5), rotation_offset);
	float section_size = TAU / float(sections);
	float dir_color = positive_direction_of_vec2(normalize(rotateVector(pos, 0.0)));
	float dir = positive_direction_of_vec2(normalize(rotateVector(pos, section_size * .5)));
	//dir += section_size * .5;
	int current_section = int(dir / section_size);
	vec2 normal = rotateVector(vec2(0.0, 1.0), float(current_section)
									 * section_size + PI / 2.0);
	COLOR.a *= invert(float(abs(dot(pos, normal)) < .02));
	float break_area = clamp_and_map(abs(dot(pos, normal)), .01, .04, .0, 1.0);
	float zero_noise = clamp_and_map(texture(noise, UV + t).r, 0.0, 1.0, -1.0, 1.0);
	break_area = float(break_area + zero_noise * .65 > .5);
	COLOR.a *= break_area;
	
	int color_section = int(dir_color / section_size);
	COLOR.rgb = mix(color_empty, color_filled, float(sections - fill <= color_section)).rgb;
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
