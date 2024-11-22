shader_type canvas_item;

uniform float grey_out_progress: hint_range(0.0, 1.0, 0.1) = 0.0;
//uniform float luminance_factor = .8;

void fragment() {
    // Calculate the luminance (perceived brightness) of the current color
    float luminance = dot(COLOR.rgb, vec3(0.299, 0.587, 0.114));
    vec3 grey_color = vec3(luminance);

    vec3 final_color = mix(COLOR.rgb, grey_color, grey_out_progress);
    COLOR.rgb = final_color;
}