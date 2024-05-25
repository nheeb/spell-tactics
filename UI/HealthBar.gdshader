shader_type canvas_item;

uniform vec4 healthy_color: source_color;
uniform vec4 bg_color: source_color;
uniform vec4 tick_color: source_color;
uniform vec4 shield_color: source_color;
uniform vec4 shield_tick_color: source_color;


uniform float shield: hint_range(0.0, 30, 1.0) = 0.0;

uniform float health: hint_range(0.0, 30, 1.0) = 4.0;
uniform float max_health: hint_range(0.0, 30, 1.0) = 4.0;
uniform float tick_width = 0.02;

void fragment() {
	float max_total = max_health + shield;
	float tick_offset = 0.5 * float(int(max_total + 1.0) % 2);
	float tick_grid = fract(tick_offset + (UV.x - 0.5) * max_total);
	float tick_idx = floor(tick_offset + (UV.x - 0.5) * max_total);
	float in_tick = float(tick_grid < 0.5 + tick_width / 2.0 && tick_grid > 0.5 - tick_width / 2.0);
	// filter 0 and last tick
	in_tick = float(tick_idx > -max_total/2.0) * float(tick_idx < floor(max_total/2.0)) * in_tick;
	// mix healthy, bg and shield
	vec4 color = mix(healthy_color, bg_color, float(health / max_total < UV.x));
	float is_shield = float(shield / max_total > (1.0 - UV.x));
	color = is_shield * shield_color + (1.0 - is_shield) * color;
	// mix in ticks
	//color = mix(color, is_shield * shield_tick_color + (1. - is_shield) * tick_color, in_tick);
	color = mix(color, tick_color, in_tick);
	// finally blend mult with flatbox
	COLOR = COLOR * color;
}

