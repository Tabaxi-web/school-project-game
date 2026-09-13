extends Label
# Screebly text generator for the main menu.
# The whole alphabet.
var char_set = ["a", "b", "c", "d", "e", "f", "g", "h",
"i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u",
"v", "w", "x", "y", "z"] ## What characters they will use
@export var chance_numerator := 9995
@export var chance_denominator := 10000
@export var game_over_screen := false
@export var length := 10000
@export var game_over_string := "0"


# Generate a string of random letters of a certain length.
func _get_random_letter_string(length_of: int) -> String:
	var string_result = ""
	for i in range(length_of):
		string_result += char_set[randi_range(0, len(char_set) - 1)]
	return string_result
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# 0.0005% change for any given letter to change to another every frame.
	for i in range(text.length()):
		if randi_range(0, chance_denominator) > chance_numerator:
			if randi_range(0,1) == 0: # Coin flip!
				text[i] = _get_random_letter_string(1)
			else:
				text[i] = _get_random_letter_string(1).to_upper()
				
	pass


func _on_timer_timeout() -> void:
	# Change the whole thing after a set amount of time.
	if not game_over_screen:
		text = Marshalls.utf8_to_base64(_get_random_letter_string(length))
	else:
		text = ""
		for i in range(length):
			text += game_over_string
