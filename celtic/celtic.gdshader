shader_type canvas_item;

uniform float zoom = 1.65;
uniform vec2 center = vec2(-0.25, 0.0);
uniform int max_iter = 320;
uniform float mirror_strength = 1.0;

vec3 palette(float t) {
	vec3 forest = vec3(0.015, 0.12, 0.085);
	vec3 emerald = vec3(0.08, 0.92, 0.5);
	vec3 lavender = vec3(0.72, 0.32, 1.0);
	vec3 color = mix(forest, emerald, smoothstep(0.0, 0.62, t));
	color = mix(color, lavender, smoothstep(0.62, 1.0, t));
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
		float raw_real_component = z.x * z.x - z.y * z.y;
		float real_component = mix(raw_real_component, abs(raw_real_component), mirror_strength);
		float imaginary_component = 2.0 * z.x * z.y;
		z = vec2(real_component, imaginary_component) + c;
		radius_squared = dot(z, z);
		iteration = float(i);
		if (radius_squared > 256.0) {
			break;
		}
	}

	if (radius_squared <= 256.0) {
		COLOR = vec4(0.003, 0.012, 0.009, 1.0);
	} else {
		float smooth_iteration = iteration + 1.0 - log2(log2(sqrt(radius_squared)));
		float t = fract(smooth_iteration * 0.032 + 0.12);
		float glow = 0.76 + 0.24 * sin(smooth_iteration * 0.44);
		COLOR = vec4(palette(t) * glow, 1.0);
	}
}
