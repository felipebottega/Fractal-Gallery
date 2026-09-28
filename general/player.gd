extends CharacterBody2D


var shadow_ground_y: float
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var speed := 310.0
@export var acceleration := 1500.0
@export var deceleration := 1900.0
@export var jump_velocity := -520.0
@onready var sprite: Sprite2D = $Sprite2D
@onready var shadow: Polygon2D = $Shadow


func _ready() -> void:
	shadow_ground_y = shadow.global_position.y

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var target_speed := direction * speed
	var rate := acceleration if direction != 0.0 else deceleration
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
			
	move_and_slide()
	shadow.global_position = Vector2(global_position.x, shadow_ground_y)
	_update_visuals(direction, delta)

func _update_visuals(direction: float, delta: float) -> void:
	if absf(velocity.x) > 8.0:
		sprite.position.y = -1.0 + 4 * sin(Time.get_ticks_msec() * 0.012) * 2.5
		sprite.rotation = lerp_angle(sprite.rotation, direction * 0.035, 8.0 * delta)
	else:
		sprite.position.y = lerpf(sprite.position.y, -1.0, 8.0 * delta)
		sprite.rotation = lerp_angle(sprite.rotation, 0.0, 8.0 * delta)
