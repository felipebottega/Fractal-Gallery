shader_type canvas_item;

uniform vec3 light_color : source_color = vec3(0.72, 0.88, 1.0);
uniform float specular_strength : hint_range(0.0, 1.0) = 0.38;
uniform float edge_darkening : hint_range(0.0, 1.0) = 0.42;


void fragment() {
	vec2 sphere_position = UV * 2.0 - 1.0;
	float radius_squared = dot(sphere_position, sphere_position);
	if (radius_squared > 1.0) {
		discard;
	}

	float sphere_depth = sqrt(max(1.0 - radius_squared, 0.0));
	vec3 normal = normalize(vec3(sphere_position, sphere_depth));

	// Stretch the center of the original sprite toward the circular silhouette.
	vec2 sample_position = sphere_position * (0.78 + 0.22 * sphere_depth);
	vec2 sample_uv = sample_position * 0.5 + 0.5;
	vec4 sprite_color = texture(TEXTURE, sample_uv);

	vec3 light_direction = normalize(vec3(-0.48, -0.58, 0.82));
	float diffuse = 0.58 + 0.42 * max(dot(normal, light_direction), 0.0);
	float edge = pow(1.0 - sphere_depth, 1.7);
	vec3 view_direction = vec3(0.0, 0.0, 1.0);
	vec3 reflected_light = reflect(-light_direction, normal);
	float specular = pow(max(dot(reflected_light, view_direction), 0.0), 28.0);

	vec3 shaded_color = sprite_color.rgb * diffuse;
	shaded_color *= 1.0 - edge * edge_darkening;
	shaded_color += light_color * specular * specular_strength;
	shaded_color += light_color * edge * 0.07;

	float circular_alpha = 1.0 - smoothstep(0.96, 1.0, sqrt(radius_squared));
	COLOR = vec4(shaded_color, sprite_color.a * circular_alpha);
}
