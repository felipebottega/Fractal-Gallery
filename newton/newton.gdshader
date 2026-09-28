shader_type canvas_item;

uniform float zoom = 1.45;
uniform vec2 center = vec2(0.0);
uniform int max_iter = 80;
uniform float precision = 9.0;
uniform float a_0 = -1.0;
uniform float a_1 = 0.0;
uniform float a_2 = 0.0;
uniform float a_3 = 1.0;
uniform float a_4 = 0.0;
uniform float a_5 = 0.0;
uniform float a_6 = 0.0;

const float DERIVATIVE_EPSILON = 0.0000001;


vec2 complex_multiply(vec2 z, vec2 w) {
	return vec2(z.x * w.x - z.y * w.y, z.x * w.y + z.y * w.x);
}

vec2 complex_divide(vec2 numerator, vec2 denominator) {
	float divisor = dot(denominator, denominator);
	return vec2(
		numerator.x * denominator.x + numerator.y * denominator.y,
		numerator.y * denominator.x - numerator.x * denominator.y
	) / divisor;
}


vec2 evaluate_polynomial(vec2 z) {
	vec2 value = a_6 * z + vec2(a_5, 0.0);
	value = complex_multiply(value, z) + vec2(a_4, 0.0);
	value = complex_multiply(value, z) + vec2(a_3, 0.0);
	value = complex_multiply(value, z) + vec2(a_2, 0.0);
	value = complex_multiply(value, z) + vec2(a_1, 0.0);
	return complex_multiply(value, z) + vec2(a_0, 0.0);
}


vec2 evaluate_derivative(vec2 z) {
	vec2 value = 6.0 * a_6 * z + vec2(5.0 * a_5, 0.0);
	value = complex_multiply(value, z) + vec2(4.0 * a_4, 0.0);
	value = complex_multiply(value, z) + vec2(3.0 * a_3, 0.0);
	value = complex_multiply(value, z) + vec2(2.0 * a_2, 0.0);
	return complex_multiply(value, z) + vec2(a_1, 0.0);
}

vec3 palette(float phase) {
	return 0.55 + 0.45 * cos(TAU * (phase + vec3(0.0, 0.33, 0.67)));
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	uv.y = -uv.y;
	uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 z = uv * zoom + center;
	float iteration = 0.0;
	float error = 1.0;

	for (int i = 0; i < max_iter; i++) {
		vec2 function_value = evaluate_polynomial(z);
		error = dot(function_value, function_value);
		iteration = float(i);
		if (error < pow(10.0, -precision)) {
			break;
		}

		vec2 derivative = evaluate_derivative(z);
		if (dot(derivative, derivative) < DERIVATIVE_EPSILON) {
			iteration = float(max_iter);
			break;
		}
		z -= complex_divide(function_value, derivative);
		float radius = length(z);
		if (radius > 50.0) {
			z *= 50.0 / radius;
		}
	}

	float root_phase = fract(atan(z.y, z.x) / TAU + 1.0);
	vec3 root_color = palette(root_phase);
	float convergence = 1.0 - clamp(iteration / float(max_iter), 0.0, 1.0);
	float iteration_texture = 0.92 + 0.08 * cos(iteration * 0.75);
	float brightness = (0.28 + 0.78 * pow(convergence, 0.38)) * iteration_texture;
	COLOR = vec4(root_color * brightness, 1.0);
}
