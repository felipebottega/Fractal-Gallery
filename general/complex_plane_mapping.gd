extends RefCounted


static func screen_to_complex(
	screen_position: Vector2,
	viewport_size: Vector2,
	zoom: float,
	center: Vector2
) -> Vector2:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return center

	var normalized := screen_position / viewport_size
	normalized = normalized * 2.0 - Vector2.ONE
	normalized.y = -normalized.y
	normalized.x *= viewport_size.x / viewport_size.y
	return normalized * zoom + center


static func screen_delta_to_complex(
	screen_delta: Vector2,
	viewport_size: Vector2,
	zoom: float
) -> Vector2:
	if viewport_size.y <= 0.0:
		return Vector2.ZERO

	return Vector2(screen_delta.x, -screen_delta.y) * (2.0 * zoom / viewport_size.y)
