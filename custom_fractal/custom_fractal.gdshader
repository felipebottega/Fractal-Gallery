shader_type canvas_item;

uniform float zoom = 2.0;
uniform vec2 center = vec2(0.0, 0.0);
uniform int max_iter = 500;
uniform float colors = 0.5;
uniform float a_1 = 0.0;
uniform float a_2 = 1.0;
uniform float a_3 = 0.0;
uniform float a_4 = 0.0;
uniform float a_5 = 0.0;
uniform float a_6 = 0.0;

const float COEFFICIENT_EPSILON = 0.000001;


vec2 complex_multiply(vec2 z, vec2 w) {
	return vec2(z.x * w.x - z.y * w.y, z.x * w.y + z.y * w.x);
}


vec3 palette(int iteration) {
	float t = float(iteration) / float(max_iter);
	if (iteration < int(0.01 * float(max_iter))) {
		return vec3(0.0);
	}
	t = (t - 0.1) / 0.8;
	t = pow(t, 0.2);
	return 0.5 + colors * cos(2.0 * colors * TAU * (t + vec3(0.0, 0.25, 0.5)));
}


float get_escape_radius_squared() {
	float leading_coefficient = 0.0;
	float degree = 0.0;

	if (abs(a_6) > COEFFICIENT_EPSILON) {
		leading_coefficient = abs(a_6);
		degree = 6.0;
	} else if (abs(a_5) > COEFFICIENT_EPSILON) {
		leading_coefficient = abs(a_5);
		degree = 5.0;
	} else if (abs(a_4) > COEFFICIENT_EPSILON) {
		leading_coefficient = abs(a_4);
		degree = 4.0;
	} else if (abs(a_3) > COEFFICIENT_EPSILON) {
		leading_coefficient = abs(a_3);
		degree = 3.0;
	} else if (abs(a_2) > COEFFICIENT_EPSILON) {
		leading_coefficient = abs(a_2);
		degree = 2.0;
	}

	if (degree < 2.0) {
		return 4.0;
	}

	// R = 2 / |a_d|^(1 / (d - 1)); return R squared.
	return 4.0 / pow(leading_coefficient, 2.0 / (degree - 1.0));
}


vec4 compute_iteration(vec2 c) {
	vec2 z = vec2(0.0);
	float escape_radius_squared = get_escape_radius_squared();
	for (int iteration = 0; iteration < max_iter; iteration++) {
		// Evaluate a6*z^6 + ... + a1*z + c with Horner's method.
		vec2 polynomial = a_6 * z + vec2(a_5, 0.0);
		polynomial = complex_multiply(polynomial, z) + vec2(a_4, 0.0);
		polynomial = complex_multiply(polynomial, z) + vec2(a_3, 0.0);
		polynomial = complex_multiply(polynomial, z) + vec2(a_2, 0.0);
		polynomial = complex_multiply(polynomial, z) + vec2(a_1, 0.0);
		z = complex_multiply(polynomial, z) + c;

		// Compare squared magnitudes to avoid a square root per iteration.
		if (dot(z, z) > escape_radius_squared) {
			return vec4(palette(iteration), 1.0);
		}
	}
	return vec4(1.0);
}


void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	uv.y = -uv.y;
	uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	uv = uv * zoom + center;
	COLOR = compute_iteration(uv);
}
