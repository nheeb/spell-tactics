shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float middle_dist = distance(UV, vec2(.5));
	COLOR.rgba = max(COLOR, vec4(1) * smoothstep(.46, .5, middle_dist));
	COLOR.a = float(middle_dist < .5) * COLOR.a;
	//COLOR.a = max(COLOR.a, float)
}
