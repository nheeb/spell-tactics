shader_type canvas_item;

group_uniforms logic;
uniform float health: hint_range(0.0, 30, 1.0) = 4.0;
uniform float max_health: hint_range(0.0, 30, 1.0) = 4.0;
uniform float shield: hint_range(0.0, 30, 1.0) = 0.0;

group_uniforms colors;
uniform vec4 healthy_color: source_color;
uniform vec4 bg_color: source_color;
uniform vec4 tick_base_color: source_color;
uniform vec4 shield_color: source_color;

group_uniforms styling;
uniform float tick_width = 0.02;

uniform float border_width_px: hint_range(0.0, 100.0, 1.0) = 30.0;

void fragment() {
	// this is my custom way of transforming uv_x
	// this successfully increases the width of the first cell on the left
	// (though I have to set border_width
	// the last cell on the right is still too narrow though
	float border_width_uv = SCREEN_PIXEL_SIZE.x * (border_width_px * 0.5);
	float uv_x = (UV.x - .5 * border_width_uv) / (1.0 - border_width_uv);
	uv_x = clamp(uv_x, 0.0, 1.0);
	
	float cell_count = max_health + shield;
	float tick_offset = 0.5 * float(int(cell_count + 1.0) % 2);
	float cell_uv_x = fract(tick_offset + (uv_x - 0.5) * cell_count);
	float cell_idx = floor(tick_offset + (uv_x - 0.5) * cell_count);

	// make tick width relative to number of cells (~= cell size)
	float rel_half_tick_width = tick_width * cell_count / 2.0;
	// determine if tick should be drawn at this uv_x
	float in_tick = float(cell_uv_x < 0.5 + rel_half_tick_width && cell_uv_x > 0.5 - rel_half_tick_width);
	// filter ticks at left and right ends of the healthbar
	in_tick *= float(cell_idx > -cell_count/2.0) * float(cell_idx < floor(cell_count/2.0));
	// mix healthy and background colors
	vec4 color = mix(healthy_color, bg_color, float(health / cell_count < uv_x));
	float is_shield = float(shield / cell_count > (1.0 - uv_x));
	// mix in shield color
	color = is_shield * shield_color + (1.0 - is_shield) * color;
	// mix in visual ticks
	color = mix(color, tick_base_color, in_tick);
	// blend mult with the Panel flatbox
	COLOR *= color;
}

