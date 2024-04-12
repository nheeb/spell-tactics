vec2 rotateUV(vec2 uv, vec2 pivot, float angle) {
    float sine = sin(angle);
    float cosine = cos(angle);

    uv -= pivot;
    uv.x = uv.x * cosine - uv.y * sine;
    uv.y = uv.x * sine + uv.y * cosine;
    uv += pivot;

    return uv;
}

mat3 rotation_matrix_x(float angle) {
    float sine = sin(angle);
    float cosine = cos(angle);
	vec3 x = vec3(1, 0, 0);
	vec3 y = vec3(0, cosine, sine);
	vec3 z = vec3(0, -sine, cosine);
	return mat3(x, y, z);
}

mat3 rotation_matrix_y(float angle) {
    float sine = sin(angle);
    float cosine = cos(angle);
	vec3 x = vec3(cosine, 0, -sine);
	vec3 y = vec3(0, 1, 0);
	vec3 z = vec3(sine, 0, cosine);
	return mat3(x, y, z);
}

mat3 rotation_matrix_z(float angle) {
    float sine = sin(angle);
    float cosine = cos(angle);
	vec3 x = vec3(cosine, sine, 0);
	vec3 y = vec3(-sine, cosine, 0);
	vec3 z = vec3(0, 0, 1);
	return mat3(x, y, z);
}

float clamp_and_map(float value, float istart, float istop, float ostart, float ostop) {
    value = clamp(value, istart, istop);
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

float clamp_and_map_and_pow(float value, float istart, float istop, float ostart, float ostop, float exponent) {
    value = clamp(value, istart, istop);
	float middle_value = pow(((value - istart) / (istop - istart)), exponent);
    return ostart + (ostop - ostart) * middle_value;
}

float invert(float value) {
	return 1.0 - value;
}

float positive_direction_of_vec2(vec2 v) {
	return PI/2.0 + atan(v.y / v.x) + PI * float(v.x < 0.0);
}

float is_in_range_as_float(float value, float a, float b) {
	return float( (value >= a && value <= b) || (value <= a && value >= b) );
}

//|-- Color Transformations, credit: https://github.com/paddy-exe/ShaderFunction-Extras
float grayscale(vec3 color) {
	float max1 = max(color.r, color.g);
	float max2 = max(max1, color.b);
	return max2;
}

vec3 hsv_to_rgb(vec3 color) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(color.xxx + K.xyz) * 6.0 - K.www);
	return color.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), color.y);
}

vec3 rgb_to_hsv(vec3 color) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(color.bg, K.wz), vec4(color.gb, K.xy), step(color.b, color.g));
	vec4 q = mix(vec4(p.xyw, color.r), vec4(color.r, p.yzx), step(p.x, color.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_adjustment(vec3 col, float hue_offset, float sat_offset, float val_offset) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(col.bg, K.wz), vec4(col.gb, K.xy), step(col.b, col.g));
	vec4 q = mix(vec4(p.xyw, col.r), vec4(col.r, p.yzx), step(p.x, col.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	vec3 hsv = vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	hsv.x += hue_offset / 360.0;
	hsv.y += sat_offset;
	hsv.z += val_offset;
	return hsv;
}
// Color Transformations --|