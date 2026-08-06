extends Marker2D
## This is a simple acript to show the player where the enemies are.

@onready var sprite = $Sprite2D
@export var transparency_coefficient := 0.01
@export var min_transparency := 0.2
@export var max_transparency := 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var target: Node2D = _acquire()
	
	if is_instance_valid(target):
		look_at(target.global_position)
		sprite.modulate.a = clampf(position.distance_to(target.position) * transparency_coefficient, min_transparency, max_transparency)

func _acquire() -> Node2D:
	# Simple iterative function which finds the closest enemy. Enemy bullets will never be homing so no player compatibility needed.
	var min_distance := INF
	var new_target: Node2D
	for node in get_tree().get_nodes_in_group("Enemies"):
			if global_position.distance_squared_to(node.global_position) < min_distance:
				min_distance = global_position.distance_squared_to(node.global_position)
				new_target = node
	return new_target
