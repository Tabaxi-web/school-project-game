extends Label
# Screebly text generator for the main menu.
# The whole alphabet.
@export var replacement_text := "#"
@export var chance_numerator := 9995
@export var chance_denominator := 10000
@export var transition_manager: Node2D
@export var text_length := 10000
var prev_wave_number := 0
# Generate a string of random letters of a certain length.	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if transition_manager.wave_number != prev_wave_number:
		prev_wave_number = transition_manager.wave_number
		text = ""
		for i in text_length:
			text += str(prev_wave_number)
	# 0.0005% change for any given letter to change to another every frame.
	for i in range(text.length()):
		if randi_range(0, chance_denominator) > chance_numerator:
			text[i] = replacement_text
				
	pass
