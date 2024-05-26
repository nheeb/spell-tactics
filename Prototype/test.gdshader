shader_type canvas_item;

group_uniforms logic;
uniform float health: hint_range(0.0, 30, 1.0) = 4.0;
uniform float max_health: hint_range(0.0, 30, 1.0) = 4.0;
uniform float shield: hint_range(0.0, 30, 1.0) = 0.0;

group_uniforms colors;
uniform vec4 healthy_color: source_color;
uniform vec4 bg_color: source_color;
uniform vec4 tick_base_color: source_color;
uniform vec4 tick_outline_color: source_color;
uniform vec4 shield_color: source_color;

group_uniforms styling;
uniform float tick_width = 0.02;
uniform float tick_outline_percent: hint_range(0.0, 1.0, .01) = 0.05;

void fragment() {
	float cell_count = max_health + shield;
	float tick_offset = 0.5 * float(int(cell_count + 1.0) % 2);
	float cell_uv_x = fract(tick_offset + (UV.x - 0.5) * cell_count);
	float cell_idx = floor(tick_offset + (UV.x - 0.5) * cell_count);
	float tick_left_bound = 0.5 - tick_width / 2.0;
	float tick_right_bound = 0.5 + tick_width / 2.0;
	float in_tick = float(cell_uv_x < 0.5 + tick_width / 2.0 && cell_uv_x > 0.5 - tick_width / 2.0);
	// filter ticks at left and right ends of the healthbar
	in_tick *= float(cell_idx > -cell_count/2.0) * float(cell_idx < floor(cell_count/2.0));
	// mix healthy and background colors
	vec4 color = mix(healthy_color, bg_color, float(health / cell_count < UV.x));
	float is_shield = float(shield / cell_count > (1.0 - UV.x));
	// mix in shield color
	color = is_shield * shield_color + (1.0 - is_shield) * color;
	// mix in visual ticks with outline
	vec4 tick_color = tick_base_color;
	color = mix(color, tick_base_color, in_tick);
	
	// blend mult with the Panel flatbox
	COLOR *= color;
}

