shader_type canvas_item;

float circle(vec2 position, float radius, float feather)
{
	return smoothstep(radius, radius + feather, dot(position, position) * 4.0);
}


void fragment() {
	//float in_circle = float((UV.x-0.5) * (UV.x-0.5) + (UV.y-.5) * (UV.y-.5) < .25);
	float in_circle = circle(UV-0.5, .9 , .1);
	COLOR = COLOR * (1.0-in_circle) + vec4(0.0) * (in_circle);
}


