extends CharacterBody2D

# -- MOVEMENT VARS --
@export var camera: Camera2D
@export var max_speed := 500.0
@export var acceleration := 3000.0
@export var friction := 30 # Velocity is multiplied by (1 - this * delta). The higher, the more friction.
# -- GAMEPLAY VARS --
@export var max_health := 100
var health: int
# -- GUN VARS --
@export var max_ammo := 10
var ammo: int
@export var bullet_cooldown_timer: Timer
@export var reload_timer: Timer

func _ready() -> void:
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Camera logic. Note the camera and player start CENTERED at 0,0.
	camera.position = position
	#movement
	var direction: Vector2
	direction.x = Input.get_axis("movement_left", "movement_right")
	direction.y = Input.get_axis("movement_up", "movement_down")
	direction = direction.normalized()
	print(direction)
	if direction != Vector2.ZERO:
		velocity += direction * acceleration * delta
	else:
		velocity *= 1 - (friction * delta)
	velocity = velocity.limit_length(max_speed)
	move_and_slide()
