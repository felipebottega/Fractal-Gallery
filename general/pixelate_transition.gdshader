shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float pixel_size : hint_range(1.0, 128.0) = 1.0;

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = floor(SCREEN_UV * screen_size / pixel_size) * pixel_size / screen_size;
	COLOR = texture(screen_texture, uv);
}
