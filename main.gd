extends Node2D


const ARTWORK_SCENE := preload("res://general/artwork.gd")
const GALLERY_LENGTH := 5920.0
const FLOOR_Y := 620.0
const TRANSITION_DURATION := 1.0
const MAX_PIXEL_SIZE := 128.0
const EXHIBITS := [
	{"title": "MANDELBROT", "subtitle": "z² + c", "type": 0, "x": 520.0, "accent": Color("#49c6e5"), "zoom": 0.78, "offset": Vector2(-0.48, 0.0), "scene": "res://mandelbrot/mandelbrot.tscn"},
	{"title": "JULIA", "subtitle": "c = −0.745 + 0.113i", "type": 1, "x": 1290.0, "accent": Color("#f7b267"), "zoom": 0.72, "offset": Vector2.ZERO, "scene": "res://julia/julia.tscn"},
	{"title": "BURNING SHIP", "subtitle": "|Re(z)| + i|Im(z)|", "type": 2, "x": 2060.0, "accent": Color("#ff5a5f"), "zoom": 0.72, "offset": Vector2(-0.48, -0.48), "scene": "res://burning_ship/burning_ship.tscn"},
	{"title": "TRICORN", "subtitle": "conjugate(z)² + c", "type": 3, "x": 2830.0, "accent": Color("#b79ced"), "zoom": 0.76, "offset": Vector2(-0.25, 0.0), "scene": "res://tricorn/tricorn.tscn"},
	{"title": "NEWTON", "subtitle": "roots of z³ − 1", "type": 4, "x": 3600.0, "accent": Color("#78e08f"), "zoom": 0.88, "offset": Vector2.ZERO, "scene": "res://newton/newton.tscn"},
	{"title": "CELTIC", "subtitle": "Celtic Mandelbrot", "type": 5, "x": 4370.0, "accent": Color("#e056fd"), "zoom": 0.7, "offset": Vector2(-0.42, 0.0), "scene": "res://celtic/celtic.tscn"},
	{"title": "CUSTOM FRACTAL", "subtitle": "a₆z⁶ + ··· + a₁z + c", "type": 0, "x": 5140.0, "accent": Color("#55c1a7"), "zoom": 1.0, "offset": Vector2.ZERO, "scene": "res://custom_fractal/custom_fractal.tscn", "custom": true},
]

var is_transitioning := false

@onready var pixelate_overlay: ColorRect = $PixelTransition/PixelateOverlay


func _ready() -> void:
	_build_exhibits()
	_build_collisions()
	_build_exhibit_portals()
	queue_redraw()
	
	$Interface/Version.text = "v" + ProjectSettings.get_setting("application/config/version")

func _build_exhibits() -> void:
	for data: Dictionary in EXHIBITS:
		var artwork := ARTWORK_SCENE.new()
		artwork.position = Vector2(data.x, 122.0)
		artwork.title = data.title
		artwork.subtitle = data.subtitle
		artwork.fractal_type = data.type
		artwork.accent = data.accent
		artwork.fractal_zoom = data.zoom
		artwork.fractal_offset = data.offset
		artwork.customizable = data.get("custom", false)
		add_child(artwork)

func _build_collisions() -> void:
	var ground := StaticBody2D.new()
	ground.name = "GalleryFloor"
	var floor_shape := CollisionShape2D.new()
	var floor_rect := RectangleShape2D.new()
	floor_rect.size = Vector2(GALLERY_LENGTH, 90.0)
	floor_shape.shape = floor_rect
	floor_shape.position = Vector2(GALLERY_LENGTH * 0.5, FLOOR_Y + 45.0)
	ground.add_child(floor_shape)
	add_child(ground)

	for x_pos in [45.0, GALLERY_LENGTH - 45.0]:
		var wall_shape := CollisionShape2D.new()
		var wall_rect := RectangleShape2D.new()
		wall_rect.size = Vector2(70.0, 720.0)
		wall_shape.shape = wall_rect
		wall_shape.position = Vector2(x_pos, 360.0)
		ground.add_child(wall_shape)

func _build_exhibit_portals() -> void:
	for data: Dictionary in EXHIBITS:
		var portal := Area2D.new()
		portal.name = "%sPortal" % data.title.to_pascal_case()
		portal.position = Vector2(data.x + 260.0, 287.0)
		
		var portal_shape := CollisionShape2D.new()
		var portal_rect := RectangleShape2D.new()
		portal_rect.size = Vector2(520.0, 330.0)
		portal_shape.shape = portal_rect
		portal.add_child(portal_shape)
		portal.body_entered.connect(_on_exhibit_portal_entered.bind(portal, data.scene))
		add_child(portal)

func _on_exhibit_portal_entered(body: Node2D, portal: Area2D, scene_path: String) -> void:
	if body == $Player and not body.is_on_floor() and not is_transitioning:
		is_transitioning = true
		portal.set_deferred("monitoring", false)
		await _pixelate_transition()
		get_tree().change_scene_to_file(scene_path)

func _pixelate_transition() -> void:
	var material := pixelate_overlay.material as ShaderMaterial
	material.set_shader_parameter("pixel_size", 1.0)
	pixelate_overlay.show()
	await get_tree().process_frame

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_method(
		func(pixel_size: float) -> void:
			material.set_shader_parameter("pixel_size", pixel_size), 1.0, MAX_PIXEL_SIZE, TRANSITION_DURATION)
	await tween.finished

func _draw() -> void:
	draw_rect(Rect2(0, 0, GALLERY_LENGTH, FLOOR_Y), Color("#ebe6dc"))
	draw_rect(Rect2(0, 70, GALLERY_LENGTH, 6), Color("#d8d0c2"))
	draw_rect(Rect2(0, 505, GALLERY_LENGTH, 8), Color("#c8bdad"))
	draw_rect(Rect2(0, 513, GALLERY_LENGTH, 107), Color("#ddd5c8"))
	draw_rect(Rect2(0, FLOOR_Y, GALLERY_LENGTH, 100), Color("#262a30"))
	draw_rect(Rect2(0, FLOOR_Y, GALLERY_LENGTH, 7), Color("#b29b72"))
	
	for x_pos in range(0, int(GALLERY_LENGTH), 260):
		draw_line(Vector2(x_pos, FLOOR_Y + 8), Vector2(x_pos + 50, 720), Color(1, 1, 1, 0.035), 2.0)
	
	for data: Dictionary in EXHIBITS:
		var x: float = data.x
		draw_circle(Vector2(x + 260, 51), 13.0, Color("#272b32"))
		var light_points := PackedVector2Array([Vector2(x + 247, 64), Vector2(x + 273, 64), Vector2(x + 390, 465), Vector2(x + 130, 465)])
		draw_colored_polygon(light_points, Color(1.0, 0.92, 0.72, 0.065))
	
	_draw_wall_text(Vector2(120, 215), "FRACTAL\nGALLERY", 38, Color("#31343a"))
	_draw_wall_text(Vector2(5720, 230), "END OF\nEXHIBITION", 18, Color("#55585e"))

func _draw_wall_text(pos: Vector2, text: String, size: int, color: Color) -> void:
	var font := ThemeDB.fallback_font
	var y := pos.y
	
	for line in text.split("\n"):
		draw_string(font, Vector2(pos.x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
		y += size + 8

func _on_exit_pressed() -> void:
	get_tree().quit()
