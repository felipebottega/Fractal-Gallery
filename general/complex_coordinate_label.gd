extends Label

const ZERO_THRESHOLD := 0.000000005
const COMPLEX_PLANE := preload("res://general/complex_plane_mapping.gd")

@onready var fractal_display: ColorRect = get_node("../../SubViewportContainer/SubViewport/ColorRect")


func _process(_delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var shader_material := fractal_display.material as ShaderMaterial
	var zoom := float(shader_material.get_shader_parameter("zoom"))
	var center := Vector2(shader_material.get_shader_parameter("center"))
	var point := COMPLEX_PLANE.screen_to_complex(get_viewport().get_mouse_position(), viewport_size, zoom, center)
	var real := 0.0 if abs(point.x) < ZERO_THRESHOLD else point.x
	var imaginary := 0.0 if abs(point.y) < ZERO_THRESHOLD else point.y
	var number_sign := "+" if imaginary >= 0.0 else "-"

	text = "%.8f %s %.8fi" % [real, number_sign, abs(imaginary)]
