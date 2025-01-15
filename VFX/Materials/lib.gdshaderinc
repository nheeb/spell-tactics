vec2 rotateVector(vec2 _v, float angle) {
	float sine = sin(angle);
    float cosine = cos(angle);

	vec2 v;

    v.x = _v.x * cosine - _v.y * sine;
    v.y = _v.x * sine + _v.y * cosine;

    return v;
}

vec2 rotateUV(vec2 uv, vec2 pivot, float angle) {
    vec2 v = uv - pivot;
	v = rotateVector(v, angle);
	return v + pivot;
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
    float _value = clamp(value, istart, istop);
    float raw_progress = abs(abs(_value - istart) / abs(istop - istart));
    float clamped_progress = abs(clamp(raw_progress, 0.0, 1.0));
    float middle_value = pow(clamped_progress, exponent);
    return ostart + ((ostop - ostart) * middle_value);
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

// |-- Color Transformations, credit: https://github.com/paddy-exe/ShaderFunction-Extras
float grayscale(vec3 color) {
	float max1 = max(color.r, color.g);
	float max2 = max(max1, color.b);
	return max2;
}

const float GRAY_BRIGHTNESS = 0.5;
vec3 custom_grayscale(vec3 color) {
	return GRAY_BRIGHTNESS * vec3(grayscale(color));
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

float circle_dist(float value, float circle_size) {
	float mod_value = mod(value, circle_size);
	return min(mod_value, circle_size - mod_value);
}
float line_point_distance(vec3 line_origin, vec3 line_direction, vec3 point) {
	vec3 a = line_origin;
	vec3 b = line_origin + normalize(line_direction);
	return length(cross(point-a, point-b));
}

float norm_to_negative(float x) {
	return clamp_and_map(x, 0.0, 1.0, -1.0, 1.0);
}

float between(float x, float start, float end) {
	return float((x < end && x > start) || (x > end && x < start));
}

float vec2_between(vec2 x, vec2 a, vec2 b) {
	return between(x.x, a.x, b.x) * between(x.y, a.y, b.y);
}

vec2 uv_project(vec2 uv, vec2 aa, vec2 bb, vec2 target_aa, vec2 target_bb) {
	float x = clamp_and_map(uv.x, aa.x, bb.x, target_aa.x, target_bb.x);
	float y = clamp_and_map(uv.y, aa.y, bb.y, target_aa.y, target_bb.y);
	return vec2(x,y);
}

vec4 texture_project(sampler2D tex, vec2 uv, vec2 aa, vec2 bb, vec2 target_aa, vec2 target_bb) {
	vec4 color = texture(tex, uv_project(uv, aa, bb, target_aa, target_bb));
	return color * vec2_between(uv, aa, bb);
}

float random_float(vec2 seed) {
    return fract(sin(dot(seed.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

vec3 global_pos_from_vertex(vec3 vert, mat4 model_mat) {
	return (model_mat * vec4(vert, 1.0)).xyz;
}
