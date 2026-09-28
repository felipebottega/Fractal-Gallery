shader_type canvas_item;

uniform float zoom = 1.45;
uniform vec2 center = vec2(-0.5, -0.55);
uniform int max_iter = 350;
uniform float heat = 0.7;

vec3 palette(float t) {
	vec3 ember = vec3(0.96, 0.12, 0.035);
	vec3 gold = vec3(1.0, 0.72, 0.08);
	vec3 smoke = vec3(0.18, 0.025, 0.035);
	vec3 color = mix(smoke, ember, smoothstep(0.0, 0.5, t));
	color = mix(color, gold, smoothstep(0.5, 1.0, t));
	vec3 hot_color = mix(color, vec3(1.0, 0.86, 0.26), heat * 0.38);
	return hot_color * (0.52 + heat * 0.72);
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
		z = abs(z);
		z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
		radius_squared = dot(z, z);
		iteration = float(i);
		if (radius_squared > 256.0) {
			break;
		}
	}

	if (radius_squared <= 256.0) {
		COLOR = vec4(0.008, 0.004, 0.008, 1.0);
	} else {
		float smooth_iteration = iteration + 1.0 - log2(log2(sqrt(radius_squared)));
		float t = fract(smooth_iteration * (0.02 + heat * 0.018) + heat * 0.12);
		float glow = 0.72 + 0.28 * sin(smooth_iteration * 0.36);
		float edge_strength = smoothstep(1.5, 11.0, smooth_iteration);
		vec3 color = mix(vec3(0.025, 0.003, 0.006), palette(t) * glow, edge_strength);
		COLOR = vec4(color, 1.0);
	}
}
