shader_type canvas_item;

uniform float height: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float width: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform vec4 albedo: source_color;

void fragment() {
    // Adjust these multipliers to control the stretching of the ellipse
    float x_radius = width / 2.0; // Half of width
    float y_radius = height / 2.0; // Half of height

    // Calculate the distance to the center of the ellipse
    float dist = distance(vec2(UV.x, UV.y), vec2(0.5, 0.5)) * 2.0; // Normalized distance to the center

    // Normalize the distance by the radii of the ellipse
    float ellipseDist = sqrt(
        pow((UV.x - 0.5) / x_radius, 2.0) +
        pow((UV.y - 0.5) / y_radius, 2.0)
    );

    float edgeSoftness = 0.01;  // Control the softness of the edge

    // Use smoothstep to create a soft edge around the radius of 1, normalized
    float alpha = smoothstep(1.0 + edgeSoftness, 1.0 - edgeSoftness, ellipseDist);

    // Apply the smoothed alpha to the color output
    COLOR = vec4(albedo.rgb, albedo.a * alpha);
}
