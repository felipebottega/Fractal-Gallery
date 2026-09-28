shader_type canvas_item;

uniform float zoom = 1.65;
uniform vec2 center = vec2(0.0);
uniform int max_iter = 300;
uniform float c_real = -0.745;
uniform float c_imaginary = 0.113;

vec3 palette(float t) {
	vec3 midnight = vec3(0.008, 0.012, 0.035);
	vec3 cyan = vec3(0.12, 0.88, 1.0);
	vec3 violet = vec3(0.62, 0.24, 0.95);
	vec3 coral = vec3(1.0, 0.42, 0.34);
	vec3 color = mix(cyan, violet, smoothstep(0.0, 0.55, t));
	color = mix(color, coral, smoothstep(0.55, 1.0, t));
	return mix(midnight, color, 0.82);
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	uv.y = -uv.y;
	uv.x *= SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 z = uv * zoom + center;
	vec2 c = vec2(c_real, c_imaginary);
	float iteration = 0.0;
	float radius_squared = 0.0;

	for (int i = 0; i < max_iter; i++) {
		z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
		radius_squared = dot(z, z);
		iteration = float(i);
		if (radius_squared > 256.0) {
			break;
		}
	}

	if (radius_squared <= 256.0) {
		COLOR = vec4(0.004, 0.006, 0.018, 1.0);
	} else {
		float smooth_iteration = iteration + 1.0 - log2(log2(sqrt(radius_squared)));
		float t = fract(smooth_iteration * 0.035 + 0.12);
		float glow = 0.78 + 0.22 * sin(smooth_iteration * 0.42);
		float edge_strength = smoothstep(1.5, 12.0, smooth_iteration);
		vec3 color = mix(vec3(0.006, 0.012, 0.035), palette(t) * glow, edge_strength);
		COLOR = vec4(color, 1.0);
	}
}
