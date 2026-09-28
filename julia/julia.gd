extends Node2D

const COMPLEX_PLANE := preload("res://general/complex_plane_mapping.gd")

var zoom: float = 2.0
var zoom_speed := 1.2
var center := Vector2.ZERO
var dragging := false
var viewport_size: Vector2

@onready var fractal_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var fractal_display: ColorRect = $SubViewportContainer/SubViewport/ColorRect


func _ready() -> void:
	zoom = float(fractal_display.material.get_shader_parameter("zoom"))
	center = Vector2(fractal_display.material.get_shader_parameter("center"))
	viewport_size = get_viewport().get_visible_rect().size
	fractal_viewport.size = viewport_size
	fractal_display.size = viewport_size
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://main.tscn")

func _on_viewport_size_changed() -> void:
	viewport_size = get_viewport().get_visible_rect().size
	fractal_viewport.size = viewport_size
	fractal_display.size = viewport_size

func _input(event: InputEvent) -> void:
	var mouse_position := get_viewport().get_mouse_position()

	if mouse_position.x > 0.7 * viewport_size.x and mouse_position.y < 0.25 * viewport_size.y:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed and zoom > 0.000001:
			var position_before_zoom := _get_fractal_position(mouse_position)
			zoom /= zoom_speed
			fractal_display.material.set_shader_parameter("zoom", zoom)
			var position_after_zoom := _get_fractal_position(mouse_position)
			center += position_before_zoom - position_after_zoom
			fractal_display.material.set_shader_parameter("center", center)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed and zoom < 2.0:
			var position_before_zoom := _get_fractal_position(mouse_position)
			zoom *= zoom_speed
			fractal_display.material.set_shader_parameter("zoom", zoom)
			var position_after_zoom := _get_fractal_position(mouse_position)
			center += position_before_zoom - position_after_zoom
			fractal_display.material.set_shader_parameter("center", center)

	if event is InputEventMouseMotion and dragging:
		var drag_delta := COMPLEX_PLANE.screen_delta_to_complex(event.relative, viewport_size, zoom)
		center -= drag_delta
		fractal_display.material.set_shader_parameter("center", center)

func _get_fractal_position(mouse_position: Vector2) -> Vector2:
	return COMPLEX_PLANE.screen_to_complex(mouse_position, viewport_size, zoom, center)

func _on_c_real_value_changed(value: float) -> void:
	fractal_display.material.set_shader_parameter("c_real", value)
	$CanvasLayer/CReal/Value.text = "%.3f" % value

func _on_c_imaginary_value_changed(value: float) -> void:
	fractal_display.material.set_shader_parameter("c_imaginary", value)
	$CanvasLayer/CImaginary/Value.text = "%.3f" % value

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
