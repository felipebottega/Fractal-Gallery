shader_type canvas_item;

uniform int fractal_type : hint_range(0, 5) = 0;
uniform float zoom : hint_range(0.2, 2.0) = 0.8;
uniform vec2 offset = vec2(0.0);
uniform vec3 accent : source_color = vec3(0.2, 0.8, 1.0);

vec3 palette(float t, vec3 base) {
	vec3 warm = vec3(1.0, 0.62, 0.22);
	vec3 deep = vec3(0.015, 0.018, 0.035);
	return mix(deep, mix(base, warm, 0.5 + 0.5 * sin(t * 5.4)), smoothstep(0.02, 0.98, t));
}

void fragment() {
	vec2 p = (UV - 0.5) * vec2(3.25, 2.05) * zoom;
	p.y = -p.y;
	p += offset;
	vec2 z;
	vec2 c;
	float escaped = 0.0;
	float iter = 0.0;
	float metric = 0.0;
	const int MAX_ITER = 96;
	if (fractal_type == 1) {
		z = p;
		c = vec2(-0.745, 0.113);
	} else if (fractal_type == 4) {
		z = p * 1.2;
		for (int i = 0; i < 42; i++) {
			float x = z.x;
			float y = z.y;
			vec2 z2 = vec2(x*x - y*y, 2.0*x*y);
			vec2 z3 = vec2(z2.x*x - z2.y*y, z2.x*y + z2.y*x);
			vec2 f = z3 - vec2(1.0, 0.0);
			vec2 df = 3.0 * z2;
			float den = max(dot(df, df), 0.000001);
			vec2 quotient = vec2(f.x*df.x + f.y*df.y, f.y*df.x - f.x*df.y) / den;
			z -= quotient;
			iter = float(i);
			if (dot(f, f) < 0.0000008) break;
		}
		vec3 root_a = vec3(0.16, 0.85, 0.62);
		vec3 root_b = vec3(0.92, 0.35, 0.55);
		vec3 root_c = vec3(0.28, 0.48, 1.0);
		float da = length(z - vec2(1.0, 0.0));
		float db = length(z - vec2(-0.5, 0.8660254));
		float dc = length(z - vec2(-0.5, -0.8660254));
		vec3 root_col = da < db && da < dc ? root_a : (db < dc ? root_b : root_c);
		float shade = 0.34 + 0.66 * (1.0 - iter / 42.0);
		COLOR = vec4(root_col * shade, 1.0);
	} else {
		z = vec2(0.0);
		c = p;
	}
	if (fractal_type != 4) {
		for (int i = 0; i < MAX_ITER; i++) {
			if (fractal_type == 2) z = abs(z);
			if (fractal_type == 3) z.y = -z.y;
			float x = z.x*z.x - z.y*z.y;
			float y = 2.0*z.x*z.y;
			if (fractal_type == 5) x = abs(x);
			z = vec2(x, y) + c;
			metric = dot(z, z);
			if (metric > 256.0) {
				escaped = 1.0;
				iter = float(i) + 1.0 - log2(log2(max(metric, 2.0)));
				break;
			}
		}
		if (escaped < 0.5) {
			COLOR = vec4(vec3(0.006, 0.008, 0.015), 1.0);
		} else {
			float t = fract(iter * 0.035 + 0.04 * sin(iter * 0.42));
			vec3 col = palette(t, accent);
			float glow = 0.82 + 0.18 * sin(iter * 0.7);
			COLOR = vec4(col * glow, 1.0);
		}
	}
}
