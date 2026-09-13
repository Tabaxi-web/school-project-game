extends Marker2D
## This is a simple acript to show the player where the enemies are.
# the arrow moves around the player and gets closer when an enemy is close, so it never overlaps.
# This script is on the parent of the arrow itself, the arrow moves on the local x axis.
@onready var sprite = $Sprite2D
@export var transparency_coefficient := 0.01
@export var min_transparency := 0.0
@export var max_transparency := 1.0
@export var arrow_distance_max := 175.0
@export var arrow_min_distance_coeff := 3.0
@export var arrow_position_lerp_weight := 0.1
var sprite_target_position: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# This is a simple script for the indicator arrow toward enemies.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target: Node2D = _acquire()
	
	if is_instance_valid(target):
		# Rotate the PARENT to look at the enemy.
		look_at(target.global_position)
		
		# Move the arrow to a max of n, and a min of distance to enemy/x
		sprite_target_position.x = clampf(
				global_position.distance_to(target.global_position) / 
				arrow_min_distance_coeff, 0, arrow_distance_max
		)
	
	# Do some smoothing with lerps.
	sprite.position.x = lerp(
			sprite_target_position.x, sprite.position.x, 
			arrow_position_lerp_weight
	)


func _acquire() -> Node2D:
	# Simple iterative function which finds the closest enemy. 
	var min_distance := INF
	var new_target: Node2D
	# Find closest enemy with a simple for loop.
	for node in get_tree().get_nodes_in_group("Enemies"):
			if global_position.distance_squared_to(node.global_position) < min_distance:
				min_distance = global_position.distance_squared_to(node.global_position)
				new_target = node
	return new_target
