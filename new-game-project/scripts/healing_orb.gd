extends Node2D

var player: CharacterBody2D
@export var speed := 300
@export var accel := 500
@export var burst_fx: PackedScene # the health effect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed += accel * delta
	position += speed * delta  * position.direction_to(player.position)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		player.health = clamp(player.health + Globals.healing_orbs_amount, 0, player.max_health)
		var burst = burst_fx.instantiate()
		burst.position = position
		burst.emitting = true
		add_sibling(burst)
		queue_free()
		
