class_name FractalArtwork
extends Node2D


var title := "FRACTAL"
var subtitle := ""
var fractal_type := 0
var accent := Color.WHITE
var fractal_zoom := 1.0
var fractal_offset := Vector2.ZERO
var customizable := false
const SHADER := preload("res://general/fractals.gdshader")
const SIZE := Vector2(520, 330)


func _ready() -> void:
	_build_frame()

func _build_frame() -> void:
	var shadow := ColorRect.new()
	shadow.position = Vector2(14, 16)
	shadow.size = SIZE + Vector2(32, 32)
	shadow.color = Color(0.05, 0.055, 0.065, 0.24)
	add_child(shadow)
	
	var outer := ColorRect.new()
	outer.position = Vector2(-16, -16)
	outer.size = SIZE + Vector2(32, 32)
	outer.color = Color("#292b31")
	add_child(outer)
	
	var accent_line := ColorRect.new()
	accent_line.position = Vector2(-8, -8)
	accent_line.size = SIZE + Vector2(16, 16)
	accent_line.color = accent.darkened(0.5)
	add_child(accent_line)
	
	var matte := ColorRect.new()
	matte.size = SIZE
	matte.color = Color.WHITE if customizable else Color("#0b0c10")
	add_child(matte)
	
	if not customizable:
		_build_fractal_preview()
	_build_plaque()

func _build_fractal_preview() -> void:
	var image := ColorRect.new()
	image.name = "RealtimeFractal"
	image.position = Vector2(12, 12)
	image.size = SIZE - Vector2(24, 24)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var material := ShaderMaterial.new()
	material.shader = SHADER
	material.set_shader_parameter("fractal_type", fractal_type)
	material.set_shader_parameter("zoom", fractal_zoom)
	material.set_shader_parameter("offset", fractal_offset)
	material.set_shader_parameter("accent", Vector3(accent.r, accent.g, accent.b))
	image.material = material
	add_child(image)

func _build_plaque() -> void:
	var plaque := ColorRect.new()
	plaque.position = Vector2(78, SIZE.y + 34)
	plaque.size = Vector2(364, 66)
	plaque.color = Color("#f6f2e9")
	add_child(plaque)
	
	var title_label := Label.new()
	title_label.position = Vector2(14, 8)
	title_label.size = Vector2(336, 25)
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color("#25272c"))
	title_label.add_theme_font_size_override("font_size", 18)
	plaque.add_child(title_label)
	
	var subtitle_label := Label.new()
	subtitle_label.position = Vector2(14, 34)
	subtitle_label.size = Vector2(336, 21)
	subtitle_label.text = subtitle
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_color_override("font_color", Color("#666970"))
	subtitle_label.add_theme_font_size_override("font_size", 12)
	plaque.add_child(subtitle_label)
