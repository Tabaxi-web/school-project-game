extends Node2D

@export var init_velocity_y := 5.0
@export var init_velocity_x := 5.0
@export var gravity := 0.5
@export var label: Label
@export var stopping_velocity := 5.0
var velocity_y
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Give it some random velocity on instantiation
	velocity_y = init_velocity_y
	init_velocity_x *= randf_range(-1, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# move it as long as velocity_y > an amount
	if velocity_y < stopping_velocity:
		move_local_x(init_velocity_x)
		velocity_y += gravity * delta
		move_local_y(velocity_y)


func _on_timer_timeout() -> void:
	# Delete after a time
	queue_free()
