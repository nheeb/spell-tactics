vec2 rotateUV(vec2 uv, vec2 pivot, float angle) {
    float sine = sin(angle);
    float cosine = cos(angle);

    uv -= pivot;
    uv.x = uv.x * cosine - uv.y * sine;
    uv.y = uv.x * sine + uv.y * cosine;
    uv += pivot;

    return uv;
}

vec2 rotateVector(vec2 _v, float angle) {
	float sine = sin(angle);
    float cosine = cos(angle);
	
	vec2 v;
	
    v.x = _v.x * cosine - _v.y * sine;
    v.y = _v.x * sine + _v.y * cosine;

    return v;
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

float circle_dist(float value, float circle_size) {
	float mod_value = mod(value, circle_size);
	return min(mod_value, circle_size - mod_value);
}