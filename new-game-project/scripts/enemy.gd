extends CharacterBody2D
@export var max_health := 100.0
var health: float
var player: CharacterBody2D
@export var health_bar : ProgressBar
@export var acceleration := 50
@export var max_speed := 200
@export var attack_area : Area2D
@export var attack_distance := 46
@export var attack_timer: Timer
var cooling_down := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	for node in get_tree().get_nodes_in_group("Player"):
		player = node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Health handling.
	if health <= 0:
		queue_free()
	health_bar.value = health / max_health
	# Movement.
	velocity += delta * acceleration * (player.position - position)
	velocity = velocity.limit_length(max_speed)
	move_and_slide()
	for body in attack_area.get_overlapping_bodies():
		if body == player and not cooling_down:
			cooling_down = true
			player.take_damage(1.0)
			set_deferred("attack_area.monitoring", false)
			attack_timer.start()

func take_damage(damage: float) -> void:
	health -= damage
	


func _on_attack_timer_timeout() -> void:
	print("recovered")
	cooling_down = false
