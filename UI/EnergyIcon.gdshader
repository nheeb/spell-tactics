shader_type canvas_item;

//uniform float radius : hint_range(0.0, 100.0); // Radius of the circle
//uniform vec2 position; // Center position of the circle
uniform vec4 base_color: source_color; // Color of the interior of the circle
uniform vec4 border_color : source_color; // Color of the border of the circle
uniform float border_thickness : hint_range(0.0, 1.0); // Thickness of the border


void fragment() {
	//float radius = 0.5 - border_thickness;
	vec2 uv = UV - vec2(0.5);
    float d = length(uv); // Distance from the center
	float radius = 0.5 - border_thickness;
    float t1 = 1.0 - smoothstep(0.0, border_thickness, abs(radius - d)); // Interpolation for border
    float t2 = 1.0 - smoothstep(radius, radius + border_thickness, d); // Interpolation for alpha channel

    vec4 final_color = mix(COLOR, border_color, t1); // Mix colors for interior and border
    final_color.a *= t2; // Set alpha channel for outline

    COLOR = final_color; // Output final color
}