extends Camera2D

var stress = 0 # How much the camera is shaking at a given time
@export var shake_strength := 50
@export var decay := 0.9999
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Randomise position by 50 * a random number * stress.
	position.x = shake_strength * randf_range(-1, 1) * stress
	position.y = shake_strength * randf_range(-1, 1) * stress
	# Multiplicatively decrease stress
	stress *= decay * delta
func shake(strength):
	# Increase stress to a max of 1
	stress = clampf(stress + strength, 0, 3)
	
