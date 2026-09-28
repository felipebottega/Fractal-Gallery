shader_type canvas_item;

uniform float zoom = 1.8;
uniform vec2 center = vec2(0.0);
uniform int max_iter = 300;
uniform float conjugate_strength = 1.0;

vec3 palette(float t) {
	vec3 navy = vec3(0.018, 0.025, 0.11);
	vec3 violet = vec3(0.5, 0.2, 0.98);
	vec3 ice = vec3(0.36, 0.9, 1.0);
	vec3 color = mix(navy, violet, smoothstep(0.0, 0.58, t));
	color = mix(color, ice, smoothstep(0.58, 1.0, t));
	return color * 1.05;
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	uv.y = -uv.y;
	uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 c = uv * zoom + center;
	vec2 z = vec2(0.0);
	float iteration = 0.0;
	float radius_squared = 0.0;

	for (int i = 0; i < max_iter; i++) {
		float regular_imaginary = 2.0 * z.x * z.y;
		float conjugated_imaginary = -regular_imaginary;
		z = vec2(z.x * z.x - z.y * z.y, mix(regular_imaginary, conjugated_imaginary, conjugate_strength)) + c;
		radius_squared = dot(z, z);
		iteration = float(i);
		if (radius_squared > 256.0) {
			break;
		}
	}

	if (radius_squared <= 256.0) {
		COLOR = vec4(0.004, 0.005, 0.02, 1.0);
	} else {
		float smooth_iteration = iteration + 1.0 - log2(log2(sqrt(radius_squared)));
		float t = fract(smooth_iteration * 0.033 + 0.1);
		float glow = 0.75 + 0.25 * sin(smooth_iteration * 0.5);
		COLOR = vec4(palette(t) * glow, 1.0);
	}
}
