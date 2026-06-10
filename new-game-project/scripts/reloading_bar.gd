extends ProgressBar

@export var reload_timer: Timer
# Called when the node enters the scene tree for the first time.
# Not SUPER happy with this being a seperate script... ah well
# Makes the reload bar line up with the timer.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Don't bother updating the bar if the bar isn't visible, duh.
	if not visible:
		pass
	else:
		value = 1 - (reload_timer.time_left / reload_timer.wait_time)
